// // // group_chat_controller.dart

// // import 'dart:async';
// // import 'dart:developer';

// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import '../../model/group chat/group_chat_model.dart';
// // import '../../services/group_chat_services.dart';

// // class GroupChatController extends GetxController {
// //   // Observable lists and variables
// //   final RxList<GroupChatModel> _messages = <GroupChatModel>[].obs;
// //   final RxBool _isLoading = false.obs;
// //   final RxBool _isSending = false.obs;
// //   final RxString _errorMessage = ''.obs;
// //   final RxString _currentCourseId = ''.obs;

// //   // Text controllers
// //   final TextEditingController messageController = TextEditingController();
// //   final ScrollController scrollController = ScrollController();

// //   // Timer for auto-refresh (optional)
// //   Timer? _refreshTimer;
// //   static const Duration refreshInterval = Duration(seconds: 30);

// //   // Getters
// //   List<GroupChatModel> get messages => _messages;
// //   bool get isLoading => _isLoading.value;
// //   bool get isSending => _isSending.value;
// //   String get errorMessage => _errorMessage.value;
// //   String get currentCourseId => _currentCourseId.value;
// //   bool get hasMessages => _messages.isNotEmpty;

// //   @override
// //   void onInit() {
// //     super.onInit();
// //     log('GroupChatController initialized');
// //   }

// //   @override
// //   void onClose() {
// //     messageController.dispose();
// //     scrollController.dispose();
// //     _refreshTimer?.cancel();
// //     super.onClose();
// //   }

// //   // Set current course and load messages
// //   Future<void> setCourse(String courseId) async {
// //     if (_currentCourseId.value == courseId) return;

// //     _currentCourseId.value = courseId;
// //     _messages.clear();
// //     _errorMessage.value = '';

// //     if (courseId.isNotEmpty) {
// //       await loadMessages();
// //       _startAutoRefresh();
// //     } else {
// //       _stopAutoRefresh();
// //     }
// //   }

// //   // Load messages for current course
// //   Future<void> loadMessages({bool showLoading = true}) async {
// //     if (_currentCourseId.value.isEmpty) {
// //       _errorMessage.value = 'No course selected';
// //       return;
// //     }

// //     try {
// //       if (showLoading) _isLoading.value = true;
// //       _errorMessage.value = '';

// //       log('Loading messages for course: ${_currentCourseId.value}');

// //       final result = await GroupChatService.getCourseMessages(
// //         _currentCourseId.value,
// //       );

// //       if (result.success && result.data != null) {
// //         _messages.assignAll(result.data!);
// //         log('Loaded ${_messages.length} messages');

// //         // Scroll to bottom after loading messages
// //         WidgetsBinding.instance.addPostFrameCallback((_) {
// //           _scrollToBottom();
// //         });
// //       } else {
// //         _errorMessage.value = result.message;
// //         log('Failed to load messages: ${result.message}');

// //         if (showLoading) {
// //           Get.snackbar(
// //             'Error',
// //             result.message,
// //             snackPosition: SnackPosition.BOTTOM,
// //             backgroundColor: Colors.red.withOpacity(0.8),
// //             colorText: Colors.white,
// //             duration: const Duration(seconds: 3),
// //           );
// //         }
// //       }
// //     } catch (e) {
// //       _errorMessage.value = 'Failed to load messages: ${e.toString()}';
// //       log('Exception in loadMessages: $e');

// //       if (showLoading) {
// //         Get.snackbar(
// //           'Error',
// //           'Failed to load messages',
// //           snackPosition: SnackPosition.BOTTOM,
// //           backgroundColor: Colors.red.withOpacity(0.8),
// //           colorText: Colors.white,
// //           duration: const Duration(seconds: 3),
// //         );
// //       }
// //     } finally {
// //       if (showLoading) _isLoading.value = false;
// //     }
// //   }

