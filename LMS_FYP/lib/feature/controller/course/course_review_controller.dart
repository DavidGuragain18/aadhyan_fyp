// course_review_controller.dart

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_fyp/core/utility/clear_focus.dart';
import 'package:get/get.dart';
import '../../model/api_response_model.dart';
import '../../model/course/course_review_model.dart';
import '../../services/course_review_services.dart';

class CourseReviewController extends GetxController {
  // Loading states
  final RxBool _isLoading = false.obs;
  final RxBool _isCreating = false.obs;
  final RxBool _isUpdating = false.obs;
  final RxBool _isDeleting = false.obs;

  // Data observables
  final RxList<CourseRemarkModel> _allReviews = <CourseRemarkModel>[].obs;
  final RxList<CourseRemarkModel> _courseReviews = <CourseRemarkModel>[].obs;
  final Rx<CourseRemarkModel?> _selectedReview = Rx<CourseRemarkModel?>(null);
  final RxInt _reviewCount = 0.obs;

  // Error state
  final RxString _errorMessage = ''.obs;

  // Form controllers for creating/updating reviews
  final TextEditingController commentController = TextEditingController();
  final RxInt selectedRating = 1.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isCreating => _isCreating.value;
  bool get isUpdating => _isUpdating.value;
  bool get isDeleting => _isDeleting.value;

