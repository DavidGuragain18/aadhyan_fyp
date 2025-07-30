// course_controller.dart

import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utility/dialog_utils.dart';
import '../../../core/utility/snackbar.dart';
import '../../model/course/course_model.dart';
import '../../model/api_response_model.dart';
import '../../services/course_services.dart';
import '../auth/login_controller.dart';

enum CourseLoadingState {
  initial,
  loading,
  loaded,
  error,
  creating,
  updating,
  deleting,
}

class CourseController extends GetxController {
  // Observable properties
  final _courses = <CourseModel>[].obs;
  final _loadingState = CourseLoadingState.initial.obs;
  final _errorMessage = ''.obs;
  final _selectedCourse = Rxn<CourseModel>();
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxBool isImageUploading = false.obs;
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final createCourseFormKey = GlobalKey<FormState>();

  // Getters
  List<CourseModel> get courses => _courses;
  CourseLoadingState get loadingState => _loadingState.value;
  String get errorMessage => _errorMessage.value;
  CourseModel? get selectedCourse => _selectedCourse.value;
  bool get isLoading => _loadingState.value == CourseLoadingState.loading;
  bool get isCreating => _loadingState.value == CourseLoadingState.creating;
  bool get isUpdating => _loadingState.value == CourseLoadingState.updating;
  bool get isDeleting => _loadingState.value == CourseLoadingState.deleting;
  bool get hasError => _loadingState.value == CourseLoadingState.error;
  bool get isEmpty =>
      _courses.isEmpty && _loadingState.value != CourseLoadingState.loading;

  // Statistics getters
  int get totalCourses => _courses.length;
  int get totalLessons =>
      _courses.fold(0, (sum, course) => sum + course.lessonCount);
  int get activeCourses => _courses.length; // Assuming all courses are active

  late String token;

  @override
  void onInit() {
    super.onInit();
    // initialize();
    final LoginController loginController = Get.find<LoginController>();
    final user = loginController.user.value;
    token = user!.token;
  }