// //   // Send a message
// //   Future<void> sendMessage({String? customMessage}) async {
// //     final message = customMessage ?? messageController.text.trim();

// //     if (message.isEmpty) {
// //       Get.snackbar(
// //         'Error',
// //         'Please enter a message',
// //         snackPosition: SnackPosition.BOTTOM,
// //         backgroundColor: Colors.orange.withOpacity(0.8),
// //         colorText: Colors.white,
// //         duration: const Duration(seconds: 2),
// //       );
// //       return;
// //     }

// //     if (_currentCourseId.value.isEmpty) {
// //       Get.snackbar(
// //         'Error',
// //         'No course selected',
// //         snackPosition: SnackPosition.BOTTOM,
// //         backgroundColor: Colors.red.withOpacity(0.8),
// //         colorText: Colors.white,
// //         duration: const Duration(seconds: 2),
// //       );
// //       return;
// //     }

// //     try {
// //       _isSending.value = true;
// //       _errorMessage.value = '';

// //       log('Sending message: $message');

// //       final result = await GroupChatService.sendMessage(
// //         message,
// //         _currentCourseId.value,
// //       );

// //       if (result.success && result.data != null) {
// //         // Add the new message to the list
// //         _messages.add(result.data!);

// //         // Clear the message input
// //         if (customMessage == null) {
// //           messageController.clear();
// //         }

// //         log('Message sent successfully: ${result.data!.message}');

// //         // Scroll to bottom to show new message
// //         WidgetsBinding.instance.addPostFrameCallback((_) {
// //           _scrollToBottom();
// //         });

// //         // Show success message
// //         Get.snackbar(
// //           'Success',
// //           'Message sent successfully',
// //           snackPosition: SnackPosition.BOTTOM,
// //           backgroundColor: Colors.green.withOpacity(0.8),
// //           colorText: Colors.white,
// //           duration: const Duration(seconds: 2),
// //         );
// //       } else {
// //         _errorMessage.value = result.message;
// //         log('Failed to send message: ${result.message}');

// //         Get.snackbar(
// //           'Error',
// //           result.message,
// //           snackPosition: SnackPosition.BOTTOM,
// //           backgroundColor: Colors.red.withOpacity(0.8),
// //           colorText: Colors.white,
// //           duration: const Duration(seconds: 3),
// //         );
// //       }
// //     } catch (e) {
// //       _errorMessage.value = 'Failed to send message: ${e.toString()}';
// //       log('Exception in sendMessage: $e');

// //       Get.snackbar(
// //         'Error',
// //         'Failed to send message',
// //         snackPosition: SnackPosition.BOTTOM,
// //         backgroundColor: Colors.red.withOpacity(0.8),
// //         colorText: Colors.white,
// //         duration: const Duration(seconds: 3),
// //       );
// //     } finally {
// //       _isSending.value = false;
// //     }
// //   }

// //   // Refresh messages
// //   Future<void> refreshMessages() async {
// //     await loadMessages(showLoading: false);
// //   }

// //   // Clear messages
// //   void clearMessages() {
// //     _messages.clear();
// //     _errorMessage.value = '';
// //     messageController.clear();
// //   }

// //   // Clear error message
// //   void clearError() {
// //     _errorMessage.value = '';
// //   }

// //   // Scroll to bottom of chat
// //   void _scrollToBottom() {
// //     if (scrollController.hasClients) {
// //       scrollController.animateTo(
// //         scrollController.position.maxScrollExtent,
// //         duration: const Duration(milliseconds: 300),
// //         curve: Curves.easeOut,
// //       );
// //     }
// //   }

// //   // Start auto-refresh timer
// //   void _startAutoRefresh() {
// //     _stopAutoRefresh(); // Stop existing timer if any
// //     _refreshTimer = Timer.periodic(refreshInterval, (timer) {
// //       if (_currentCourseId.value.isNotEmpty) {
// //         refreshMessages();
// //       } else {
// //         _stopAutoRefresh();
// //       }
// //     });
// //     log('Auto-refresh started');
// //   }

