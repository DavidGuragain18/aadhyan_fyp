import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_fyp/core/theme/app_colors.dart';
import 'package:get/get.dart';
import '../../../core/constant/api_url.dart';
import '../../../core/helpers/status_color.dart';
import '../../../core/utility/dialog_utils.dart';
import '../../controller/course/course_controller.dart';
import '../../controller/auth/login_controller.dart';
import '../../controller/course/enrollment_controller.dart';
import '../../model/course/course_model.dart';
import 'add_edit_course.dart';
import 'view_course.dart';

class CourseScreen extends StatefulWidget {
  const CourseScreen({Key? key}) : super(key: key);

  @override
  State<CourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  late final CourseController courseController;
  late final LoginController loginController;
  late final EnrollmentController enrollmentController;
  String? selectedStatus;

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    try {
      courseController = Get.find<CourseController>();
    } catch (e) {
      courseController = Get.put(CourseController());
    }

    try {
      loginController = Get.find<LoginController>();
    } catch (e) {
      loginController = Get.put(LoginController());
    }
    if (loginController.user.value!.role.toLowerCase() == 'student') {
      enrollmentController = Get.put(EnrollmentController());
      enrollmentController.getMyEnrollments();
    }
    // Fetch courses when the screen is initialized
    courseController.fetchCourses();
  }

  // Helper method to check if user is teacher
  bool get isTeacher {
    final user = loginController.user.value;
    return user?.role.toLowerCase() == 'teacher';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isTeacher ? 'My Courses' : 'Available Courses'),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8FAFF), Color(0xFFFFFFFF), Color(0xFFF3E8FF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => courseController.refreshCourses(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [_buildContent()],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return GetX<CourseController>(
      builder: (controller) {
        // Handle loading state
        if (controller.isLoading) {
          return _buildLoadingState();
        }

        // Handle error state
        if (controller.hasError) {
          return _buildErrorState(controller);
        }

        // Handle empty state
        if (controller.isEmpty) {
          return _buildEmptyState();
        }

        // Show courses and quick actions
        return Column(
          children: [
            // Only show stats for teachers
            if (isTeacher) ...[_buildStatsCards(), const SizedBox(height: 32)],
            _buildSectionHeader(),
            const SizedBox(height: 16),
            _buildCoursesGrid(),
            const SizedBox(height: 32),
            // Only show quick actions for teachers
            if (isTeacher) _buildQuickActions(),
          ],
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Column(
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
            ),
            SizedBox(height: 16),
            Text(
              'Loading courses...',
              style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(CourseController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(48),
              ),
              child: const Icon(
                Icons.error_outline,
                size: 48,
                color: Color(0xFFDC2626),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage,
              style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                controller.clearError();
                controller.fetchCourses();
              },
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                elevation: 3,
                shadowColor: const Color(0xFF6366F1).withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gradient Icon Badge
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF9333EA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.school, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isTeacher ? 'My Courses' : 'Explore Courses',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isTeacher
                      ? 'Track, manage and update your course list.'
                      : 'Find the right course to boost your knowledge.',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 12),

                // Status filter (for students only)
                if (!isTeacher)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedStatus,
                          hint: const Text('Filter by status'),
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('All Status'),
                            ),
                            const DropdownMenuItem<String>(
                              value: 'approved',
                              child: Text('Approved'),
                            ),
                            const DropdownMenuItem<String>(
                              value: 'pending',
                              child: Text('Pending'),
                            ),
                            const DropdownMenuItem<String>(
                              value: 'rejected',
                              child: Text('Rejected'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedStatus = value;
                              // Trigger API call or state update here
                            });
                          },
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF111827),
                          ),
                          icon: const Icon(Icons.arrow_drop_down),
                          dropdownColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Add Course Button (for teachers only)
          if (isTeacher)
            ElevatedButton.icon(
              onPressed: () {
                Get.to(() => AddEditCourseScreen(isEditMode: false));
              },
              icon: const Icon(Icons.add, size: 20),
              label: const Text('New Course'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return GetX<CourseController>(
      builder: (controller) {
        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Courses',
                '${controller.totalCourses}',
                Icons.school,
                const Color(0xFF3B82F6),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Total Lessons',
                '${controller.totalLessons}',
                Icons.play_circle_outline,
                const Color(0xFF10B981),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Active Course',
                '${controller.activeCourses}',
                Icons.trending_up,
                const Color(0xFF8B5CF6),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isTeacher ? 'Your Courses' : 'Available Courses',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isTeacher
              ? 'Create and manage your educational content'
              : 'Browse and enroll in courses',
          style: const TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(48),
              ),
              child: const Icon(
                Icons.school,
                size: 48,
                color: Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isTeacher ? 'No courses yet' : 'No courses available',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isTeacher
                  ? 'Get started by creating your first course'
                  : 'Check back later for new courses',
              style: const TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Only show create course button for teachers
            if (isTeacher)
              ElevatedButton.icon(
                onPressed: () {
                  Get.to(() => AddEditCourseScreen(isEditMode: false));
                },
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Create Your First Course'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  elevation: 3,
                  shadowColor: const Color(0xFF6366F1).withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoursesGrid() {
    return GetX<CourseController>(
      builder: (controller) {
        // Filter courses based on selected status for students
        final filteredCourses = isTeacher || selectedStatus == null
            ? controller.courses
            : controller.courses.where((course) {
                final enrollment = enrollmentController.getEnrollmentForCourse(
                  course.id,
                );
                return enrollment != null &&
                    enrollment.status.toLowerCase() == selectedStatus;
              }).toList();

        if (filteredCourses.isEmpty && !isTeacher && selectedStatus != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(48),
                    ),
                    child: const Icon(
                      Icons.school,
                      size: 48,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'No courses to display',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No courses found with "$selectedStatus" status',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6B7280),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 16,
            childAspectRatio: 0.68,
          ),
          itemCount: filteredCourses.length,
          itemBuilder: (context, index) {
            return _buildCourseCard(filteredCourses[index]);
          },
        );
      },
    );
  }

  Widget _buildCourseCard(CourseModel course) {
    final enrollment = !isTeacher
        ? enrollmentController.getEnrollmentForCourse(course.id)
        : null;
    return GestureDetector(
      onTap: () {
        if (isTeacher) {
          Get.to(() => ViewCourseScreen(course: course));
        } else if (enrollment?.status == "approved") {
          Get.to(
            () => ViewCourseScreen(
              course: course,
              enrollment: enrollment,
              // enroll: enrollment,
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: Image.network(
                        '$ASSETS_URL${course.coverImage}',
                        fit: BoxFit.cover,
                        // errorBuilder: (context, error, stackTrace) {
                        //   return Image.asset(
                        //     'assets/logo.png',
                        //     fit: BoxFit.cover,
                        //   );
                        // },
                      ),
                    ),
                  ),
                  // Add lock icon for non-teachers when status is not approved
                  if (!isTeacher && enrollment?.status != 'approved')
                    Positioned(
                      top: 25,
                      left: 50,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock,
                          color: Colors.white30,
                          size: 50,
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 0,
                    left: 8,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.play_circle_outline,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${course.lessonCount} Lessons',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        // Only show edit button for teachers
                        if (isTeacher) ...[
                          const SizedBox(width: 34),
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 18,
                            ),
                            onPressed: () {
                              Get.to(
                                () => AddEditCourseScreen(
                                  course: course,
                                  isEditMode: true,
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Only show delete button for teachers
                  if (isTeacher)
                    Positioned(
                      top: 8,
                      right: 0,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.white,
                              size: 18,
                            ),
                            onPressed: () async {
                              final shouldDelete =
                                  await DialogUtils.showConfirmDialog(
                                    title: 'Delete Course',
                                    message:
                                        'Are you sure you want to delete "${course.title}"? This action cannot be undone.',
                                    confirmText: 'Delete',
                                    cancelText: 'Cancel',
                                    icon: Icons.delete,
                                    isDangerous: true,
                                  );

                              if (shouldDelete) {
                                final isDeleted = await courseController
                                    .deleteCourse(course.id);
                                log(
                                  'Course deleted: ${course.title}, Success: $isDeleted',
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      course.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      course.description,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF6B7280),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 12,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '0 Students',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!isTeacher && enrollment != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: getStatusBackgroundColor(
                                enrollment.status,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              enrollment.status,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                                color: getStatusTextColor(enrollment.status),
                              ),
                            ),
                          ),
                        if (!isTeacher && enrollment == null)
                          GestureDetector(
                            onTap: () {
                              enrollmentController.createEnrollment(
                                courseId: course.id,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                "Enrol Now",
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Center(
      child: Column(
        children: [
          const Text(
            'Ready to expand your catalog ?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              Get.to(() => AddEditCourseScreen(isEditMode: false));
            },
            icon: const Icon(Icons.add, size: 20),
            label: const Text('Add Another Course'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF6366F1),
              side: const BorderSide(color: Color(0xFF6366F1), width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
