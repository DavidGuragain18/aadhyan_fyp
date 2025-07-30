// enrollment_controller.dart

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utility/dialog_utils.dart';
import '../../../core/utility/snackbar.dart';
import '../../model/course/enrollment_model.dart';
import '../../services/enrollment_api_services.dart';
import 'course_controller.dart';

enum EnrollmentStatus { pending, approved, rejected }

class EnrollmentController extends GetxController {
  // Observable lists
  final RxList<EnrollmentModel> _enrollments = <EnrollmentModel>[].obs;
  final RxList<EnrollmentModel> _myEnrollments = <EnrollmentModel>[].obs;
  final RxList<EnrollmentModel> _courseEnrollments = <EnrollmentModel>[].obs;
  final RxList<EnrollmentModel> _teacherEnrollments = <EnrollmentModel>[].obs;

  // Loading states
  final RxBool _isLoading = false.obs;
  final RxBool _isCreatingEnrollment = false.obs;
  final RxBool _isUpdatingEnrollment = false.obs;
  final RxBool _isDeletingEnrollment = false.obs;
  final RxBool _isLoadingMyEnrollments = false.obs;
  final RxBool _isLoadingCourseEnrollments = false.obs;
  final RxBool _isLoadingTeacherEnrollments = false.obs;
  final RxBool _isUpdatingStatus = false.obs;

  // Selected enrollment
  final Rx<EnrollmentModel?> _selectedEnrollment = Rx<EnrollmentModel?>(null);

  // Enrollment count
  final RxInt _enrollmentCount = 0.obs;

  // Error message
  final RxString _errorMessage = ''.obs;

  // Getters
  List<EnrollmentModel> get enrollments => _enrollments;
  List<EnrollmentModel> get myEnrollments => _myEnrollments;
  List<EnrollmentModel> get courseEnrollments => _courseEnrollments;
  List<EnrollmentModel> get teacherEnrollments => _teacherEnrollments;

  bool get isLoading => _isLoading.value;
  bool get isCreatingEnrollment => _isCreatingEnrollment.value;
  bool get isUpdatingEnrollment => _isUpdatingEnrollment.value;
  bool get isDeletingEnrollment => _isDeletingEnrollment.value;
  bool get isLoadingMyEnrollments => _isLoadingMyEnrollments.value;
  bool get isLoadingCourseEnrollments => _isLoadingCourseEnrollments.value;
  bool get isLoadingTeacherEnrollments => _isLoadingTeacherEnrollments.value;
  bool get isUpdatingStatus => _isUpdatingStatus.value;