// //   // Stop auto-refresh timer
// //   void _stopAutoRefresh() {
// //     _refreshTimer?.cancel();
// //     _refreshTimer = null;
// //     log('Auto-refresh stopped');
// //   }

// //   // Search messages (local search)
// //   List<GroupChatModel> searchMessages(String query) {
// //     if (query.isEmpty) return _messages;

// //     return _messages
// //         .where(
// //           (message) =>
// //               message.message.toLowerCase().contains(query.toLowerCase()),
// //         )
// //         .toList();
// //   }

// //   // Get messages by user
// //   List<GroupChatModel> getMessagesByUser(String userId) {
// //     return _messages.where((message) => message.user.id == userId).toList();
// //   }

// //   // Get message count
// //   int get messageCount => _messages.length;

// //   // Check if user can send messages (you can add more validation logic here)
// //   bool get canSendMessage =>
// //       _currentCourseId.value.isNotEmpty && !_isSending.value;

// //   // Enable/disable auto-refresh
// //   void setAutoRefresh(bool enabled) {
// //     if (enabled && _currentCourseId.value.isNotEmpty) {
// //       _startAutoRefresh();
// //     } else {
// //       _stopAutoRefresh();
// //     }
// //   }

// //   // Reset controller state
// //   void reset() {
// //     _messages.clear();
// //     _currentCourseId.value = '';
// //     _errorMessage.value = '';
// //     _isLoading.value = false;
// //     _isSending.value = false;
// //     messageController.clear();
// //     _stopAutoRefresh();
// //   }
// // }

// // group_chat_controller.dart

// import 'dart:async';
// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../model/group chat/group_chat_model.dart';
// import '../../model/auth/user_model.dart';
// import '../../model/course/course_model.dart';
// import '../../services/group_chat_services.dart';

// class GroupChatController extends GetxController {
//   // Observable lists and variables
//   final RxList<GroupChatModel> _messages = <GroupChatModel>[].obs;
//   final RxBool _isLoading = false.obs;
//   final RxBool _isSending = false.obs;
//   final RxString _errorMessage = ''.obs;
//   final RxString _currentCourseId = ''.obs;

//   // Text controllers
//   final TextEditingController messageController = TextEditingController();
//   final ScrollController scrollController = ScrollController();

//   // Timer for auto-refresh (optional)
//   Timer? _refreshTimer;
//   static const Duration refreshInterval = Duration(seconds: 30);

//   // Cache for current course and user data
//   CourseModel? _currentCourse;
//   UserModel? _currentUser;

//   // Getters
//   List<GroupChatModel> get messages => _messages;
//   bool get isLoading => _isLoading.value;
//   bool get isSending => _isSending.value;
//   String get errorMessage => _errorMessage.value;
//   String get currentCourseId => _currentCourseId.value;
//   bool get hasMessages => _messages.isNotEmpty;

//   @override
//   void onInit() {
//     super.onInit();
//     log('GroupChatController initialized');
//   }

//   @override
//   void onClose() {
//     messageController.dispose();
//     scrollController.dispose();
//     _refreshTimer?.cancel();
//     super.onClose();
//   }

//   // Set current course and load messages
//   Future<void> setCourse(
//     String courseId, {
//     CourseModel? courseModel,
//     UserModel? userModel,
//   }) async {
//     if (_currentCourseId.value == courseId) return;

//     _currentCourseId.value = courseId;
//     _currentCourse = courseModel;
//     _currentUser = userModel;
//     _messages.clear();
//     _errorMessage.value = '';

//     if (courseId.isNotEmpty) {
//       await loadMessages();
//       _startAutoRefresh();
//     } else {
//       _stopAutoRefresh();
//     }
//   }

