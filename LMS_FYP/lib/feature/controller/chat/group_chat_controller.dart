// group_chat_controller.dart

import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utility/clear_focus.dart';
import '../../model/group chat/group_chat_model.dart';
import '../../model/course/course_model.dart';
import '../../model/auth/user_model.dart';
import '../../services/group_chat_services.dart';

class GroupChatController extends GetxController {
  // Observable lists and variables
  final RxList<GroupChatModel> _messages = <GroupChatModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isSending = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxString _currentCourseId = ''.obs;

  // Store current course and user data for reuse
  CourseModel? _currentCourse;
  UserModel? _currentUser;

  // Text controllers
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  // Timer for auto-refresh (optional)
  Timer? _refreshTimer;
  static const Duration refreshInterval = Duration(seconds: 30);

  // Getters
  List<GroupChatModel> get messages => _messages;
  bool get isLoading => _isLoading.value;
  bool get isSending => _isSending.value;
  String get errorMessage => _errorMessage.value;
  String get currentCourseId => _currentCourseId.value;
  bool get hasMessages => _messages.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    log('GroupChatController initialized');
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    _refreshTimer?.cancel();
    super.onClose();
  }

  // Set current course and user data
  Future<void> setCourse(
    String courseId, {
    CourseModel? courseData,
    UserModel? userData,
  }) async {
    if (_currentCourseId.value == courseId) return;

    _currentCourseId.value = courseId;
    _currentCourse = courseData;
    _currentUser = userData;
    _messages.clear();
    _errorMessage.value = '';

    if (courseId.isNotEmpty) {
      await loadMessages();
      // _startAutoRefresh();
    } else {
      stopAutoRefresh();
    }
  }

  // Method to set current user data (call this when user logs in or when you have user data)
  void setCurrentUser(UserModel? user) {
    _currentUser = user;
    log('Current user set: ${user!.name} (${user.id})');
  }

  // Method to set current course data
  void setCurrentCourse(CourseModel course) {
    _currentCourse = course;
    log('Current course set: ${course.title} (${course.id})');
  }

  // Load messages for current course
  Future<void> loadMessages({bool showLoading = true}) async {
    if (_currentCourseId.value.isEmpty) {
      _errorMessage.value = 'No course selected';
      return;
    }

    try {
      if (showLoading) _isLoading.value = true;
      _errorMessage.value = '';

      log('Loading messages for course: ${_currentCourseId.value}');

      final result = await GroupChatService.getCourseMessages(
        _currentCourseId.value,
      );

      if (result.success && result.data != null) {
        _messages.assignAll(result.data!);

        // Extract course and user data from loaded messages if we don't have them
        if (_messages.isNotEmpty) {
          if (_currentCourse == null && _messages.first.hasFullCourseData) {
            _currentCourse = _messages.first.course;
            log(
              'Extracted course data from messages: ${_currentCourse!.title}',
            );
          }

          // Find current user's message to extract user data
          if (_currentUser == null) {
            final userMessage = _messages.firstWhere(
              (msg) => msg.hasFullUserData,
              orElse: () => _messages.first,
            );
            if (userMessage.hasFullUserData) {
              _currentUser = userMessage.user;
              log('Extracted user data from messages: ${_currentUser!.name}');
            }
          }
        }

        log('Loaded ${_messages.length} messages');

        // Scroll to bottom after loading messages
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      } else {
        _errorMessage.value = result.message;
        log('Failed to load messages: ${result.message}');

        if (showLoading) {
          Get.snackbar(
            'Error',
            result.message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withOpacity(0.8),
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
        }
      }
    } catch (e) {
      _errorMessage.value = 'Failed to load messages: ${e.toString()}';
      log('Exception in loadMessages: $e');

      if (showLoading) {
        Get.snackbar(
          'Error',
          'Failed to load messages',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } finally {
      if (showLoading) _isLoading.value = false;
    }
  }

  // Enhanced send message method with data reuse
  Future<void> sendMessage({String? customMessage}) async {
    ClearFocus.clearAllFocus(Get.context!);
    final message = customMessage ?? messageController.text.trim();

    if (message.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a message',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    if (_currentCourseId.value.isEmpty) {
      Get.snackbar(
        'Error',
        'No course selected',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    try {
      _isSending.value = true;
      _errorMessage.value = '';

      log('Sending message: $message');

      final result = await GroupChatService.sendMessage(
        message,
        _currentCourseId.value,
      );

      if (result.success && result.data != null) {
        // Create enhanced message with full data if available
        GroupChatModel enhancedMessage = result.data!;

        // If the response doesn't have full course/user data, use what we have stored
        if (!enhancedMessage.hasFullCourseData && _currentCourse != null) {
          log('Using stored course data for new message');
          enhancedMessage = enhancedMessage.copyWithFullData(
            fullCourse: _currentCourse,
          );
        }

        if (!enhancedMessage.hasFullUserData && _currentUser != null) {
          log('Using stored user data for new message');
          enhancedMessage = enhancedMessage.copyWithFullData(
            fullUser: _currentUser,
          );
        }

        // If we still don't have full data, try to get it from existing messages
        if ((!enhancedMessage.hasFullCourseData ||
                !enhancedMessage.hasFullUserData) &&
            _messages.isNotEmpty) {
          // Find a message with full course data
          if (!enhancedMessage.hasFullCourseData) {
            final courseMessage = _messages.firstWhere(
              (msg) =>
                  msg.hasFullCourseData &&
                  msg.courseId == enhancedMessage.courseId,
              orElse: () => _messages.first,
            );
            if (courseMessage.hasFullCourseData) {
              log('Using course data from existing messages');
              enhancedMessage = enhancedMessage.copyWithFullData(
                fullCourse: courseMessage.course,
              );
            }
          }

          // Find a message with full user data for the same user
          if (!enhancedMessage.hasFullUserData) {
            final userMessage = _messages.firstWhere(
              (msg) =>
                  msg.hasFullUserData && msg.userId == enhancedMessage.userId,
              orElse: () => _messages.firstWhere(
                (msg) => msg.hasFullUserData,
                orElse: () => _messages.first,
              ),
            );
            if (userMessage.hasFullUserData) {
              log('Using user data from existing messages');
              enhancedMessage = enhancedMessage.copyWithFullData(
                fullUser: userMessage.user,
              );
            }
          }
        }

        // Add the enhanced message to the list
        _messages.add(enhancedMessage);

        // Clear the message input
        if (customMessage == null) {
          messageController.clear();
        }

        log('Message sent successfully: ${enhancedMessage.message}');
        log(
          'Message has full course data: ${enhancedMessage.hasFullCourseData}',
        );
        log('Message has full user data: ${enhancedMessage.hasFullUserData}');

        // Scroll to bottom to show new message
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });

        // Show success message
        Get.snackbar(
          'Success',
          'Message sent successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        _errorMessage.value = result.message;
        log('Failed to send message: ${result.message}');

        Get.snackbar(
          'Error',
          result.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      _errorMessage.value = 'Failed to send message: ${e.toString()}';
      log('Exception in sendMessage: $e');

      Get.snackbar(
        'Error',
        'Failed to send message',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      _isSending.value = false;
    }
  }

  // Refresh messages
  Future<void> refreshMessages() async {
    await loadMessages(showLoading: false);
  }

  // Clear messages
  void clearMessages() {
    _messages.clear();
    _errorMessage.value = '';
    messageController.clear();
  }

  // Clear error message
  void clearError() {
    _errorMessage.value = '';
  }

  // Scroll to bottom of chat
  void _scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // Stop auto-refresh timer
  void stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    log('Auto-refresh stopped');
  }

  // Search messages (local search)
  List<GroupChatModel> searchMessages(String query) {
    if (query.isEmpty) return _messages;

    return _messages
        .where(
          (message) =>
              message.message.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  // Get messages by user
  List<GroupChatModel> getMessagesByUser(String userId) {
    return _messages.where((message) => message.user.id == userId).toList();
  }

  // Get message count
  int get messageCount => _messages.length;

  // Check if user can send messages
  bool get canSendMessage =>
      _currentCourseId.value.isNotEmpty && !_isSending.value;

  // Enable/disable auto-refresh
  void setAutoRefresh(bool enabled) {
    if (enabled && _currentCourseId.value.isNotEmpty) {
      // _startAutoRefresh();
    } else {
      stopAutoRefresh();
    }
  }

  // Reset controller state
  void reset() {
    _messages.clear();
    _currentCourseId.value = '';
    _currentCourse = null;
    _currentUser = null;
    _errorMessage.value = '';
    _isLoading.value = false;
    _isSending.value = false;
    messageController.clear();
    stopAutoRefresh();
  }

  // Getter methods for current data
  CourseModel? get currentCourse => _currentCourse;
  UserModel? get currentUser => _currentUser;

  // Helper method to check if we have sufficient data
  bool get hasRequiredData => _currentCourse != null && _currentUser != null;
}
