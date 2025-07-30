import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:badges/badges.dart' as badge;
import '../controller/auth/login_controller.dart';
import '../controller/course/course_review_controller.dart';
import '../controller/miscalleneous/notification_controller.dart';
import '../model/auth/user_model.dart';
import 'AI/chat_AI_screen.dart';
import 'Notification.dart/notification_screen.dart';
import 'admin/fetch_course_test.dart';
import 'admin/user_management.dart';
import 'auth/login_screen.dart';
import 'auth/update_profile.dart';
import 'courses/course test/fetch_course.dart';
import 'courses/get_course.dart';
import 'courses/review/show_review.dart';
import 'setting/notification_setting.dart';
import 'setting/password_setting.dart';
import 'teacher/teacher_course.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final LoginController loginController = Get.find<LoginController>();
  final NotificationController notificationController =
      Get.put<NotificationController>(NotificationController());

  @override
  void initState() {
    super.initState();
    // Check for notification updates when app opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = loginController.user.value;
      if (user != null) {
        notificationController.fetchNotifications(userId: user.id);
        notificationController.checkForUpdates(user.id);
      }
    });
  }

  String getRoleTitle(UserModel? user) {
    if (user == null) return 'Dashboard';
    switch (user.role.toLowerCase()) {
      case 'student':
        return 'Student Dashboard';
      case 'teacher':
        return 'Teacher Dashboard';
      case 'admin':
        return 'Admin Panel';
      default:
        return 'Dashboard';
    }
  }

  Color getRoleColor(UserModel? user) {
    if (user == null) return Colors.grey;
    switch (user.role.toLowerCase()) {
      case 'student':
        return Colors.blue;
      case 'teacher':
        return Colors.green;
      case 'admin':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: getRoleColor(loginController.user.value),
        foregroundColor: Colors.white,
        title: Obx(() => Text(getRoleTitle(loginController.user.value))),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Obx(
        () => _buildDrawer(
          loginController.user.value,
          getRoleColor(loginController.user.value),
        ),
      ),
      body: Obx(
        () => _getBodyForIndex(
          _currentIndex,
          loginController.user.value,
          getRoleColor(loginController.user.value),
        ),
      ),

      // Only showing the relevant badge part of MainScreen
      bottomNavigationBar: Obx(() {
        final user = loginController.user.value;
        return BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          selectedItemColor: getRoleColor(user),
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Obx(
                () => badge.Badge(
                  badgeContent: Text(
                    user != null
                        ? notificationController
                              .getUnreadCountForUser(user.id)
                              .toString()
                        : '0',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  showBadge:
                      user != null &&
                      notificationController.getUnreadCountForUser(user.id) > 0,
                  badgeStyle: badge.BadgeStyle(
                    badgeColor: Colors.red,
                    padding: EdgeInsets.all(6),
                  ),
                  child: Icon(Icons.notifications),
                ),
              ),
              label: 'Notifications',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        );
      }),
    );
  }

  Widget _getBodyForIndex(int index, UserModel? user, Color roleColor) {
    switch (index) {
      case 0:
        return _buildHomeScreen(user, roleColor);
      case 1:
        return NotificationScreen(user: user, roleColor: roleColor);
      case 2:
        return _buildSettingsScreen(user, roleColor);
      default:
        return _buildHomeScreen(user, roleColor);
    }
  }

  Widget _buildHomeScreen(UserModel? user, Color roleColor) {
    if (user == null) {
      return Center(child: CircularProgressIndicator());
    }

    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              Text(
                'Welcome ${user.name ?? 'User'}!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: roleColor,
                ),
              ),
              SizedBox(height: 20),
              _buildRoleSpecificContent(user),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSpecificContent(UserModel user) {
    switch (user.role.toLowerCase()) {
      case 'student':
        return _buildStudentContent();
      case 'teacher':
        return _buildTeacherContent();
      case 'admin':
        return _buildAdminContent();
      default:
        return Container();
    }
  }

  Widget _buildStudentContent() {
    return Column(
      children: [
        SizedBox(height: 16),
        _buildDashboardCard(
          icon: Icons.book,
          title: 'My Enrolled Courses',
          subtitle: 'View your enrolled courses',
          color: Colors.blue,
          onTap: () => Get.to(() => CourseScreen()),
        ),
        SizedBox(height: 16),
        _buildDashboardCard(
          icon: Icons.reviews,
          title: 'Your Reviews',
          subtitle: 'View Courses Review',
          color: Colors.purple,
          onTap: () {
            Get.to(
              () => ReviewScreen(),
              binding: BindingsBuilder(() {
                Get.lazyPut(() => CourseReviewController());
              }),
            );
          },
        ),
        SizedBox(height: 16),
        _buildDashboardCard(
          icon: Icons.psychology,
          title: 'Ask AI Assistant',
          subtitle: 'Get help with your studies from AI',
          color: Colors.deepOrange,
          onTap: () => Get.to(() => ChatWithAIScreen()),
        ),
        SizedBox(height: 16),
        _buildDashboardCard(
          icon: Icons.quiz,
          title: 'Course Test Quiz',
          subtitle: 'Start Course Test Journey',
          color: Colors.amber,
          onTap: () => Get.to(() => FetchCourseScreen()),
        ),
      ],
    );
  }

  Widget _buildTeacherContent() {
    return Column(
      children: [
        _buildDashboardCard(
          icon: Icons.library_add_check,
          title: 'My Courses',
          subtitle: 'Manage your Courses',
          color: Colors.green,
          onTap: () {
            Get.to(() => CourseScreen());
          },
        ),
        _buildDashboardCard(
          icon: Icons.book,
          title: 'Enrollment',
          subtitle: 'Manage your student enrollment',
          color: Colors.blue,
          onTap: () {
            Get.to(() => TeacherCourseScreen());
          },
        ),
        SizedBox(height: 16),
        _buildDashboardCard(
          icon: Icons.reviews,
          title: 'Course Review',
          subtitle: 'View and Manage Course Reviews',
          color: Colors.purple,
          onTap: () {
            Get.to(
              () => ReviewScreen(),
              binding: BindingsBuilder(() {
                Get.lazyPut(() => CourseReviewController());
              }),
            );
          },
        ),
        SizedBox(height: 16),
        _buildDashboardCard(
          icon: Icons.psychology,
          title: 'Ask AI Assistant',
          subtitle: 'Get help with your studies from AI',
          color: Colors.deepOrange,
          onTap: () => Get.to(() => ChatWithAIScreen()),
        ),
        SizedBox(height: 16),
        _buildDashboardCard(
          icon: Icons.quiz,
          title: 'Course Test',
          subtitle: 'Manage Course Test',
          color: Colors.amber,
          onTap: () => Get.to(() => FetchCourseScreen()),
        ),
      ],
    );
  }

  Widget _buildAdminContent() {
    return Column(
      children: [
        _buildDashboardCard(
          icon: Icons.manage_accounts,
          title: 'User Management',
          subtitle: 'Manage users and roles',
          color: Colors.red,
          onTap: () => Get.to(() => UserManagementScreen()),
        ),
        SizedBox(height: 16),
        _buildDashboardCard(
          icon: Icons.person,
          title: 'Profile Settings',
          subtitle: 'Manage your profile',
          color: Colors.indigo,
          onTap: () => Get.to(() => ProfileScreen()),
        ),
        SizedBox(height: 16),
        _buildDashboardCard(
          icon: Icons.quiz,
          title: 'Course Test',
          subtitle: 'View Course Test',
          color: Colors.amber,
          onTap: () => Get.to(() => AdminCourseScreen()),
        ),
      ],
    );
  }

  Widget _buildDashboardCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    void Function()? onTap,
  }) {
    return Card(
      elevation: 4,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap:
            onTap ??
            () {
              Get.snackbar(
                'Info',
                'Navigate to $title',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
      ),
    );
  }

  Widget _buildSettingsScreen(UserModel? user, Color roleColor) {
    if (user == null) {
      return Center(child: CircularProgressIndicator());
    }

    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'Settings Panel',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: roleColor,
            ),
          ),
          SizedBox(height: 20),
          _buildSettingsItem(
            icon: Icons.person,
            title: 'Profile',
            subtitle: 'Manage your profile information',
            roleColor: roleColor,
          ),
          _buildSettingsItem(
            icon: Icons.lock,
            title: 'Security Settings',
            subtitle: 'Update your password and security options',
            roleColor: roleColor,
          ),
          _buildSettingsItem(
            icon: Icons.notifications_outlined,
            title: 'Notification Preferences',
            subtitle: 'Manage notification settings',
            roleColor: roleColor,
          ),
          _buildSettingsItem(
            icon: Icons.logout,
            title: 'Logout',
            subtitle: 'Sign out of your account',
            roleColor: roleColor,
            isLogout: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color roleColor,
    bool isLogout = false,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isLogout
              ? Colors.red.withOpacity(0.2)
              : roleColor.withOpacity(0.2),
          child: Icon(icon, color: isLogout ? Colors.red : roleColor),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isLogout ? Colors.red : null,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          if (isLogout) {
            _showLogoutDialog();
          } else {
            if (title == 'Profile') {
              Get.to(() => ProfileScreen());
            } else if (title == 'Notification Preferences') {
              Get.to(() => NotificationPreferencesScreen());
            } else if (title == 'Security Settings') {
              Get.to(
                () => SecuritySettingsScreen(
                  user: loginController.user.value,
                  roleColor: roleColor,
                ),
              );
            } else {
              Get.snackbar(
                'Info',
                'Navigate to $title settings',
                snackPosition: SnackPosition.BOTTOM,
              );
            }
          }
        },
      ),
    );
  }

  Widget _buildDrawer(UserModel? user, Color roleColor) {
    if (user == null) {
      return Drawer(child: Center(child: CircularProgressIndicator()));
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: roleColor),
            accountName: Text(user.name ?? 'User'),
            accountEmail: Text(user.email),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                (user.name ?? 'U')[0].toUpperCase(),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: roleColor,
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home, color: roleColor),
            title: Text('Home'),
            onTap: () {
              setState(() {
                _currentIndex = 0;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.person, color: roleColor),
            title: Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Get.to(() => ProfileScreen());
            },
          ),
          ListTile(
            leading: Icon(Icons.help, color: roleColor),
            title: Text('Help & Support'),
            onTap: () {
              Navigator.pop(context);
              Get.snackbar('Info', 'Navigate to Help & Support');
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _showLogoutDialog();
            },
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          TextButton(
            onPressed: () async {
              Get.back();
              loginController.resetState();
              Get.delete<UserModel>();
              Get.delete<LoginController>();
              Get.offAll(() => LoginScreen());
            },
            child: Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