  String? validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Course Title cannot be empty';
    }
    return null;
  }

  String? validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Course description cannot be empty';
    }
    return null;
  }

  void setSelectedImage(File? image) {
    selectedImage.value = image;
  }

  void setImageUploading(bool loading) {
    isImageUploading.value = loading;
  }

  // Set loading state
  void _setLoadingState(CourseLoadingState state) {
    _loadingState.value = state;
  }

  // Set error message and error state
  void _setError(String message) {
    _errorMessage.value = message;
    _setLoadingState(CourseLoadingState.error);
    log('CourseController Error: $message');
  }

  // Clear error
  void clearError() {
    _errorMessage.value = '';
    if (_loadingState.value == CourseLoadingState.error) {
      _setLoadingState(CourseLoadingState.loaded);
    }
  }

  // Refresh courses (pull to refresh)
  Future<void> refreshCourses() async {
    await fetchCourses(showLoading: false);
  }

  // Fetch all courses
  Future<void> fetchCourses({bool showLoading = true}) async {
    FocusScope.of(Get.context!).unfocus();

    try {
      if (showLoading) {
        _setLoadingState(CourseLoadingState.loading);
      }
      _courses.clear(); // Clear existing courses before fetching new ones

      log('Fetching courses...');

      // Simulate delay
      await Future.delayed(const Duration(seconds: 2));

      final ApiResponse<List<CourseModel>> response =
          await CourseService.getCourseList();

      if (response.success && response.data != null) {
        _courses.assignAll(response.data!);
        _setLoadingState(CourseLoadingState.loaded);
        log('Successfully fetched ${_courses.length} courses');
      } else {
        _setError(response.message);
      }
    } catch (e) {
      _setError(
        'An unexpected error occurred while fetching courses: ${e.toString()}',
      );
    }
  }

  Future<bool> createCourse() async {
    // Show confirmation dialog before creating
    final shouldCreate = await DialogUtils.showConfirmDialog(
      title: 'Create Course',
      message: 'Are you sure you want to create this course?',
      confirmText: 'Create',
      cancelText: 'Cancel',
      icon: Icons.add_circle,
    );

    if (!shouldCreate) return false;

    log('Creating course: ${titleController.text.trim()}');
    log('Description: ${descriptionController.text.trim()}');
    log('Selected Image: ${selectedImage.value?.path ?? 'No image selected'}');

    try {
      DialogUtils.showLoadingDialog(message: 'Creating course...');
      await Future.delayed(const Duration(seconds: 2));

      final ApiResponse<CourseModel> response =
          await CourseService.createCourse(
            titleController.text.trim(),
            descriptionController.text.trim(),
            image: selectedImage.value?.path,
          );

      DialogUtils.hideDialog(); // Hide loading dialog

      if (response.success && response.data != null) {
        _courses.insert(0, response.data!);
        _setLoadingState(CourseLoadingState.loaded);
        log('Successfully created course: ${response.data!.title}');
        SnackBarMessage.showSuccessMessage('Course created successfully');
        _clearFormData();
        return true;
      } else {
        DialogUtils.showErrorDialog(
          title: 'Creation Failed',
          message: response.message,
        );
        return false;
      }
    } catch (e) {
      DialogUtils.hideDialog(); // Hide loading dialog
      DialogUtils.showErrorDialog(
        title: 'Creation Failed',
        message:
            'An unexpected error occurred while creating course: ${e.toString()}',
      );
      return false;
    }
  }

  Future<bool> updateCourse(
    String courseId,
    String title,
    String description, {
    String? imagePath,
  }) async {
    // Show confirmation dialog before updating
    final shouldUpdate = await DialogUtils.showConfirmDialog(
      title: 'Update Course',
      message: 'Are you sure you want to update this course?',
      confirmText: 'Update',
      cancelText: 'Cancel',
      icon: Icons.edit,
    );

    if (!shouldUpdate) return false;

    try {
      DialogUtils.showLoadingDialog(message: 'Updating course...');

      await Future.delayed(const Duration(seconds: 2));

      log('Updating course: $courseId');
      final ApiResponse<CourseModel> response =
          await CourseService.updateCourse(
            courseId,
            title,
            description,
            imagePath: imagePath,
          );

      DialogUtils.hideDialog(); // Hide loading dialog

      if (response.success && response.data != null) {
        final index = _courses.indexWhere((course) => course.id == courseId);
        if (index != -1) {
          _courses[index] = response.data!;
        }
        _setLoadingState(CourseLoadingState.loaded);
        log('Successfully updated course: ${response.data!.title}');

        SnackBarMessage.showSuccessMessage('Course updated successfully');
        return true;
      } else {
        DialogUtils.showErrorDialog(
          title: 'Update Failed',
          message: response.message,
        );
        return false;
      }
    } catch (e) {
      DialogUtils.hideDialog(); // Hide loading dialog
      DialogUtils.showErrorDialog(
        title: 'Update Failed',
        message:
            'An unexpected error occurred while updating course: ${e.toString()}',
      );
      return false;
    }
  }

  Future<bool> deleteCourse(String courseId) async {
    try {
      DialogUtils.showLoadingDialog(message: 'Deleting course...');

      log('Deleting course: $courseId');

      await Future.delayed(Duration(seconds: 2));

      final ApiResponse<bool> response = await CourseService.deleteCourse(
        courseId,
      );

      DialogUtils.hideDialog(); // Hide loading dialog

      if (response.success) {
        _courses.removeWhere((course) => course.id == courseId);
        _setLoadingState(CourseLoadingState.loaded);
        log('Successfully deleted course: $courseId');

        SnackBarMessage.showSuccessMessage('Course deleted successfully');
        return true;
      } else {
        DialogUtils.showErrorDialog(
          title: 'Delete Failed',
          message: response.message,
        );
        return false;
      }
    } catch (e) {
      DialogUtils.hideDialog(); // Hide loading dialog
      DialogUtils.showErrorDialog(
        title: 'Delete Failed',
        message:
            'An unexpected error occurred while deleting course: ${e.toString()}',
      );
      return false;
    }
  }

  // Create a new course - FIXED VERSION

  // Clear form data
  void _clearFormData() {
    titleController.clear();
    descriptionController.clear();
    selectedImage.value = null;
  }

  // Select a course
  void selectCourse(CourseModel course) {
    _selectedCourse.value = course;
  }

  // Clear selected course
  void clearSelectedCourse() {
    _selectedCourse.value = null;
  }

  // Get course by ID
  CourseModel? getCourseById(String courseId) {
    try {
      return _courses.firstWhere((course) => course.id == courseId);
    } catch (e) {
      return null;
    }
  }

  // Search courses by title or description
  List<CourseModel> searchCourses(String query) {
    if (query.isEmpty) return _courses;

    final lowerQuery = query.toLowerCase();
    return _courses.where((course) {
      return course.title.toLowerCase().contains(lowerQuery) ||
          course.description.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Filter courses (you can extend this with more filters)
  List<CourseModel> filterCourses({int? minLessons, int? maxLessons}) {
    return _courses.where((course) {
      bool matchesMinLessons =
          minLessons == null || course.lessons.length >= minLessons;
      bool matchesMaxLessons =
          maxLessons == null || course.lessons.length <= maxLessons;

      return matchesMinLessons && matchesMaxLessons;
    }).toList();
  }

  // Reset controller
  void reset() {
    _courses.clear();
    _errorMessage.value = '';
    _selectedCourse.value = null;
    _setLoadingState(CourseLoadingState.initial);
  }

  // Debug method to print current state
  void debugPrintState() {
    log('=== CourseController State ===');
    log('Courses count: ${_courses.length}');
    log('Loading state: ${_loadingState.value}');
    log('Error message: ${_errorMessage.value}');
    log('Selected course: ${_selectedCourse.value?.title ?? 'None'}');
    log('============================');
  }

  // Show error dialog
  void showErrorDialog(String message) {
    Get.defaultDialog(
      title: 'Error',
      middleText: message,
      textConfirm: 'OK',
      confirmTextColor: Get.theme.colorScheme.onPrimary,
      buttonColor: Get.theme.primaryColor,
      onConfirm: () => Get.back(),
    );
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