//   // Load messages for current course
//   Future<void> loadMessages({bool showLoading = true}) async {
//     if (_currentCourseId.value.isEmpty) {
//       _errorMessage.value = 'No course selected';
//       return;
//     }

//     try {
//       if (showLoading) _isLoading.value = true;
//       _errorMessage.value = '';

//       log('Loading messages for course: ${_currentCourseId.value}');

//       final result = await GroupChatService.getCourseMessages(
//         _currentCourseId.value,
//       );

//       if (result.success && result.data != null) {
//         _messages.assignAll(result.data!);

//         // Update cached course and user data from the first message if not already set
//         if (_messages.isNotEmpty && _currentCourse == null) {
//           final firstMessage = _messages.first;
//           if (firstMessage.hasFullCourseData) {
//             _currentCourse = firstMessage.course;
//           }
//           if (firstMessage.hasFullUserData) {
//             _currentUser = firstMessage.user;
//           }
//         }

//         log('Loaded ${_messages.length} messages');

//         // Scroll to bottom after loading messages
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           _scrollToBottom();
//         });
//       } else {
//         _errorMessage.value = result.message;
//         log('Failed to load messages: ${result.message}');

//         if (showLoading) {
//           Get.snackbar(
//             'Error',
//             result.message,
//             snackPosition: SnackPosition.BOTTOM,
//             backgroundColor: Colors.red.withOpacity(0.8),
//             colorText: Colors.white,
//             duration: const Duration(seconds: 3),
//           );
//         }
//       }
//     } catch (e) {
//       _errorMessage.value = 'Failed to load messages: ${e.toString()}';
//       log('Exception in loadMessages: $e');

//       if (showLoading) {
//         Get.snackbar(
//           'Error',
//           'Failed to load messages',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.red.withOpacity(0.8),
//           colorText: Colors.white,
//           duration: const Duration(seconds: 3),
//         );
//       }
//     } finally {
//       if (showLoading) _isLoading.value = false;
//     }
//   }

//   // Send a message
//   Future<void> sendMessage({String? customMessage}) async {
//     final message = customMessage ?? messageController.text.trim();

//     if (message.isEmpty) {
//       Get.snackbar(
//         'Error',
//         'Please enter a message',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.orange.withOpacity(0.8),
//         colorText: Colors.white,
//         duration: const Duration(seconds: 2),
//       );
//       return;
//     }

//     if (_currentCourseId.value.isEmpty) {
//       Get.snackbar(
//         'Error',
//         'No course selected',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red.withOpacity(0.8),
//         colorText: Colors.white,
//         duration: const Duration(seconds: 2),
//       );
//       return;
//     }

//     try {
//       _isSending.value = true;
//       _errorMessage.value = '';

//       log('Sending message: $message');

//       final result = await GroupChatService.sendMessage(
//         message,
//         _currentCourseId.value,
//       );

//       if (result.success && result.data != null) {
//         // The sent message will have minimal data (only IDs)
//         var sentMessage = result.data!;

//         // If we have cached course and user data, update the message with full data
//         if (_currentCourse != null || _currentUser != null) {
//           sentMessage = sentMessage.copyWithFullData(
//             fullCourse: _currentCourse,
//             fullUser: _currentUser,
//           );
//         } else {
//           // If no cached data, try to get it from existing messages
//           if (_messages.isNotEmpty) {
//             final existingMessage = _messages.first;
//             if (existingMessage.hasFullCourseData &&
//                 sentMessage.courseId == existingMessage.courseId) {
//               sentMessage = sentMessage.copyWithFullData(
//                 fullCourse: existingMessage.course,
//               );
//             }
//             if (existingMessage.hasFullUserData &&
//                 sentMessage.userId == existingMessage.userId) {
//               sentMessage = sentMessage.copyWithFullData(
//                 fullUser: existingMessage.user,
//               );
//             }
//           }
//         }

//         // Add the updated message to the list
//         _messages.add(sentMessage);

//         // Clear the message input
//         if (customMessage == null) {
//           messageController.clear();
//         }

