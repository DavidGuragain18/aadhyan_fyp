import 'package:flutter/material.dart';
import 'package:flutter_fyp/feature/model/course/enrollment_model.dart';
import 'package:get/get.dart';

import '../../../../core/helpers/format_data.dart';
import '../../../controller/auth/login_controller.dart';
import '../../../controller/course/course_review_controller.dart';
import '../../../model/course/course_model.dart';
import '../../../model/course/course_review_model.dart';

class ReviewsTabWidget extends StatelessWidget {
  final CourseModel course;
  final EnrollmentModel? enrollment;
  final CourseReviewController courseReviewController;
  final LoginController loginController;

  const ReviewsTabWidget({
    Key? key,
    required this.course,
    this.enrollment,
    required this.courseReviewController,
    required this.loginController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Student Reviews'),
          const SizedBox(height: 16),

          // Review Statistics
          _buildReviewStats(),
          const SizedBox(height: 20),

          // Reviews List
          Obx(() {
            if (courseReviewController.isLoading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF6366F1),
                    ),
                  ),
                ),
              );
            }

            final reviews = courseReviewController.courseReviews;

            if (reviews.isEmpty &&
                loginController.user.value!.role.toLowerCase() != 'student') {
              return _buildEmptyReviewsState();
            } else if (reviews.isEmpty) {
              return _buildEmptyReviewsStateForStudent();
            } else {
              return _buildReviewsList(reviews);
            }
          }),

          // Add Review Section (only for students)
          if (loginController.user.value!.role.toLowerCase() == 'student' &&
              enrollment!.status == 'approved')
            _buildAddReviewSection(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF111827),
      ),
    );
  }

  Widget _buildReviewStats() {
    return Obx(() {
      final reviews = courseReviewController.courseReviews;

      if (reviews.isEmpty) {
        return const SizedBox.shrink();
      }

      // Calculate average rating
      final averageRating =
          reviews.fold<double>(0.0, (sum, review) => sum + review.rating) /
          reviews.length;

      // Calculate rating distribution
      final ratingCounts = <int, int>{};
      for (int i = 1; i <= 5; i++) {
        ratingCounts[i] = reviews.where((r) => r.rating == i).length;
      }

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Overall Rating
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Text(
                        averageRating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return Icon(
                            index < averageRating.floor()
                                ? Icons.star
                                : index < averageRating
                                ? Icons.star_half
                                : Icons.star_border,
                            color: const Color(0xFFF59E0B),
                            size: 20,
                          );
                        }),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${reviews.length} review${reviews.length != 1 ? 's' : ''}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),

                // Rating Distribution
                Expanded(
                  flex: 3,
                  child: Column(
                    children: List.generate(5, (index) {
                      final starCount = 5 - index;
                      final count = ratingCounts[starCount] ?? 0;
                      final percentage = reviews.isNotEmpty
                          ? count / reviews.length
                          : 0.0;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Text(
                              '$starCount',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.star,
                              size: 12,
                              color: Color(0xFFF59E0B),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: percentage,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF59E0B),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$count',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildReviewsList(List<CourseRemarkModel> reviews) {
    return Column(
      children: reviews.map((review) => _buildReviewItem(review)).toList(),
    );
  }

  Widget _buildReviewItem(CourseRemarkModel review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with user info and rating
          Row(
            children: [
              // User Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Text(
                    review.user.name.isNotEmpty
                        ? review.user.name[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.user.name.isNotEmpty
                          ? review.user.name
                          : 'Anonymous User',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        // Star Rating
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < review.rating
                                  ? Icons.star
                                  : Icons.star_border,
                              color: const Color(0xFFF59E0B),
                              size: 16,
                            );
                          }),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formatDate(review.createdAt),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Review Comment
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Text(
                review.comment,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF374151),
                  height: 1.5,
                ),
              ),
            ),
          ],

          // Updated timestamp (if different from created)
          if (review.updatedAt.isAfter(review.createdAt)) ...[
            const SizedBox(height: 12),
            Text(
              'Updated ${formatDate(review.updatedAt)}',
              style: TextStyle(
                fontSize: 11,
                color: const Color(0xFF6B7280).withValues(alpha: 0.8),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyReviewsState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.star_outline,
                size: 40,
                color: Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No reviews yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Be the first to leave a review for this course',
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyReviewsStateForStudent() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.rate_review,
                size: 40,
                color: Color(0xFF6366F1),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No reviews yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Be the first to share your experience with this course!',
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddReviewSection() {
    return Obx(() {
      final currentUserId = loginController.user.value!.id;
      final userReviews = courseReviewController.courseReviews
          .where((review) => review.user.id == currentUserId)
          .toList();
      final userReview = userReviews.isNotEmpty ? userReviews.first : null;
      final isEditing = courseReviewController.selectedReview != null;

      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF6366F1).withValues(alpha: 0.2),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isEditing ? Icons.edit : Icons.add_comment,
                  color: const Color(0xFF6366F1),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  userReview != null && !isEditing
                      ? 'Your Review'
                      : isEditing
                      ? 'Edit Your Review'
                      : 'Add Your Review',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),

            if (userReview != null && !isEditing) ...[
              const SizedBox(height: 16),
              _buildUserReviewDisplay(userReview),
            ] else ...[
              const SizedBox(height: 20),
              _buildReviewForm(),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildUserReviewDisplay(CourseRemarkModel review) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF6366F1).withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < review.rating ? Icons.star : Icons.star_border,
                    color: const Color(0xFFF59E0B),
                    size: 20,
                  );
                }),
              ),

              TextButton.icon(
                onPressed: () {
                  courseReviewController.setSelectedReview(review);
                },
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Edit'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF6366F1),
                ),
              ),

              TextButton.icon(
                onPressed: () => _showDeleteReviewDialog(review),
                icon: const Icon(Icons.delete, size: 16),
                label: const Text('Delete'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.comment,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF374151),
                height: 1.5,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'Posted on ${formatDate(review.createdAt)}',
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rating',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => Row(
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () {
                  courseReviewController.selectedRating.value = index + 1;
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    index < courseReviewController.selectedRating.value
                        ? Icons.star
                        : Icons.star_border,
                    color: const Color(0xFFF59E0B),
                    size: 32,
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Comment',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: courseReviewController.commentController,
          maxLines: 4,
          scrollPadding: const EdgeInsets.only(bottom: 200),
          decoration: InputDecoration(
            hintText: 'Share your thoughts about this course...',
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            if (courseReviewController.selectedReview != null) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    courseReviewController.setSelectedReview(null);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF6B7280),
                    side: const BorderSide(color: Color(0xFFD1D5DB)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Obx(
                () => ElevatedButton(
                  onPressed:
                      courseReviewController.isCreating ||
                          courseReviewController.isUpdating
                      ? null
                      : () => _submitReview(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child:
                      courseReviewController.isCreating ||
                          courseReviewController.isUpdating
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          courseReviewController.selectedReview != null
                              ? 'Update Review'
                              : 'Submit Review',
                        ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _submitReview() async {
    final selectedReview = courseReviewController.selectedReview;
    bool success = false;

    if (selectedReview != null) {
      // Update existing review
      success = await courseReviewController.updateReview(
        selectedReview.id.toString(),
        course.id.toString(),
        loginController.user.value!.id.toString(),
        true,
      );
    } else {
      // Create new review
      success = await courseReviewController.createReview(course.id);
    }

    if (success) {
      // Refresh the reviews list
      await courseReviewController.getReviewsForCourse(course.id);
    }
  }

  void _showDeleteReviewDialog(CourseRemarkModel review) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Review'),
        content: const Text(
          'Are you sure you want to delete your review? This action cannot be undone.',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              final success = await courseReviewController.deleteReview(
                review.id.toString(),
              );
              if (success) {
                await courseReviewController.getReviewsForCourse(course.id);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
