import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_fyp/feature/model/course/enrollment_model.dart';
import 'package:flutter_fyp/feature/model/course/extension.dart';
import 'package:get/get.dart';
import '../../../core/helpers/format_data.dart';
import '../../controller/auth/login_controller.dart';
import '../../controller/chat/group_chat_controller.dart';
import '../../controller/course/course_lesson_controller.dart';
import '../../controller/course/course_review_controller.dart';
import '../../controller/course/enrollment_controller.dart';
import '../../model/course/course_lesson_model.dart';
import '../../model/course/course_model.dart';
import '../../model/group chat/group_chat_model.dart';
import 'course lesson/add_edit_lesson.dart';
import 'course lesson/lesson_screen.dart';
import 'review/review_tab.dart';

class ViewCourseScreen extends StatefulWidget {
  final CourseModel course;
  final EnrollmentModel? enrollment;
  const ViewCourseScreen({Key? key, required this.course, this.enrollment})
    : super(key: key);

  @override
  State<ViewCourseScreen> createState() => _ViewCourseScreenState();
}

class _ViewCourseScreenState extends State<ViewCourseScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final CourseLessonController courseLessonController = Get.put(
    CourseLessonController(),
  );
  final CourseReviewController courseReviewController = Get.put(
    CourseReviewController(),
  );

    final EnrollmentController enrollmentController = Get.put(
    EnrollmentController(),
  );

  final GroupChatController groupChatController = GroupChatController();

  final LoginController loginController = Get.find<LoginController>();

  final RxInt _currentTabIndex = 0.obs;

  String enrollStatus = '';

  Map<String, double> lessonProgress = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      _currentTabIndex.value = _tabController.index;
    });

    // Handle null enrollment safely
    enrollStatus = widget.enrollment?.status ?? 'not_enrolled';
    log(enrollStatus);

    courseLessonController.setCurrentCourseId(widget.course.id);
    courseLessonController.fetchCourseLessons();

    courseReviewController.getReviewsForCourse(widget.course.id);

    groupChatController.setCourse(widget.course.id);
    groupChatController.setCurrentUser(loginController.user.value);
    groupChatController.setCurrentCourse(widget.course);
  }

  void _onProgressUpdate(String lessonId, double progress) {
    setState(() {
      lessonProgress[lessonId] = progress;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (courseLessonController.isLoading.value) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFF),
          body: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
            ),
          ),
        );
      }

      return Scaffold(
        body: CustomScrollView(
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildCourseHeader(),
                  _buildTabSection(),
                  _buildTabContent(),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: _buildFloatingActionButton(widget.course),
      );
    });
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: const Color(0xFF6366F1),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF6366F1),
                    Color(0xFF8B5CF6),
                    Color(0xFF06B6D4),
                  ],
                ),
              ),
              child: widget.course.coverImage != null
                  ? Image.network(
                      widget.course.coverImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          "assets/logo.png",
                          fit: BoxFit.cover,
                        );
                      },
                    )
                  : Image.asset("assets/logo.png", fit: BoxFit.cover),
            ),
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
            // Course Title at Bottom
            Positioned(
              bottom: 60,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Obx(() {
                      return Text(
                        '${courseLessonController.lessons.length} Lessons',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.course.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 2),
                          blurRadius: 4,
                          color: Colors.black45,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              // Implement share functionality
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCourseHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.course.description,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B7280),
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildStatsRow(),
          const SizedBox(height: 20),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Obx(() {
          return _buildStatItem(
            icon: Icons.play_circle_outline,
            label: 'Lessons',
            value: '${courseLessonController.lessons.length}',
            color: const Color(0xFF10B981),
          );
        }),

        _buildStatItem(
          icon: Icons.people_outline,
          label: 'Students',
          value: EnrollmentModel.countApprovedEnrollments(enrollmentController.courseEnrollments, widget.course.id).toString(),
          color: const Color(0xFF3B82F6),
        ),
        _buildStatItem(
          icon: Icons.star_outline,
          label: 'Rating',
          value: courseReviewController.courseReviews.ratingAverage
              .toStringAsFixed(2),

          color: const Color(0xFFF59E0B),
        ),
        _buildStatItem(
          icon: Icons.access_time,
          label: 'Duration',
          value: CourseLessonModel.formattedTotalReadingDuration(
            courseLessonController.lessons,
          ),
          color: const Color(0xFF8B5CF6),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: () {
              // Start course functionality
            },
            icon: const Icon(Icons.play_arrow, size: 24),
            label: const Text('Start Learning'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              elevation: 3,
              shadowColor: const Color(0xFF6366F1).withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              // Bookmark functionality
            },
            icon: const Icon(Icons.bookmark_border, size: 20),
            label: const Text('Save'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF6366F1),
              side: const BorderSide(color: Color(0xFF6366F1), width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabSection() {
    return Container(
      color: Colors.white,
      child: TabBar(
        isScrollable: true,
        controller: _tabController,
        labelColor: const Color(0xFF6366F1),
        unselectedLabelColor: const Color(0xFF6B7280),
        indicatorColor: const Color(0xFF6366F1),
        indicatorWeight: 3,
        labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Lessons'),
          Tab(text: 'Reviews'),
          Tab(text: 'Discussion'),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return Container(
      height: 700,
      color: const Color(0xFFF8FAFF),
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildLessonsTab(),
          _buildReviewsTab(),
          _buildGroupChatTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('About This Course'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.course.description,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF374151),
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 20),
                _buildCourseDetails(),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildWhatYouLearn(),
        ],
      ),
    );
  }

  Widget _buildCourseDetails() {
    return Column(
      children: [
        const Divider(height: 24),

        _buildDetailRow('Course ID', widget.course.id),
        const Divider(height: 24),
        // _buildDetailRow('Total Lessons', '${widget.course.lessons.length}'),
        Obx(() {
          return _buildDetailRow(
            'Total Lessons',
            '${courseLessonController.lessons.length}',
          );
        }),

        const Divider(height: 24),
        _buildDetailRow('Version', 'v${widget.course.version}'),
        const Divider(height: 24),
        _buildDetailRow('Status', 'Active'),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF111827),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildWhatYouLearn() {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What you\'ll learn',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(4, (index) {
            final learningPoints = [
              'Master the fundamentals of ${widget.course.title}',
              'Build practical projects and real-world applications',
              'Understand advanced concepts and best practices',
              'Get ready for professional development opportunities',
            ];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 14,
                      color: Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      learningPoints[index],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF374151),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLessonsTab() {
    return LessonsTabWidget(
      course: widget.course,
      enrollment: widget.enrollment,
      courseLessonController: courseLessonController,
      loginController: loginController,
      onProgressUpdate: _onProgressUpdate,
    );
  }

  Widget _buildReviewsTab() {
    return ReviewsTabWidget(
      course: widget.course,
      enrollment: widget.enrollment,
      courseReviewController: courseReviewController,
      loginController: loginController,
    );
  }

  Widget _buildGroupChatTab() {
    if (enrollStatus == 'pending' ||
        enrollStatus == 'rejected' ||
        enrollStatus == 'cancelled') {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'You cannot access the discussion until your enrollment is approved.',
            style: const TextStyle(fontSize: 16, color: Color(0xFFEF4444)),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return Column(
      children: [
        // Chat Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: const Color(0xFFF3F4F6), width: 1),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.group, color: const Color(0xFF6366F1), size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Course Discussion',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    Obx(
                      () => Text(
                        '${groupChatController.messageCount} messages',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => groupChatController.refreshMessages(),
                icon: Icon(Icons.refresh, color: const Color(0xFF6366F1)),
              ),
            ],
          ),
        ),

        // Messages Area
        Expanded(
          child: Obx(() {
            if (groupChatController.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                ),
              );
            }

            if (groupChatController.errorMessage.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: const Color(0xFFEF4444),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading messages',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      groupChatController.errorMessage,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => groupChatController.loadMessages(),
                      child: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (groupChatController.messages.isEmpty) {
              return _buildEmptyMessageState();
            }

            return ListView.builder(
              controller: groupChatController.scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: groupChatController.messages.length,
              itemBuilder: (context, index) {
                final message = groupChatController.messages[index];
                return _buildMessageItem(message, index);
              },
            );
          }),
        ),

        // Message Input Area
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: const Color(0xFFF3F4F6), width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFF),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFF3F4F6),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: groupChatController.messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => groupChatController.sendMessage(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Obx(
                () => Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: groupChatController.canSendMessage
                          ? () => groupChatController.sendMessage()
                          : null,
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        width: 48,
                        height: 48,
                        child: groupChatController.isSending
                            ? const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.send,
                                color: Colors.white,
                                size: 24,
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyMessageState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              size: 40,
              color: Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No messages yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start the conversation by sending the first message',
            style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(GroupChatModel message, int index) {
    final isCurrentUser =
        message.user.id ==
        'current_user_id'; // Replace with actual current user ID logic
    final showDateHeader = _shouldShowDateHeader(message, index);

    return Column(
      children: [
        // Date Header
        if (showDateHeader) _buildDateHeader(message.createdAt),

        // Message Bubble
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: isCurrentUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isCurrentUser) ...[
                // User Avatar
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      message.user.name.isNotEmpty
                          ? message.user.name[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],

              // Message Content
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isCurrentUser
                        ? const Color(0xFF6366F1)
                        : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isCurrentUser ? 16 : 4),
                      bottomRight: Radius.circular(isCurrentUser ? 4 : 16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: isCurrentUser
                        ? null
                        : Border.all(color: const Color(0xFFF3F4F6), width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isCurrentUser)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            message.user.name.isNotEmpty
                                ? message.user.name
                                : 'Anonymous User',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6366F1),
                            ),
                          ),
                        ),
                      Text(
                        message.message,
                        style: TextStyle(
                          fontSize: 14,
                          color: isCurrentUser
                              ? Colors.white
                              : const Color(0xFF374151),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatDate(message.createdAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: isCurrentUser
                              ? Colors.white.withValues(alpha: 0.8)
                              : const Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (isCurrentUser) ...[
                const SizedBox(width: 8),
                // Current user avatar (optional)
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF10B981), Color(0xFF059669)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Icon(Icons.person, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);

    String dateText;
    if (messageDate == today) {
      dateText = 'Today';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      dateText = 'Yesterday';
    } else {
      dateText = '${date.day}/${date.month}/${date.year}';
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            dateText,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
      ),
    );
  }

  bool _shouldShowDateHeader(GroupChatModel message, int index) {
    if (index == 0) return true;

    final previousMessage = groupChatController.messages[index - 1];
    final currentDate = DateTime(
      message.createdAt.year,
      message.createdAt.month,
      message.createdAt.day,
    );
    final previousDate = DateTime(
      previousMessage.createdAt.year,
      previousMessage.createdAt.month,
      previousMessage.createdAt.day,
    );

    return currentDate != previousDate;
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

  Widget _buildFloatingActionButton(CourseModel course) {
    if (_currentTabIndex.value == 2 || _currentTabIndex.value == 3) {
      return const SizedBox.shrink();
    } else {
      groupChatController.stopAutoRefresh();
    }
    return FloatingActionButton.extended(
      onPressed: () {
        Get.to(
          () => AddEditLessonScreen(course: course),
          // binding: BindingsBuilder(() {
          //   Get.lazyPut(() => CourseLessonController());
          // }),
        );
      },
      backgroundColor: const Color(0xFF6366F1),
      foregroundColor: Colors.white,
      elevation: 8,
      icon: const Icon(Icons.edit),
      label: const Text('Add Lesson'),
    );
  }
}
