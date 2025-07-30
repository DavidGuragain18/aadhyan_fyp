import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/auth/login_controller.dart';
import '../../../controller/course/course_review_controller.dart';
import '../../../model/course/course_review_model.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({Key? key}) : super(key: key);

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final CourseReviewController reviewController =
      Get.find<CourseReviewController>();
  final LoginController loginController = Get.find<LoginController>();

  @override
  void initState() {
    super.initState();
    // Fetch all reviews when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      reviewController.getAllReviews();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Reviews'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Obx(() {
        if (reviewController.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (reviewController.allReviews.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.rate_review_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No reviews found',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        // Group reviews by course
        final Map<String, List<CourseRemarkModel>> courseReviewsMap = {};
        for (var review in reviewController.allReviews) {
          final courseId = review.course.id;
          if (!courseReviewsMap.containsKey(courseId)) {
            courseReviewsMap[courseId] = [];
          }
          courseReviewsMap[courseId]!.add(review);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: courseReviewsMap.keys.length,
          itemBuilder: (context, index) {
            final courseId = courseReviewsMap.keys.elementAt(index);
            final courseReviews = courseReviewsMap[courseId]!;
            final course = courseReviews.first.course;

            // Calculate average rating for this course
            final averageRating =
                courseReviews.fold<double>(
                  0.0,
                  (sum, review) => sum + review.rating,
                ) /
                courseReviews.length;

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _navigateToCourseReviews(courseId, course.title),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              course.title.isNotEmpty
                                  ? course.title
                                  : 'Untitled Course',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Text(
                              '${courseReviews.length} review${courseReviews.length > 1 ? 's' : ''}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Row(
                            children: List.generate(5, (starIndex) {
                              return Icon(
                                starIndex < averageRating.round()
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 20,
                              );
                            }),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${averageRating.toStringAsFixed(1)} / 5.0',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getPreviewText(courseReviews),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  String _getPreviewText(List<CourseRemarkModel> reviews) {
    if (reviews.isEmpty) return 'No reviews available';

    // Show the most recent review as preview
    final latestReview = reviews.reduce(
      (a, b) => a.createdAt.isAfter(b.createdAt) ? a : b,
    );

    return 'Latest: "${latestReview.comment}" - ${latestReview.user.name}';
  }

  void _navigateToCourseReviews(String courseId, String courseTitle) {
    Get.to(
      () => CourseReviewDetailScreen(
        courseId: courseId,
        courseTitle: courseTitle,
      ),
      transition: Transition.cupertino,
    );
  }
}

class CourseReviewDetailScreen extends StatefulWidget {
  final String courseId;
  final String courseTitle;

  const CourseReviewDetailScreen({
    Key? key,
    required this.courseId,
    required this.courseTitle,
  }) : super(key: key);

  @override
  State<CourseReviewDetailScreen> createState() =>
      _CourseReviewDetailScreenState();
}

class _CourseReviewDetailScreenState extends State<CourseReviewDetailScreen> {
  final CourseReviewController reviewController =
      Get.find<CourseReviewController>();
  final LoginController loginController = Get.find<LoginController>();

  @override
  void initState() {
    super.initState();
    // Fetch reviews for this specific course
    WidgetsBinding.instance.addPostFrameCallback((_) {
      reviewController.getReviewsForCourse(widget.courseId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.courseTitle.isNotEmpty ? widget.courseTitle : 'Course Reviews',
          style: const TextStyle(fontSize: 18),
        ),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Obx(() {
        if (reviewController.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Filter reviews based on user role
        List<CourseRemarkModel> displayReviews;
        final currentUser = loginController.user.value;

        if (currentUser == null) {
          return const Center(
            child: Text(
              'Please login to view reviews',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        if (currentUser.role.toLowerCase() == 'teacher') {
          // Teachers see all reviews for the course
          displayReviews = reviewController.courseReviews;
        } else {
          // Students see only their own reviews for the course
          displayReviews = reviewController.courseReviews
              .where((review) => review.user.id == currentUser.id)
              .toList();
        }

        if (displayReviews.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.rate_review_outlined,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  currentUser.role.toLowerCase() == 'teacher'
                      ? 'No reviews found for this course'
                      : 'You haven\'t reviewed this course yet',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Course statistics (only for teachers)
            if (currentUser.role.toLowerCase() == 'teacher')
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          '${displayReviews.length}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'Total Reviews',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          reviewController.averageRating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'Average Rating',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            // Reviews list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: displayReviews.length,
                itemBuilder: (context, index) {
                  final review = displayReviews[index];
                  return _buildReviewCard(
                    review,
                    currentUser.role.toLowerCase() == 'teacher',
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildReviewCard(CourseRemarkModel review, bool isTeacherView) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    review.user.name.isNotEmpty
                        ? review.user.name[0].toUpperCase()
                        : 'U',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.user.name.isNotEmpty
                            ? review.user.name
                            : 'Anonymous',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      if (isTeacherView)
                        Text(
                          review.user.email,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(5, (starIndex) {
                        return Icon(
                          starIndex < review.rating
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 18,
                        );
                      }),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(review.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              review.comment,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
            if (review.createdAt != review.updatedAt) ...[
              const SizedBox(height: 8),
              Text(
                'Edited ${_formatDate(review.updatedAt)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return '1 day ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
