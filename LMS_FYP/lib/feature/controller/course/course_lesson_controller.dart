// course_lesson_controller.dart

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_fyp/core/utility/snackbar.dart';
import 'package:get/get.dart';
import '../../../core/utility/dialog_utils.dart';
import '../../model/course/course_lesson_model.dart';
import '../../services/course_lesson_services.dart';
import 'course_controller.dart';

class CourseLessonController extends GetxController {
  // Observable variables for state management
  final RxList<CourseLessonModel> lessons = <CourseLessonModel>[].obs;
  final Rx<CourseLessonModel?> selectedLesson = Rx<CourseLessonModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isCreating = false.obs;
  final RxBool isUpdating = false.obs;
  final RxBool isDeleting = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString successMessage = ''.obs;

  // Controllers for form input fields
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController readingDurationController = TextEditingController();
  final TextEditingController keywordsController = TextEditingController();

  // Holds the currently selected course ID
  final RxString currentCourseId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    log('CourseLessonController initialized');
  }

  @override
  void onClose() {
    // Clean up controllers when controller is disposed
    titleController.dispose();
    descriptionController.dispose();
    readingDurationController.dispose();
    keywordsController.dispose();
    super.onClose();
  }

  // Resets controller state and clears all data
  void clearData() {
    lessons.clear();
    selectedLesson.value = null;
    errorMessage.value = '';
    successMessage.value = '';
    clearControllers();
  }

  // Clears all text fields
  void clearControllers() {
    titleController.clear();
    descriptionController.clear();
    readingDurationController.clear();
    keywordsController.clear();
  }

  // Clears success and error messages
  void clearMessages() {
    errorMessage.value = '';
    successMessage.value = '';
  }

  // Sets the currently selected course ID
  void setCurrentCourseId(String courseId) {
    currentCourseId.value = courseId;
  }

  // Converts comma-separated keyword string into a list
  List<String> parseKeywords(String keywordString) {
    return keywordString
        .split(',')
        .map((keyword) => keyword.trim())
        .where((keyword) => keyword.isNotEmpty)
        .toList();
  }

  // Formats a keyword list into a display string
  String formatKeywords(List<String> keywords) {
    return keywords.join(', ');
  }

  // Fetch all lessons for a given course
  Future<void> fetchCourseLessons({String? courseId}) async {
    try {
      isLoading.value = true;
      clearMessages();

      await Future.delayed(Duration(seconds: 2));

      String targetCourseId = courseId ?? currentCourseId.value;
      if (targetCourseId.isEmpty) {
        throw Exception('Course ID is required');
      }

      log('Fetching lessons for course: $targetCourseId');

      final response = await CourseLessonService.getCourseLessons(targetCourseId);

      if (response.success && response.data != null) {
        lessons.assignAll(response.data!);
        successMessage.value = response.message;
        log('Fetched ${lessons.length} lessons successfully');
      } else {
        errorMessage.value = response.message;
        log('Failed to fetch lessons: ${response.message}');
      }
    } catch (e) {
      errorMessage.value = 'Error fetching lessons: ${e.toString()}';
      log('Exception in fetchCourseLessons: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch a single lesson by its ID
  Future<void> fetchCourseLesson(String lessonId, {String? courseId}) async {
    try {
      isLoading.value = true;
      clearMessages();
      await Future.delayed(Duration(seconds: 2));

      String targetCourseId = courseId ?? currentCourseId.value;
      if (targetCourseId.isEmpty) throw Exception('Course ID is required');
      if (lessonId.isEmpty) throw Exception('Lesson ID is required');

      log('Fetching lesson: $lessonId for course: $targetCourseId');

      final response = await CourseLessonService.getCourseLessonByID(
        targetCourseId,
        lessonId,
      );

      if (response.success && response.data != null) {
        selectedLesson.value = response.data!;
        successMessage.value = response.message;
        log('Fetched lesson successfully: ${response.data!.title}');
      } else {
        errorMessage.value = response.message;
        log('Failed to fetch lesson: ${response.message}');
      }
    } catch (e) {
      errorMessage.value = 'Error fetching lesson: ${e.toString()}';
      log('Exception in fetchCourseLesson: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Create a new lesson for a course
  Future<bool> createCourseLesson({String? courseId, String? pdfPath}) async {
    final shouldCreate = await DialogUtils.showConfirmDialog(
      title: 'Create Lesson',
      message: 'Are you sure you want to create this lesson?',
      confirmText: 'Create',
      cancelText: 'Cancel',
      icon: Icons.add_circle,
    );
    if (!shouldCreate) return false;

    try {
      DialogUtils.showLoadingDialog(message: 'Creating lesson...');
      await Future.delayed(Duration(seconds: 2));
      isCreating.value = true;
      clearMessages();

      String targetCourseId = courseId ?? currentCourseId.value;
      if (targetCourseId.isEmpty) throw Exception('Course ID is required');

      // Form validation
      if (!validateLessonForm()) return false;

      List<String> keywords = parseKeywords(keywordsController.text);

      final response = await CourseLessonService.createCourseLesson(
        targetCourseId,
        titleController.text.trim(),
        descriptionController.text.trim(),
        int.parse(readingDurationController.text.trim()),
        keywords,
        pdfPath: pdfPath,
      );

      if (response.success && response.data != null) {
        lessons.add(response.data!);
        successMessage.value = response.message;

        // Refresh course list after creation
        try {
          CourseController courseController = Get.find<CourseController>();
          await courseController.fetchCourses(showLoading: false);
        } catch (e) {
          log('CourseController not found or error refreshing courses: $e');
        }

        clearControllers();
        SnackBarMessage.showSuccessMessage(response.message);
        return true;
      } else {
        errorMessage.value = response.message;
        Get.snackbar('Error', response.message, snackPosition: SnackPosition.BOTTOM);
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Error creating lesson: ${e.toString()}';
      Get.snackbar('Error', errorMessage.value, snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isCreating.value = false;
      DialogUtils.hideDialog();
    }
  }

  // Update an existing lesson
  Future<bool> updateCourseLesson(String lessonId,
      {String? courseId, String? pdfPath}) async {
    final shouldUpdate = await DialogUtils.showConfirmDialog(
      title: 'Update Lesson',
      message: 'Are you sure you want to update this lesson?',
      confirmText: 'Update',
      cancelText: 'Cancel',
      icon: Icons.edit,
    );
    if (!shouldUpdate) return false;

    try {
      DialogUtils.showLoadingDialog(message: 'Updating lesson...');
      await Future.delayed(Duration(seconds: 2));
      isUpdating.value = true;
      clearMessages();

      String targetCourseId = courseId ?? currentCourseId.value;
      if (targetCourseId.isEmpty || lessonId.isEmpty)
        throw Exception('Course ID and Lesson ID are required');

      // Form validation
      if (!validateLessonForm()) return false;

      List<String> keywords = parseKeywords(keywordsController.text);

      final response = await CourseLessonService.updateCourseLesson(
        targetCourseId,
        lessonId,
        titleController.text.trim(),
        descriptionController.text.trim(),
        int.parse(readingDurationController.text.trim()),
        keywords,
        pdfPath: pdfPath,
      );

      if (response.success && response.data != null) {
        int index = lessons.indexWhere((lesson) => lesson.id == lessonId);
        if (index != -1) lessons[index] = response.data!;
        if (selectedLesson.value?.id == lessonId)
          selectedLesson.value = response.data!;

        successMessage.value = response.message;
        Get.snackbar('Success', response.message, snackPosition: SnackPosition.BOTTOM);
        return true;
      } else {
        errorMessage.value = response.message;
        Get.snackbar('Error', response.message, snackPosition: SnackPosition.BOTTOM);
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Error updating lesson: ${e.toString()}';
      Get.snackbar('Error', errorMessage.value, snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isUpdating.value = false;
      DialogUtils.hideDialog();
    }
  }

  // Delete a lesson by ID
  Future<bool> deleteCourseLesson(String lessonId, {String? courseId}) async {
    try {
      DialogUtils.showLoadingDialog(message: 'Deleting lesson...');
      await Future.delayed(Duration(seconds: 2));
      isDeleting.value = true;
      clearMessages();

      String targetCourseId = courseId ?? currentCourseId.value;
      if (targetCourseId.isEmpty || lessonId.isEmpty)
        throw Exception('Course ID and Lesson ID are required');

      final response = await CourseLessonService.deleteCourseLesson(
        targetCourseId,
        lessonId,
      );

      if (response.success) {
        lessons.removeWhere((lesson) => lesson.id == lessonId);
        if (selectedLesson.value?.id == lessonId)
          selectedLesson.value = null;

        successMessage.value = response.message;
        Get.snackbar('Success', response.message, snackPosition: SnackPosition.BOTTOM);
        return true;
      } else {
        errorMessage.value = response.message;
        Get.snackbar('Error', response.message, snackPosition: SnackPosition.BOTTOM);
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Error deleting lesson: ${e.toString()}';
      Get.snackbar('Error', errorMessage.value, snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isDeleting.value = false;
      DialogUtils.hideDialog();
    }
  }

  // Load selected lesson into form fields for editing
  void loadLessonForEditing(CourseLessonModel lesson) {
    titleController.text = lesson.title;
    descriptionController.text = lesson.description;
    readingDurationController.text = lesson.readingDuration.toString();
    keywordsController.text = formatKeywords(lesson.keywords);
    selectedLesson.value = lesson;
  }

  // Refresh the list of lessons
  Future<void> refreshLessons({String? courseId}) async {
    await fetchCourseLessons(courseId: courseId);
  }

  // Search lessons by title, description or keywords
  List<CourseLessonModel> searchLessons(String query) {
    if (query.trim().isEmpty) return lessons.toList();

    String searchQuery = query.toLowerCase().trim();
    return lessons.where((lesson) {
      return lesson.title.toLowerCase().contains(searchQuery) ||
          lesson.description.toLowerCase().contains(searchQuery) ||
          lesson.keywords.any((keyword) =>
              keyword.toLowerCase().contains(searchQuery));
    }).toList();
  }

  // Filter lessons by duration range
  List<CourseLessonModel> filterLessonsByDuration(int min, int max) {
    return lessons.where((lesson) =>
        lesson.readingDuration >= min && lesson.readingDuration <= max).toList();
  }

  // Sort lessons by title alphabetically
  void sortLessonsByTitle({bool ascending = true}) {
    lessons.sort((a, b) =>
        ascending ? a.title.compareTo(b.title) : b.title.compareTo(a.title));
  }

  // Sort lessons by duration
  void sortLessonsByDuration({bool ascending = true}) {
    lessons.sort((a, b) => ascending
        ? a.readingDuration.compareTo(b.readingDuration)
        : b.readingDuration.compareTo(a.readingDuration));
  }

  // Get total time needed to complete all lessons
  int getTotalReadingDuration() {
    return lessons.fold(0, (total, lesson) => total + lesson.readingDuration);
  }

  // Returns the number of lessons
  int get lessonCount => lessons.length;

  // Check if a lesson contains a PDF
  bool hasLessonPdf(CourseLessonModel lesson) {
    return lesson.pdfUrl != null && lesson.pdfUrl!.isNotEmpty;
  }

  // Form validation for lesson creation and update
  bool validateLessonForm() {
    clearMessages();

    if (titleController.text.trim().isEmpty) {
      errorMessage.value = 'Title is required';
      return false;
    }

    if (descriptionController.text.trim().isEmpty) {
      errorMessage.value = 'Description is required';
      return false;
    }

    int readingDuration =
        int.tryParse(readingDurationController.text.trim()) ?? 0;
    if (readingDuration <= 0) {
      errorMessage.value = 'Reading duration must be greater than 0';
      return false;
    }

    return true;
  }
}