  EnrollmentModel? get selectedEnrollment => _selectedEnrollment.value;
  int get enrollmentCount => _enrollmentCount.value;
  String get errorMessage => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    log('EnrollmentController initialized');
  }

  @override
  void onClose() {
    log('EnrollmentController disposed');
    super.onClose();
  }

  // Clear error message
  void clearError() {
    _errorMessage.value = '';
  }

  // Set selected enrollment
  void setSelectedEnrollment(EnrollmentModel? enrollment) {
    _selectedEnrollment.value = enrollment;
  }

  // Create new enrollment
  Future<bool> createEnrollment({
    required String courseId,
    bool showSnackbar = true,
  }) async {
    final shouldCreate = await DialogUtils.showConfirmDialog(
      title: 'Enroll Now',
      message: 'Are you sure you want to enroll this lesson?',
      confirmText: 'Enroll Now',
      cancelText: 'Cancel',
      icon: Icons.add_circle,
    );

    if (!shouldCreate) return false;
    try {
      DialogUtils.showLoadingDialog(message: 'Creating lesson...');

      await Future.delayed(const Duration(seconds: 2));
      _isCreatingEnrollment.value = true;
      clearError();

      log('Creating enrollment for course: $courseId');

      final response = await EnrollmentApiService.createEnrollment(courseId);
      DialogUtils.hideDialog(); // Hide loading dialog

      if (response.success && response.data != null) {
        // Add to my enrollments list
        _myEnrollments.add(response.data!);
        final courseController = Get.find<CourseController>();
        await courseController.refreshCourses();

        SnackBarMessage.showSuccessMessage(response.message);

        log('Enrollment created successfully');
        return true;
      } else {
        _errorMessage.value = response.message ?? 'Failed to create enrollment';

        if (showSnackbar) {
          Get.snackbar(
            'Error',
            response.message ?? 'Failed to create enrollment',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
        }

        log('Failed to create enrollment: ${response.message}');
        return false;
      }
    } catch (e) {
      _errorMessage.value = 'An unexpected error occurred: ${e.toString()}';

      if (showSnackbar) {
        Get.snackbar(
          'Error',
          'An unexpected error occurred',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }

      log('Exception in createEnrollment: $e');
      return false;
    } finally {
      _isCreatingEnrollment.value = false;
    }
  }

  // Get my enrollments
  Future<void> getMyEnrollments({bool showSnackbar = false}) async {
    try {
      _isLoadingMyEnrollments.value = true;
      clearError();

      log('Fetching my enrollments');

      final response = await EnrollmentApiService.getMyEnrollments();

      if (response.success && response.data != null) {
        _myEnrollments.assignAll(response.data!);

        log(
          'My enrollments fetched successfully: ${_myEnrollments.length} items',
        );
      } else {
        _errorMessage.value =
            response.message ?? 'Failed to fetch my enrollments';

        if (showSnackbar) {
          Get.snackbar(
            'Error',
            response.message ?? 'Failed to fetch my enrollments',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
        }

        log('Failed to fetch my enrollments: ${response.message}');
      }
    } catch (e) {
      _errorMessage.value = 'An unexpected error occurred: ${e.toString()}';

      if (showSnackbar) {
        Get.snackbar(
          'Error',
          'An unexpected error occurred',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }

      log('Exception in getMyEnrollments: $e');
    } finally {
      _isLoadingMyEnrollments.value = false;
    }
  }

  // Get course enrollments
  Future<void> getCourseEnrollments({
    required String courseId,
    bool showSnackbar = false,
  }) async {
    try {
      _isLoadingCourseEnrollments.value = true;
      clearError();

      log('Fetching course enrollments for: $courseId');

      final response = await EnrollmentApiService.getCourseEnrollments(
        courseId,
      );

      if (response.success && response.data != null) {
        _courseEnrollments.assignAll(response.data!);

        log(
          'Course enrollments fetched successfully: ${_courseEnrollments.length} items',
        );
      } else {
        _errorMessage.value =
            response.message ?? 'Failed to fetch course enrollments';

        if (showSnackbar) {
          Get.snackbar(
            'Error',
            response.message ?? 'Failed to fetch course enrollments',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
        }

        log('Failed to fetch course enrollments: ${response.message}');
      }
    } catch (e) {
      _errorMessage.value = 'An unexpected error occurred: ${e.toString()}';

      if (showSnackbar) {
        Get.snackbar(
          'Error',
          'An unexpected error occurred',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }

      log('Exception in getCourseEnrollments: $e');
    } finally {
      _isLoadingCourseEnrollments.value = false;
    }
  }

  // Get enrollments for teacher
  Future<void> getEnrollmentsForTeacher({String? status,bool showSnackbar = false}) async {
    EnrollmentStatus? status;
    try {
      _isLoadingTeacherEnrollments.value = true;
      clearError();

      log('Fetching teacher enrollments');

      final response = await EnrollmentApiService.getEnrollmentsForTeacher(
        status.toString(),
      );

      if (response.success && response.data != null) {
        _teacherEnrollments.assignAll(response.data!);

        log(
          'Teacher enrollments fetched successfully: ${_teacherEnrollments.length} items',
        );
      } else {
        _errorMessage.value =
            response.message ?? 'Failed to fetch teacher enrollments';

        if (showSnackbar) {
          Get.snackbar(
            'Error',
            response.message ?? 'Failed to fetch teacher enrollments',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
        }

        log('Failed to fetch teacher enrollments: ${response.message}');
      }
    } catch (e) {
      _errorMessage.value = 'An unexpected error occurred: ${e.toString()}';

      if (showSnackbar) {
        Get.snackbar(
          'Error',
          'An unexpected error occurred',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }

      log('Exception in getEnrollmentsForTeacher: $e');
    } finally {
      _isLoadingTeacherEnrollments.value = false;
    }
  }

  // Get enrollment by ID
  Future<EnrollmentModel?> getEnrollmentById({
    required String enrollmentId,
    bool showSnackbar = false,
  }) async {
    try {
      _isLoading.value = true;
      clearError();

      log('Fetching enrollment by ID: $enrollmentId');

      final response = await EnrollmentApiService.getEnrollmentById(
        enrollmentId,
      );

      if (response.success && response.data != null) {
        _selectedEnrollment.value = response.data!;

        log('Enrollment fetched successfully: ${response.data!.id}');
        return response.data!;
      } else {
        _errorMessage.value = response.message ?? 'Failed to fetch enrollment';

        if (showSnackbar) {
          Get.snackbar(
            'Error',
            response.message ?? 'Failed to fetch enrollment',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
        }

        log('Failed to fetch enrollment: ${response.message}');
        return null;
      }
    } catch (e) {
      _errorMessage.value = 'An unexpected error occurred: ${e.toString()}';

      if (showSnackbar) {
        Get.snackbar(
          'Error',
          'An unexpected error occurred',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }

      log('Exception in getEnrollmentById: $e');
      return null;
    } finally {
      _isLoading.value = false;
    }
  }

  // Update enrollment
  Future<bool> updateEnrollment({
    required String enrollmentId,
    required Map<String, dynamic> updateData,
    bool showSnackbar = true,
  }) async {
    try {
      _isUpdatingEnrollment.value = true;
      clearError();

      log('Updating enrollment: $enrollmentId');

      final response = await EnrollmentApiService.updateEnrollment(
        enrollmentId,
        updateData,
      );

      if (response.success && response.data != null) {
        // Update in respective lists
        _updateInAllLists(response.data!);

        if (showSnackbar) {
          Get.snackbar(
            'Success',
            response.message ?? 'Enrollment updated successfully',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
        }

        log('Enrollment updated successfully');
        return true;
      } else {
        _errorMessage.value = response.message ?? 'Failed to update enrollment';

        if (showSnackbar) {
          Get.snackbar(
            'Error',
            response.message ?? 'Failed to update enrollment',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
        }

        log('Failed to update enrollment: ${response.message}');
        return false;
      }
    } catch (e) {
      _errorMessage.value = 'An unexpected error occurred: ${e.toString()}';

      if (showSnackbar) {
        Get.snackbar(
          'Error',
          'An unexpected error occurred',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }

      log('Exception in updateEnrollment: $e');
      return false;
    } finally {
      _isUpdatingEnrollment.value = false;
    }
  }

  // Update enrollment status (approve/reject)
  Future<bool> updateEnrollmentStatus({
    required String enrollmentId,
    required EnrollmentStatus status,
    bool showSnackbar = true,
  }) async {
    try {
      _isUpdatingStatus.value = true;
      clearError();

      String statusString = status.name; // pending, approved, rejected
      log('Updating enrollment status: $enrollmentId to $statusString');

      final response = await EnrollmentApiService.updateEnrollmentStatus(
        enrollmentId,
        statusString,
      );

      if (response.success && response.data != null) {
        // Update in respective lists
        _updateInAllLists(response.data!);

        if (showSnackbar) {
          Get.snackbar(
            'Success',
            response.message ?? 'Enrollment status updated successfully',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
        }

        log('Enrollment status updated successfully');
        return true;
      } else {
        _errorMessage.value =
            response.message ?? 'Failed to update enrollment status';

        if (showSnackbar) {
          Get.snackbar(
            'Error',
            response.message ?? 'Failed to update enrollment status',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
        }

        log('Failed to update enrollment status: ${response.message}');
        return false;
      }
    } catch (e) {
      _errorMessage.value = 'An unexpected error occurred: ${e.toString()}';

      if (showSnackbar) {
        Get.snackbar(
          'Error',
          'An unexpected error occurred',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }

      log('Exception in updateEnrollmentStatus: $e');
      return false;
    } finally {
      _isUpdatingStatus.value = false;
    }
  }

  // Delete enrollment
  Future<bool> deleteEnrollment({
    required String enrollmentId,
    bool showSnackbar = true,
  }) async {
    try {
      _isDeletingEnrollment.value = true;
      clearError();

      log('Deleting enrollment: $enrollmentId');

      final response = await EnrollmentApiService.deleteEnrollment(
        enrollmentId,
      );

      if (response.success) {
        // Remove from all lists
        _removeFromAllLists(enrollmentId);

        if (showSnackbar) {
          Get.snackbar(
            'Success',
            response.message ?? 'Enrollment deleted successfully',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
        }

        log('Enrollment deleted successfully');
        return true;
      } else {
        _errorMessage.value = response.message ?? 'Failed to delete enrollment';

        if (showSnackbar) {
          Get.snackbar(
            'Error',
            response.message ?? 'Failed to delete enrollment',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
        }

        log('Failed to delete enrollment: ${response.message}');
        return false;
      }
    } catch (e) {
      _errorMessage.value = 'An unexpected error occurred: ${e.toString()}';

      if (showSnackbar) {
        Get.snackbar(
          'Error',
          'An unexpected error occurred',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }

      log('Exception in deleteEnrollment: $e');
      return false;
    } finally {
      _isDeletingEnrollment.value = false;
    }
  }

  // Get enrollment count for a course
  Future<void> getEnrollmentCount({
    required String courseId,
    bool showSnackbar = false,
  }) async {
    try {
      _isLoading.value = true;
      clearError();

      log('Fetching enrollment count for course: $courseId');

      final response = await EnrollmentApiService.getEnrollmentCount(courseId);

      if (response.success && response.data != null) {
        _enrollmentCount.value = response.data!;

        log('Enrollment count fetched successfully: ${response.data!}');
      } else {
        _errorMessage.value =
            response.message ?? 'Failed to fetch enrollment count';

        if (showSnackbar) {
          Get.snackbar(
            'Error',
            response.message ?? 'Failed to fetch enrollment count',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
        }

        log('Failed to fetch enrollment count: ${response.message}');
      }
    } catch (e) {
      _errorMessage.value = 'An unexpected error occurred: ${e.toString()}';

      if (showSnackbar) {
        Get.snackbar(
          'Error',
          'An unexpected error occurred',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }

      log('Exception in getEnrollmentCount: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // Helper method to check if user is enrolled in a course
  bool isEnrolledInCourse(String courseId) {
    return _myEnrollments.any((enrollment) => enrollment.courseId == courseId);
  }

  // Helper method to get enrollment for a specific course
  EnrollmentModel? getEnrollmentForCourse(String courseId) {
    try {
      return _myEnrollments.firstWhere(
        (enrollment) => enrollment.courseId.id == courseId,
      );
    } catch (e) {
      return null;
    }
  }

  // Helper method to get enrollments by status
  List<EnrollmentModel> getEnrollmentsByStatus(EnrollmentStatus status) {
    return _teacherEnrollments
        .where((enrollment) => enrollment.status?.toLowerCase() == status.name)
        .toList();
  }

  // Helper method to clear all lists
  void clearAllLists() {
    _enrollments.clear();
    _myEnrollments.clear();
    _courseEnrollments.clear();
    _teacherEnrollments.clear();
    _selectedEnrollment.value = null;
    _enrollmentCount.value = 0;
  }

  // Helper method to update enrollment in all relevant lists
  void _updateInAllLists(EnrollmentModel updatedEnrollment) {
    // Update in my enrollments
    final myIndex = _myEnrollments.indexWhere(
      (enrollment) => enrollment.id == updatedEnrollment.id,
    );
    if (myIndex != -1) {
      _myEnrollments[myIndex] = updatedEnrollment;
    }

    // Update in course enrollments
    final courseIndex = _courseEnrollments.indexWhere(
      (enrollment) => enrollment.id == updatedEnrollment.id,
    );
    if (courseIndex != -1) {
      _courseEnrollments[courseIndex] = updatedEnrollment;
    }

    // Update in teacher enrollments
    final teacherIndex = _teacherEnrollments.indexWhere(
      (enrollment) => enrollment.id == updatedEnrollment.id,
    );
    if (teacherIndex != -1) {
      _teacherEnrollments[teacherIndex] = updatedEnrollment;
    }

    // Update selected enrollment if it matches
    if (_selectedEnrollment.value?.id == updatedEnrollment.id) {
      _selectedEnrollment.value = updatedEnrollment;
    }
  }

  // Helper method to remove enrollment from all lists
  void _removeFromAllLists(String enrollmentId) {
    _myEnrollments.removeWhere((enrollment) => enrollment.id == enrollmentId);
    _courseEnrollments.removeWhere(
      (enrollment) => enrollment.id == enrollmentId,
    );
    _teacherEnrollments.removeWhere(
      (enrollment) => enrollment.id == enrollmentId,
    );

    // Clear selected enrollment if it matches
    if (_selectedEnrollment.value?.id == enrollmentId) {
      _selectedEnrollment.value = null;
    }
  }

  // Refresh all data
  Future<void> refreshAllData() async {
    await Future.wait([getMyEnrollments(), getEnrollmentsForTeacher()]);
  }

  // Show confirmation dialog for destructive actions
  Future<bool> showConfirmationDialog({
    required String title,
    required String content,
    String confirmText = 'Yes',
    String cancelText = 'No',
  }) async {
    return await Get.dialog<bool>(
          AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: Text(cancelText),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: Text(
                  confirmText,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }
}
