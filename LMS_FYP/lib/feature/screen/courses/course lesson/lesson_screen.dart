// Create a new file: lessons_tab_widget.dart
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_fyp/feature/model/course/enrollment_model.dart';
import 'package:flutter_fyp/feature/screen/courses/lesson%20test%20question/lesson_test_question.dart';
import 'package:get/get.dart';

import '../../../../core/utility/dialog_utils.dart';
import '../../../controller/auth/login_controller.dart';
import '../../../controller/course/course_lesson_controller.dart';
import '../../../model/course/course_lesson_model.dart';
import '../../../model/course/course_model.dart';
import '../lesson test question/quiz.dart';
import 'add_edit_lesson.dart';

class LessonsTabWidget extends StatefulWidget {
  final CourseModel course;
  final EnrollmentModel? enrollment;
  final CourseLessonController courseLessonController;
  final LoginController loginController;
  final Function(String, double) onProgressUpdate;

  const LessonsTabWidget({
    Key? key,
    required this.course,
    this.enrollment,
    required this.courseLessonController,
    required this.loginController,
    required this.onProgressUpdate,
  }) : super(key: key);

  @override
  State<LessonsTabWidget> createState() => _LessonsTabWidgetState();
}

class _LessonsTabWidgetState extends State<LessonsTabWidget> {
  Map<String, double> lessonProgress = {};

  @override
  void initState() {
    super.initState();
    // Initialize with any existing progress data if needed
  }

  // Helper method to check if a lesson is accessible for students
  bool _isLessonAccessible(int lessonIndex, List<CourseLessonModel> lessons) {
    // Teachers can access all lessons
    if (widget.loginController.user.value!.role == 'teacher') {
      return true;
    }

    // First lesson is always accessible for students
    if (lessonIndex == 0) {
      return true;
    }

    // For subsequent lessons, check if previous lesson has 90% or above progress
    for (int i = 0; i < lessonIndex; i++) {
      final previousLessonId = lessons[i].id;
      final previousProgress = lessonProgress[previousLessonId] ?? 0.0;
      if (previousProgress < 90.0) {
        return false;
      }
    }

    return true;
  }

  // Helper method to show locked lesson dialog
  void _showLockedLessonDialog(
    int lessonIndex,
    List<CourseLessonModel> lessons,
  ) {
    String requiredLessonTitle = '';
    double requiredProgress = 0.0;

    // Find the first lesson that doesn't meet the 90% requirement
    for (int i = 0; i < lessonIndex; i++) {
      final previousLessonId = lessons[i].id;
      final previousProgress = lessonProgress[previousLessonId] ?? 0.0;
      if (previousProgress < 90.0) {
        requiredLessonTitle = lessons[i].title;
        requiredProgress = previousProgress;
        break;
      }
    }

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.lock, color: Color(0xFFF59E0B), size: 24),
            SizedBox(width: 8),
            Text(
              'Lesson Locked',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'To unlock this lesson, you need to complete the previous lesson with at least 90% score.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFFF59E0B).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Color(0xFFF59E0B).withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Required:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFF59E0B),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    requiredLessonTitle,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Current Score: ${requiredProgress.toInt()}% (Need: 90%)',
                    style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'OK',
              style: TextStyle(
                color: Color(0xFF6366F1),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
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

  Widget _buildEmptyLessonsState() {
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
                Icons.play_circle_outline,
                size: 40,
                color: Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No lessons yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Lessons will appear here once they are added to the course',
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonsList(List<CourseLessonModel> lessons) {
    return Container(
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.4),
      decoration: BoxDecoration(
        color: Colors.transparent,
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
        children: List.generate(
          lessons.length,
          (index) => _buildLessonItem(index, lessons[index], lessons),
        ),
      ),
    );
  }

  Widget _buildLessonItem(
    int index,
    CourseLessonModel lesson,
    List<CourseLessonModel> lessons,
  ) {
    final progressPercentage = lessonProgress[lesson.id] ?? 0.0;
    final isAccessible = _isLessonAccessible(index, lessons);
    final isStudent = widget.loginController.user.value!.role == 'student';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Overlay for locked lessons
          if (isStudent && !isAccessible)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(Icons.lock, size: 32, color: Color(0xFF9CA3AF)),
                ),
              ),
            ),

          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                // Check if lesson is accessible for students
                if (isStudent && !isAccessible) {
                  _showLockedLessonDialog(index, lessons);
                  return;
                }