  List<CourseRemarkModel> get allReviews => _allReviews;
  List<CourseRemarkModel> get courseReviews => _courseReviews;
  CourseRemarkModel? get selectedReview => _selectedReview.value;
  int get reviewCount => _reviewCount.value;
  String get errorMessage => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    log('CourseReviewController initialized');
  }

  @override
  void onClose() {
    commentController.dispose();
    super.onClose();
  }

  // Clear error message
  void clearError() {
    _errorMessage.value = '';
  }

  // Clear form data
  void clearForm() {
    commentController.clear();
    selectedRating.value = 1;
  }

  // Set selected review for editing
  void setSelectedReview(CourseRemarkModel? review) {
    _selectedReview.value = review;
    if (review != null) {
      commentController.text = review.comment;
      selectedRating.value = review.rating;
    } else {
      clearForm();
    }
  }

  // Get reviews for a specific course
  Future<void> getReviewsForCourse(
    String courseId, {
    bool showLoading = true,
  }) async {
    try {
      if (showLoading) _isLoading.value = true;
      clearError();

      log('Fetching reviews for course: $courseId');

      final ApiResponse<List<CourseRemarkModel>> response =
          await CourseReviewService.getReviewsForCourse(courseId);

      if (response.success && response.data != null) {
        _courseReviews.value = response.data!;
        log(
          'Successfully fetched ${_courseReviews.length} reviews for course $courseId',
        );
      } else {
        _errorMessage.value = response.message;
        log('Failed to fetch course reviews: ${response.message}');

        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      _errorMessage.value = 'An unexpected error occurred: $e';
      log('Error in getReviewsForCourse: $e');

      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      if (showLoading) _isLoading.value = false;
    }
  }

  // Get all reviews
  Future<void> getAllReviews({bool showLoading = true}) async {
    try {
      if (showLoading) _isLoading.value = true;
      clearError();

      log('Fetching all reviews...');

      final ApiResponse<List<CourseRemarkModel>> response =
          await CourseReviewService.getAllReviews();

      if (response.success && response.data != null) {
        _allReviews.value = response.data!;
        log('Successfully fetched ${_allReviews.length} reviews');

        // Show success message
        Get.snackbar(
          'Success',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        _errorMessage.value = response.message;
        log('Failed to fetch reviews: ${response.message}');

        // Show error message
        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      _errorMessage.value = 'An unexpected error occurred: $e';
      log('Error in getAllReviews: $e');

      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      if (showLoading) _isLoading.value = false;
    }
  }

  // Get a specific review by ID
  Future<void> getReviewById(String reviewId, {bool showLoading = true}) async {
    try {
      if (showLoading) _isLoading.value = true;
      clearError();

      log('Fetching review: $reviewId');

      final ApiResponse<CourseRemarkModel> response =
          await CourseReviewService.getReviewById(reviewId);

      if (response.success && response.data != null) {
        _selectedReview.value = response.data!;
        log('Successfully fetched review: ${response.data!.comment}');
      } else {
        _errorMessage.value = response.message;
        log('Failed to fetch review: ${response.message}');

        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      _errorMessage.value = 'An unexpected error occurred: $e';
      log('Error in getReviewById: $e');

      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      if (showLoading) _isLoading.value = false;
    }
  }

  // Create a new review
  Future<bool> createReview(String courseId) async {
    ClearFocus.clearAllFocus(Get.context!);

    try {
      _isCreating.value = true;
      clearError();

      // Validate input
      if (commentController.text.trim().isEmpty) {
        Get.snackbar(
          'Validation Error',
          'Please enter a comment',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return false;
      }

      log('Creating review for course: $courseId');

      final ApiResponse<CourseRemarkModel> response =
          await CourseReviewService.createReview(
            courseId,
            selectedRating.value,
            commentController.text.trim(),
          );

      if (response.success && response.data != null) {
        log('Review created successfully');

        // Add to local lists
        _allReviews.add(response.data!);
        _courseReviews.add(response.data!);

        // Clear form
        clearForm();

        // Show success message
        Get.snackbar(
          'Success',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );

        return true;
      } else {
        _errorMessage.value = response.message;
        log('Failed to create review: ${response.message}');

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
      _errorMessage.value = 'An unexpected error occurred: $e';
      log('Error in createReview: $e');

      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      return false;
    } finally {
      _isCreating.value = false;
    }
  }

  // Update an existing review
  Future<bool> updateReview(
    String reviewId,
    String courseId,
    String userId,
    bool isApproved,
  ) async {
    ClearFocus.clearAllFocus(Get.context!);
    try {
      _isUpdating.value = true;
      clearError();

      // Validate input
      if (commentController.text.trim().isEmpty) {
        Get.snackbar(
          'Validation Error',
          'Please enter a comment',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return false;
      }

      log('Updating review: $reviewId');

      final ApiResponse<CourseRemarkModel> response =
          await CourseReviewService.updateReview(
            reviewId,
            courseId,
            userId,
            selectedRating.value,
            commentController.text.trim(),
            isApproved,
          );

      if (response.success && response.data != null) {
        log('Review updated successfully');

        // Update in local lists
        final updatedReview = response.data!;

        // Update in all reviews list
        final allIndex = _allReviews.indexWhere(
          (review) => review.toString().contains(reviewId),
        ); // You might need to add an ID field to your model
        if (allIndex != -1) {
          _allReviews[allIndex] = updatedReview;
        }

        // Update in course reviews list
        final courseIndex = _courseReviews.indexWhere(
          (review) => review.toString().contains(reviewId),
        );
        if (courseIndex != -1) {
          _courseReviews[courseIndex] = updatedReview;
        }

        // Update selected review
        _selectedReview.value = updatedReview;

        // Clear form
        clearForm();

        // Show success message
        Get.snackbar(
          'Success',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );

        return true;
      } else {
        _errorMessage.value = response.message;
        log('Failed to update review: ${response.message}');

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
      _errorMessage.value = 'An unexpected error occurred: $e';
      log('Error in updateReview: $e');

      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      return false;
    } finally {
      _isUpdating.value = false;
    }
  }

  // Delete a review
  Future<bool> deleteReview(String reviewId) async {
    try {
      _isDeleting.value = true;
      clearError();

      log('Deleting review: $reviewId');

      final ApiResponse<bool> response = await CourseReviewService.deleteReview(
        reviewId,
      );

      if (response.success) {
        log('Review deleted successfully');

        // Remove from local lists
        _allReviews.removeWhere(
          (review) => review.toString().contains(reviewId),
        );
        _courseReviews.removeWhere(
          (review) => review.toString().contains(reviewId),
        );

        // Clear selected review if it was the deleted one
        if (_selectedReview.value != null &&
            _selectedReview.value.toString().contains(reviewId)) {
          _selectedReview.value = null;
        }

        // Show success message
        Get.snackbar(
          'Success',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );

        return true;
      } else {
        _errorMessage.value = response.message;
        log('Failed to delete review: ${response.message}');

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
      _errorMessage.value = 'An unexpected error occurred: $e';
      log('Error in deleteReview: $e');

      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      return false;
    } finally {
      _isDeleting.value = false;
    }
  }

  // Get review count for a course
  Future<void> getReviewCountForCourse(
    String courseId, {
    bool showLoading = true,
  }) async {
    try {
      if (showLoading) _isLoading.value = true;
      clearError();

      log('Fetching review count for course: $courseId');

      final ApiResponse<int> response =
          await CourseReviewService.getReviewCountForCourse(courseId);

      if (response.success && response.data != null) {
        _reviewCount.value = response.data!;
        log('Successfully fetched review count: ${_reviewCount.value}');
      } else {
        _errorMessage.value = response.message;
        log('Failed to fetch review count: ${response.message}');

        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      _errorMessage.value = 'An unexpected error occurred: $e';
      log('Error in getReviewCountForCourse: $e');

      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      if (showLoading) _isLoading.value = false;
    }
  }

  // Refresh all data
  Future<void> refreshData() async {
    await getAllReviews(showLoading: false);
  }

  // Refresh course reviews
  Future<void> refreshCourseReviews(String courseId) async {
    await getReviewsForCourse(courseId, showLoading: false);
  }

  // Get average rating for course reviews
  double get averageRating {
    if (_courseReviews.isEmpty) return 0.0;

    final totalRating = _courseReviews.fold<int>(
      0,
      (sum, review) => sum + review.rating,
    );

    return totalRating / _courseReviews.length;
  }

  // Get reviews by rating
  List<CourseRemarkModel> getReviewsByRating(int rating) {
    return _courseReviews.where((review) => review.rating == rating).toList();
  }

  // Get rating distribution
  Map<int, int> get ratingDistribution {
    Map<int, int> distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

    for (var review in _courseReviews) {
      distribution[review.rating] = (distribution[review.rating] ?? 0) + 1;
    }

    return distribution;
  }

  // Search reviews by comment content
  List<CourseRemarkModel> searchReviews(String query) {
    if (query.isEmpty) return _courseReviews;

    return _courseReviews
        .where(
          (review) =>
              review.comment.toLowerCase().contains(query.toLowerCase()) ||
              review.user.name.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  // Sort reviews by date (newest first)
  List<CourseRemarkModel> get reviewsSortedByDate {
    List<CourseRemarkModel> sortedReviews = List.from(_courseReviews);
    sortedReviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedReviews;
  }

  // Sort reviews by rating (highest first)
  List<CourseRemarkModel> get reviewsSortedByRating {
    List<CourseRemarkModel> sortedReviews = List.from(_courseReviews);
    sortedReviews.sort((a, b) => b.rating.compareTo(a.rating));
    return sortedReviews;
  }
}
