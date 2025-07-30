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
  // Observable variables
  final RxList<CourseLessonModel> lessons = <CourseLessonModel>[].obs;
  final Rx<CourseLessonModel?> selectedLesson = Rx<CourseLessonModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isCreating = false.obs;
  final RxBool isUpdating = false.obs;
  final RxBool isDeleting = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString successMessage = ''.obs;

  // Text controllers for forms
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController readingDurationController =
      TextEditingController();
  final TextEditingController keywordsController = TextEditingController();

  // Current course ID
  final RxString currentCourseId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    log('CourseLessonController initialized');
  }

  @override
  void onClose() {
    // Dispose text controllers
    titleController.dispose();
    descriptionController.dispose();
    readingDurationController.dispose();
    keywordsController.dispose();
    super.onClose();
  }

  // Clear all data
  void clearData() {
    lessons.clear();
    selectedLesson.value = null;
    errorMessage.value = '';
    successMessage.value = '';
    clearControllers();
  }

  // Clear text controllers
  void clearControllers() {
    titleController.clear();
    descriptionController.clear();
    readingDurationController.clear();
    keywordsController.clear();
  }

  // Clear messages
  void clearMessages() {
    errorMessage.value = '';
    successMessage.value = '';
  }

  // Set current course ID
  void setCurrentCourseId(String courseId) {
    currentCourseId.value = courseId;
  }

  // Parse keywords from string input
  List<String> parseKeywords(String keywordString) {
    return keywordString
        .split(',')
        .map((keyword) => keyword.trim())
        .where((keyword) => keyword.isNotEmpty)
        .toList();
  }

  // Format keywords for display
  String formatKeywords(List<String> keywords) {
    return keywords.join(', ');
  }

  // Get all lessons for the current course
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

      final response = await CourseLessonService.getCourseLessons(
        targetCourseId,
      );

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

  // Get a specific lesson by ID
  Future<void> fetchCourseLesson(String lessonId, {String? courseId}) async {
    try {
      isLoading.value = true;
      clearMessages();
      await Future.delayed(Duration(seconds: 2));

      String targetCourseId = courseId ?? currentCourseId.value;
      if (targetCourseId.isEmpty) {
        throw Exception('Course ID is required');
      }

      if (lessonId.isEmpty) {
        throw Exception('Lesson ID is required');
      }

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

  // Create a new lesson
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

      await Future.delayed(const Duration(seconds: 2));

      isCreating.value = true;
      clearMessages();

      String targetCourseId = courseId ?? currentCourseId.value;
      if (targetCourseId.isEmpty) {
        throw Exception('Course ID is required');
      }

      // Validate form inputs
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

      List<String> keywords = parseKeywords(keywordsController.text);

      final response = await CourseLessonService.createCourseLesson(
        targetCourseId,
        titleController.text.trim(),
        descriptionController.text.trim(),
        readingDuration,
        keywords,
        pdfPath: pdfPath,
      );

      if (response.success && response.data != null) {
        // Add the new lesson to the list
        lessons.add(response.data!);
        successMessage.value = response.message;
        try {
          CourseController courseController = Get.find<CourseController>();
          await courseController.fetchCourses(showLoading: false);
          DialogUtils.hideDialog(); // Hide loading dialog
        } catch (e) {
          log('CourseController not found or error refreshing courses: $e');
        }
        clearControllers();
        log('Lesson created successfully: ${response.data!.title}');

        // Show success snackbar
        SnackBarMessage.showSuccessMessage(response.message);

        return true;
      } else {
        errorMessage.value = response.message;
        log('Failed to create lesson: ${response.message}');

        // Show error snackbar
        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color.fromARGB(255, 194, 194, 194),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        return false;
      }
    } catch (e) {
      errorMessage.value = 'Error creating lesson: ${e.toString()}';
      log('Exception in createCourseLesson: $e');

      // Show error snackbar
      Get.snackbar(
        'Error',
        'Error creating lesson: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      return false;
    } finally {
      isCreating.value = false;
    }
  }

  // Update an existing lesson
  Future<bool> updateCourseLesson(
    String lessonId, {
    String? courseId,
    String? pdfPath,
  }) async {
    final shouldCreate = await DialogUtils.showConfirmDialog(
      title: 'Update Lesson',
      message: 'Are you sure you want to update this lesson?',
      confirmText: 'Update',
      cancelText: 'Cancel',
      icon: Icons.edit,
    );
    if (!shouldCreate) return false;

    try {
      DialogUtils.showLoadingDialog(message: 'Updating lesson...');

      await Future.delayed(const Duration(seconds: 2));
      isUpdating.value = true;
      clearMessages();

      String targetCourseId = courseId ?? currentCourseId.value;
      if (targetCourseId.isEmpty) {
        throw Exception('Course ID is required');
      }

      if (lessonId.isEmpty) {
        throw Exception('Lesson ID is required');
      }

      // Validate form inputs
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

      List<String> keywords = parseKeywords(keywordsController.text);

      log('Updating lesson: $lessonId');

      final response = await CourseLessonService.updateCourseLesson(
        targetCourseId,
        lessonId,
        titleController.text.trim(),
        descriptionController.text.trim(),
        readingDuration,
        keywords,
        pdfPath: pdfPath,
      );
      DialogUtils.hideDialog();
      if (response.success && response.data != null) {
        // Update the lesson in the list
        int index = lessons.indexWhere((lesson) => lesson.id == lessonId);
        if (index != -1) {
          lessons[index] = response.data!;
        }

        // Update selected lesson if it's the same
        if (selectedLesson.value?.id == lessonId) {
          selectedLesson.value = response.data!;
        }

        successMessage.value = response.message;
        log('Lesson updated successfully: ${response.data!.title}');

        // Show success snackbar
        Get.snackbar(
          'Success',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        return true;
      } else {
        errorMessage.value = response.message;
        log('Failed to update lesson: ${response.message}');

        // Show error snackbar
        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        return false;
      }
    } catch (e) {
      errorMessage.value = 'Error updating lesson: ${e.toString()}';
      log('Exception in updateCourseLesson: $e');

      // Show error snackbar
      Get.snackbar(
        'Error',
        'Error updating lesson: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  // Delete a lesson
  Future<bool> deleteCourseLesson(String lessonId, {String? courseId}) async {
    log("in delete function lesson ID : $lessonId and Course ID : $courseId");

    try {
      DialogUtils.showLoadingDialog(message: 'Deleting lesson...');

      await Future.delayed(const Duration(seconds: 2));
      isDeleting.value = true;
      clearMessages();

      String targetCourseId = courseId ?? currentCourseId.value;
      if (targetCourseId.isEmpty) {
        throw Exception('Course ID is required');
      }

      if (lessonId.isEmpty) {
        throw Exception('Lesson ID is required');
      }

      log('Deleting lesson: $lessonId');

      final response = await CourseLessonService.deleteCourseLesson(
        targetCourseId,
        lessonId,
      );
      DialogUtils.hideDialog();

      if (response.success) {
        // Remove the lesson from the list
        lessons.removeWhere((lesson) => lesson.id == lessonId);

        // Clear selected lesson if it's the same
        if (selectedLesson.value?.id == lessonId) {
          selectedLesson.value = null;
        }

        successMessage.value = response.message;
        log('Lesson deleted successfully');

        // Show success snackbar
        Get.snackbar(
          'Success',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        return true;
      } else {
        errorMessage.value = response.message;
        log('Failed to delete lesson: ${response.message}');

        // Show error snackbar
        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        return false;
      }
    } catch (e) {
      errorMessage.value = 'Error deleting lesson: ${e.toString()}';
      log('Exception in deleteCourseLesson: $e');

      // Show error snackbar
      Get.snackbar(
        'Error',
        'Error deleting lesson: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      return false;
    } finally {
      isDeleting.value = false;
    }
  }

  // Load lesson data into form controllers for editing
  void loadLessonForEditing(CourseLessonModel lesson) {
    titleController.text = lesson.title;
    descriptionController.text = lesson.description;
    readingDurationController.text = lesson.readingDuration.toString();
    keywordsController.text = formatKeywords(lesson.keywords);
    selectedLesson.value = lesson;
  }

  // Refresh lessons data
  Future<void> refreshLessons({String? courseId}) async {
    await fetchCourseLessons(courseId: courseId);
  }

  // Search lessons by title or keywords
  List<CourseLessonModel> searchLessons(String query) {
    if (query.trim().isEmpty) {
      return lessons.toList();
    }

    String searchQuery = query.toLowerCase().trim();
    return lessons.where((lesson) {
      return lesson.title.toLowerCase().contains(searchQuery) ||
          lesson.description.toLowerCase().contains(searchQuery) ||
          lesson.keywords.any(
            (keyword) => keyword.toLowerCase().contains(searchQuery),
          );
    }).toList();
  }

  // Filter lessons by reading duration
  List<CourseLessonModel> filterLessonsByDuration(
    int minDuration,
    int maxDuration,
  ) {
    return lessons.where((lesson) {
      return lesson.readingDuration >= minDuration &&
          lesson.readingDuration <= maxDuration;
    }).toList();
  }

  // Sort lessons by title
  void sortLessonsByTitle({bool ascending = true}) {
    lessons.sort((a, b) {
      return ascending
          ? a.title.compareTo(b.title)
          : b.title.compareTo(a.title);
    });
  }

  // Sort lessons by reading duration
  void sortLessonsByDuration({bool ascending = true}) {
    lessons.sort((a, b) {
      return ascending
          ? a.readingDuration.compareTo(b.readingDuration)
          : b.readingDuration.compareTo(a.readingDuration);
    });
  }

  // Get total reading duration for all lessons
  int getTotalReadingDuration() {
    return lessons.fold(0, (total, lesson) => total + lesson.readingDuration);
  }

  // Get lesson count
  int get lessonCount => lessons.length;

  // Check if lesson has PDF
  bool hasLessonPdf(CourseLessonModel lesson) {
    return lesson.pdfUrl != null && lesson.pdfUrl!.isNotEmpty;
  }

  // Validate lesson form
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
