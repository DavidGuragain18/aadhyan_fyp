import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/utility/dialog_utils.dart';
import '../../controller/course/enrollment_controller.dart';
import '../../model/course/course_model.dart';
import '../../model/course/enrollment_model.dart';

class ManageEnrollmentCourseScreen extends StatefulWidget {
  final CourseModel course;

  const ManageEnrollmentCourseScreen({Key? key, required this.course})
    : super(key: key);

  @override
  State<ManageEnrollmentCourseScreen> createState() =>
      _ManageEnrollmentCourseScreenState();
}

class _ManageEnrollmentCourseScreenState
    extends State<ManageEnrollmentCourseScreen>
    with TickerProviderStateMixin {
  final EnrollmentController enrollmentController =
      Get.find<EnrollmentController>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
    ); // Changed from 3 to 4
    _loadEnrollments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadEnrollments() {
    enrollmentController.getCourseEnrollments(
      courseId: widget.course.id,
      showSnackbar: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildCourseHeader(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllEnrollments(),
                _buildPendingEnrollments(),
                _buildApprovedEnrollments(),
                _buildRejectedEnrollments(), // Added rejected tab
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: const Color(0xFF1E293B),
      foregroundColor: Colors.white,
      title: const Text(
        'Manage Enrollments',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
      actions: [
        IconButton(
          onPressed: _loadEnrollments,
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Refresh',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildCourseHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E293B), Color(0xFF334155)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.course.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Course Management',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Obx(() {
              final enrollments = enrollmentController.courseEnrollments;
              final pendingCount = enrollments
                  .where((e) => e.status == 'pending')
                  .length;
              final approvedCount = enrollments
                  .where((e) => e.status == 'approved')
                  .length;
              final rejectedCount = enrollments
                  .where((e) => e.status == 'rejected')
                  .length; // Added rejected count

              return Column(
                children: [
                  Row(
                    children: [
                      _buildStatCard(
                        'Total',
                        enrollments.length.toString(),
                        Icons.people_rounded,
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        'Pending',
                        pendingCount.toString(),
                        Icons.pending_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildStatCard(
                        'Approved',
                        approvedCount.toString(),
                        Icons.check_circle_rounded,
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        'Rejected',
                        rejectedCount.toString(),
                        Icons.cancel_rounded,
                      ), // Added rejected stat card
                    ],
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF1E293B),
        unselectedLabelColor: Colors.grey,
        indicatorColor: const Color(0xFF3B82F6),
        indicatorWeight: 3,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        isScrollable: true, // Added to handle 4 tabs better on smaller screens
        tabs: const [
          Tab(text: 'All Students'),
          Tab(text: 'Pending'),
          Tab(text: 'Approved'),
          Tab(text: 'Rejected'), // Added rejected tab
        ],
      ),
    );
  }

  Widget _buildAllEnrollments() {
    return Obx(() {
      if (enrollmentController.isLoadingCourseEnrollments) {
        return _buildLoadingState();
      }

      final enrollments = enrollmentController.courseEnrollments;
      if (enrollments.isEmpty) {
        return _buildEmptyState('No enrollments found for this course');
      }

      return _buildEnrollmentList(enrollments);
    });
  }

  Widget _buildPendingEnrollments() {
    return Obx(() {
      if (enrollmentController.isLoadingCourseEnrollments) {
        return _buildLoadingState();
      }

      final pendingEnrollments = enrollmentController.courseEnrollments
          .where((enrollment) => enrollment.status == 'pending')
          .toList();

      if (pendingEnrollments.isEmpty) {
        return _buildEmptyState('No pending enrollments');
      }

      return _buildEnrollmentList(pendingEnrollments);
    });
  }

  Widget _buildApprovedEnrollments() {
    return Obx(() {
      if (enrollmentController.isLoadingCourseEnrollments) {
        return _buildLoadingState();
      }

      final approvedEnrollments = enrollmentController.courseEnrollments
          .where((enrollment) => enrollment.status == 'approved')
          .toList();

      if (approvedEnrollments.isEmpty) {
        return _buildEmptyState('No approved enrollments');
      }

      return _buildEnrollmentList(approvedEnrollments);
    });
  }

  // Added rejected enrollments tab
  Widget _buildRejectedEnrollments() {
    return Obx(() {
      if (enrollmentController.isLoadingCourseEnrollments) {
        return _buildLoadingState();
      }

      final rejectedEnrollments = enrollmentController.courseEnrollments
          .where((enrollment) => enrollment.status == 'rejected')
          .toList();

      if (rejectedEnrollments.isEmpty) {
        return _buildEmptyState('No rejected enrollments');
      }

      return _buildEnrollmentList(rejectedEnrollments);
    });
  }

  Widget _buildEnrollmentList(List<EnrollmentModel> enrollments) {
    return RefreshIndicator(
      onRefresh: () async => _loadEnrollments(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: enrollments.length,
        itemBuilder: (context, index) {
          final enrollment = enrollments[index];
          return _buildEnrollmentCard(enrollment, index);
        },
      ),
    );
  }

  Widget _buildEnrollmentCard(EnrollmentModel enrollment, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildStudentAvatar(enrollment.studentId.name, index),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        enrollment.studentId.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        enrollment.studentId.email,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildStatusChip(enrollment.status),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.schedule_rounded,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(enrollment.enrolledAt),

                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final confirmed = await DialogUtils.showConfirmDialog(
                          title: 'Delete Enrollment',
                          message:
                              'Are you sure you want to delete ${enrollment.studentId.name}\'s enrollment?',
                          confirmText: 'Delete',
                          cancelText: 'Cancel',
                          isDangerous: true,
                          icon: Icons.delete_forever,
                        );

                        if (confirmed) {
                          final success = await enrollmentController
                              .deleteEnrollment(enrollmentId: enrollment.id);

                          if (success) {
                            _loadEnrollments(); // Refresh the data
                          }
                        }
                      },
                      child: Icon(Icons.delete_forever, color: Colors.red),
                    ),
                    _buildActionButton(enrollment),
                  ],
                ),
              ],
            ),
          ),
          if (enrollment.completedChapters.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.book_rounded, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Completed ${enrollment.completedChapters.length} chapters',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStudentAvatar(String name, int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: colors[index % colors.length].withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'U',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colors[index % colors.length],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'approved':
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green[700]!;
        icon = Icons.check_circle_rounded;
        break;
      case 'rejected':
        backgroundColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red[700]!;
        icon = Icons.cancel_rounded;
        break;
      default:
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange[700]!;
        icon = Icons.pending_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            status.capitalize ?? status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(EnrollmentModel enrollment) {
    if (enrollment.status == 'pending') {
      return PopupMenuButton<String>(
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.more_vert_rounded,
            color: Color(0xFF3B82F6),
            size: 18,
          ),
        ),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'approve',
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 18,
                  color: Colors.green[600],
                ),
                const SizedBox(width: 8),
                const Text('Approve'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'reject',
            child: Row(
              children: [
                Icon(Icons.cancel_rounded, size: 18, color: Colors.red[600]),
                const SizedBox(width: 8),
                const Text('Reject'),
              ],
            ),
          ),
        ],
        onSelected: (value) => _handleEnrollmentAction(enrollment, value),
      );
    }

    // Enhanced action button for rejected enrollments
    if (enrollment.status == 'rejected') {
      return PopupMenuButton<String>(
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.more_vert_rounded,
            color: Colors.red,
            size: 18,
          ),
        ),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'approve',
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 18,
                  color: Colors.green[600],
                ),
                const SizedBox(width: 8),
                const Text('Approve'),
              ],
            ),
          ),
        ],
        onSelected: (value) => _handleEnrollmentAction(enrollment, value),
      );
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        enrollment.status == 'approved'
            ? Icons.check_rounded
            : Icons.close_rounded,
        color: enrollment.status == 'approved' ? Colors.green : Colors.red,
        size: 18,
      ),
    );
  }

  void _handleEnrollmentAction(
    EnrollmentModel enrollment,
    String action,
  ) async {
    final EnrollmentStatus status = action == 'approve'
        ? EnrollmentStatus.approved
        : EnrollmentStatus.rejected;

    final confirmed = await DialogUtils.showConfirmDialog(
      title: '${action.capitalize} Enrollment',
      message:
          'Are you sure you want to ${action} ${enrollment.studentId.name}\'s enrollment?',
      confirmText: action.capitalize ?? action,
      cancelText: 'Cancel',
      icon: action == 'approve' ? Icons.check_circle : Icons.cancel,
    );

    if (confirmed) {
      final success = await enrollmentController.updateEnrollmentStatus(
        enrollmentId: enrollment.id,
        status: status,
      );

      if (success) {
        _loadEnrollments(); // Refresh the data
      }
    }
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
          ),
          SizedBox(height: 16),
          Text(
            'Loading enrollments...',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.people_outline_rounded,
              size: 48,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Students will appear here once they enroll',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }
}