//         log('Message sent successfully: ${sentMessage.message}');

//         // Scroll to bottom to show new message
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           _scrollToBottom();
//         });

//         // Show success message
//         Get.snackbar(
//           'Success',
//           'Message sent successfully',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.green.withOpacity(0.8),
//           colorText: Colors.white,
//           duration: const Duration(seconds: 2),
//         );
//       } else {
//         _errorMessage.value = result.message;
//         log('Failed to send message: ${result.message}');

//         Get.snackbar(
//           'Error',
//           result.message,
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.red.withOpacity(0.8),
//           colorText: Colors.white,
//           duration: const Duration(seconds: 3),
//         );
//       }
//     } catch (e) {
//       _errorMessage.value = 'Failed to send message: ${e.toString()}';
//       log('Exception in sendMessage: $e');

//       Get.snackbar(
//         'Error',
//         'Failed to send message',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red.withOpacity(0.8),
//         colorText: Colors.white,
//         duration: const Duration(seconds: 3),
//       );
//     } finally {
//       _isSending.value = false;
//     }
//   }

//   // Refresh messages
//   Future<void> refreshMessages() async {
//     await loadMessages(showLoading: false);
//   }

//   // Clear messages
//   void clearMessages() {
//     _messages.clear();
//     _errorMessage.value = '';
//     messageController.clear();
//   }

//   // Clear error message
//   void clearError() {
//     _errorMessage.value = '';
//   }

//   // Scroll to bottom of chat
//   void _scrollToBottom() {
//     if (scrollController.hasClients) {
//       scrollController.animateTo(
//         scrollController.position.maxScrollExtent,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeOut,
//       );
//     }
//   }

//   // Start auto-refresh timer
//   void _startAutoRefresh() {
//     _stopAutoRefresh(); // Stop existing timer if any
//     _refreshTimer = Timer.periodic(refreshInterval, (timer) {
//       if (_currentCourseId.value.isNotEmpty) {
//         refreshMessages();
//       } else {
//         _stopAutoRefresh();
//       }
//     });
//     log('Auto-refresh started');
//   }

//   // Stop auto-refresh timer
//   void _stopAutoRefresh() {
//     _refreshTimer?.cancel();
//     _refreshTimer = null;
//     log('Auto-refresh stopped');
//   }

//   // Search messages (local search)
//   List<GroupChatModel> searchMessages(String query) {
//     if (query.isEmpty) return _messages;

//     return _messages
//         .where(
//           (message) =>
//               message.message.toLowerCase().contains(query.toLowerCase()),
//         )
//         .toList();
//   }

//   // Get messages by user
//   List<GroupChatModel> getMessagesByUser(String userId) {
//     return _messages.where((message) => message.user.id == userId).toList();
//   }

//   // Get message count
//   int get messageCount => _messages.length;

//   // Check if user can send messages (you can add more validation logic here)
//   bool get canSendMessage =>
//       _currentCourseId.value.isNotEmpty && !_isSending.value;

//   // Enable/disable auto-refresh
//   void setAutoRefresh(bool enabled) {
//     if (enabled && _currentCourseId.value.isNotEmpty) {
//       _startAutoRefresh();
//     } else {
//       _stopAutoRefresh();
//     }
//   }

//   // Reset controller state
//   void reset() {
//     _messages.clear();
//     _currentCourseId.value = '';
//     _currentCourse = null;
//     _currentUser = null;
//     _errorMessage.value = '';
//     _isLoading.value = false;
//     _isSending.value = false;
//     messageController.clear();
//     _stopAutoRefresh();
//   }

//   // Set current user data (call this when you know the current user)
//   void setCurrentUser(UserModel user) {
//     _currentUser = user;
//   }

//   // Set current course data (call this when you know the current course)
//   void setCurrentCourse(CourseModel course) {
//     _currentCourse = course;
//   }
// }