                // Navigate to lesson detail or start lesson
                log('Tapped lesson: ${lesson.title}');
                if (widget.loginController.user.value!.role == 'teacher') {
                  Get.to(() => LessonTestQuestionScreen(), arguments: lesson);
                } else if (widget.loginController.user.value!.role ==
                    'student') {
                  // Get the result from quiz screen
                  final result = await Get.to(
                    () => const LessonTestQuizScreen(),
                    arguments: lesson,
                  );
                  if (result != null && result is double) {
                    setState(() {
                      lessonProgress[lesson.id] = result;
                    });
                    // Notify parent widget about progress update
                    widget.onProgressUpdate(lesson.id, result);
                  }
                } else {
                  Get.to(() => LessonTestQuestionScreen(), arguments: lesson);
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Opacity(
                opacity: (isStudent && !isAccessible) ? 0.5 : 1.0,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Lesson Number Badge
                          Container(
                            width: 25,
                            height: 25,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: (isStudent && !isAccessible)
                                    ? [Color(0xFF9CA3AF), Color(0xFF6B7280)]
                                    : [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                              ),
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: (isStudent && !isAccessible)
                                      ? Color(0xFF9CA3AF).withValues(alpha: 0.3)
                                      : Color(
                                          0xFF6366F1,
                                        ).withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: (isStudent && !isAccessible)
                                  ? Icon(
                                      Icons.lock,
                                      size: 14,
                                      color: Colors.white,
                                    )
                                  : Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          Expanded(
                            child: Text(
                              lesson.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111827),
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      Wrap(
                        alignment: WrapAlignment.start,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF10B981,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  size: 12,
                                  color: Color(0xFF10B981),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  lesson.formattedReadingDuration,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF10B981),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),

                          // PDF Indicator
                          if (lesson.hasPdf)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFF59E0B,
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.picture_as_pdf,
                                    size: 12,
                                    color: Color(0xFFF59E0B),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'PDF',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFF59E0B),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Quiz Badge
                          GestureDetector(
                            onTap: (isStudent && !isAccessible)
                                ? null
                                : () async {
                                    if (widget
                                            .loginController
                                            .user
                                            .value!
                                            .role ==
                                        'teacher') {
                                      Get.to(
                                        () => LessonTestQuestionScreen(),
                                        arguments: lesson,
                                      );
                                    } else if (widget
                                            .loginController
                                            .user
                                            .value!
                                            .role ==
                                        'student') {
                                      final result = await Get.to(
                                        () => const LessonTestQuizScreen(),
                                        arguments: lesson,
                                      );
                                      if (result != null && result is double) {
                                        setState(() {
                                          lessonProgress[lesson.id] = result;
                                        });
                                        widget.onProgressUpdate(
                                          lesson.id,
                                          result,
                                        );
                                      }
                                    }
                                  },
                            child: Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF8B5CF6,
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.quiz,
                                    size: 12,
                                    color: Color(0xFF8B5CF6),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${lesson.tests.length} Test',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF8B5CF6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Progress Badge for Students
                          if (widget.loginController.user.value!.role ==
                                  'student' &&
                              progressPercentage > 0)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: progressPercentage >= 90
                                    ? const Color(
                                        0xFF10B981,
                                      ).withValues(alpha: 0.1)
                                    : progressPercentage >= 70
                                    ? const Color(
                                        0xFFF59E0B,
                                      ).withValues(alpha: 0.1)
                                    : const Color(
                                        0xFFEF4444,
                                      ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    progressPercentage >= 90
                                        ? Icons.check_circle
                                        : progressPercentage >= 70
                                        ? Icons.hourglass_bottom
                                        : Icons.refresh,
                                    size: 12,
                                    color: progressPercentage >= 90
                                        ? const Color(0xFF10B981)
                                        : progressPercentage >= 70
                                        ? const Color(0xFFF59E0B)
                                        : const Color(0xFFEF4444),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${progressPercentage.toInt()}%',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: progressPercentage >= 90
                                          ? const Color(0xFF10B981)
                                          : progressPercentage >= 70
                                          ? const Color(0xFFF59E0B)
                                          : const Color(0xFFEF4444),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          const Spacer(),
                          if (widget.loginController.user.value!.role ==
                              'teacher')
                            IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: () async {
                                log('delete lesson: ${lesson.title}');
                                final shouldEdit =
                                    await DialogUtils.showConfirmDialog(
                                      title: 'Delete Lesson',
                                      message:
                                          'Are you sure you want to delete "${lesson.title}"? This action cannot be undone.',
                                      confirmText: 'Delete',
                                      cancelText: 'Cancel',
                                      icon: Icons.delete,
                                      isDangerous: true,
                                    );

                                if (shouldEdit) {
                                  await widget.courseLessonController
                                      .deleteCourseLesson(
                                        lesson.id,
                                        courseId: widget.course.id,
                                      );
                                }
                              },
                              icon: const Icon(
                                Icons.delete_forever,
                                color: Color(0xFF6366F1),
                                size: 18,
                              ),
                            ),
                          if (widget.loginController.user.value!.role ==
                              'teacher')
                            IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                Get.to(
                                  () => AddEditLessonScreen(
                                    course: widget.course,
                                    lesson: lesson,
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.edit,
                                color: Color(0xFF6366F1),
                                size: 18,
                              ),
                            ),
                        ],
                      ),

                      // Description
                      if (lesson.description.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          lesson.description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      // Keywords
                      if (lesson.hasKeywords) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: lesson.keywords.take(4).map((keyword) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF6366F1,
                                ).withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: const Color(
                                    0xFF6366F1,
                                  ).withValues(alpha: 0.2),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                keyword,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF6366F1),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        if (lesson.keywords.length > 4)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              '+${lesson.keywords.length - 4} more topics',
                              style: TextStyle(
                                fontSize: 11,
                                color: const Color(
                                  0xFF6B7280,
                                ).withValues(alpha: 0.8),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                      ],

                      // Progress Bar for Students
                      if (widget.loginController.user.value!.role ==
                          'student') ...[
                        const SizedBox(height: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Quiz Progress',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: const Color(0xFF6B7280),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  progressPercentage > 0
                                      ? '${progressPercentage.toInt()}%'
                                      : !isAccessible
                                      ? 'Locked'
                                      : 'Not started',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: !isAccessible
                                        ? const Color(0xFF9CA3AF)
                                        : progressPercentage >= 90
                                        ? const Color(0xFF10B981)
                                        : progressPercentage >= 70
                                        ? const Color(0xFFF59E0B)
                                        : progressPercentage > 0
                                        ? const Color(0xFFEF4444)
                                        : const Color(0xFF6B7280),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: !isAccessible
                                    ? 0.0
                                    : progressPercentage / 100,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: progressPercentage >= 90
                                          ? [
                                              const Color(0xFF10B981),
                                              const Color(0xFF047857),
                                            ]
                                          : progressPercentage >= 70
                                          ? [
                                              const Color(0xFFF59E0B),
                                              const Color(0xFFD97706),
                                            ]
                                          : [
                                              const Color(0xFFEF4444),
                                              const Color(0xFFDC2626),
                                            ],
                                    ),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        // Regular progress bar for teachers
                        const SizedBox(height: 12),
                        Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor:
                                0.0, // Set to 0.0 for new lessons, update based on progress
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Course Content'),
          const SizedBox(height: 16),
          Obx(() {
            if (widget.courseLessonController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            final lessons = widget.courseLessonController.lessons;

            if (lessons.isEmpty) {
              return _buildEmptyLessonsState();
            } else {
              return _buildLessonsList(lessons);
            }
          }),
        ],
      ),
    );
  }
}
