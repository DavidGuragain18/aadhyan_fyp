import 'dart:developer';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../model/notification_model.dart' as my_model;
import '../../model/notification_model.dart';
import '../../services/notidication_services.dart';
import '../auth/login_controller.dart';

class NotificationController extends GetxController {
  // Reactive variables
  final RxList<my_model.NotificationModel> notifications =
      <my_model.NotificationModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Computed unread count based on user-specific status
  int getUnreadCountForUser(String userId) {
    return notifications
        .where((notification) => 
            notification.recipients.contains(userId) && 
            !notification.isReadByUser(userId))
        .length;
  }

  @override
  void onInit() async {
    super.onInit();
    // Initialize awesome_notifications
    await AwesomeNotifications().initialize(
      null, // Use default icon
      [
        NotificationChannel(
          channelKey: 'basic_channel',
          channelName: 'Basic Notifications',
          channelDescription: 'Notification channel for course updates',
          defaultColor: Colors.blue,
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          playSound: true,
          enableVibration: true,
        ),
      ],
      debug: true,
    );

    // Request notification permission
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  // Create a local notification for a new notification
  Future<void> _createLocalNotification(
    my_model.NotificationModel notification,
  ) async {
    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: notification.id.hashCode, // Use notification ID as unique ID
          channelKey: 'basic_channel',
          title: notification.title,
          body: notification.body,
          notificationLayout: NotificationLayout.Default,
          payload: {
            'notificationId': notification.id,
            'courseId': notification.data?.courseId ?? '',
          },
        ),
      );
      log('Local notification created for: ${notification.title}');
    } catch (e) {
      log('Error creating local notification: $e');
    }
  }

  // Fetch notifications and filter by userId
  Future<void> fetchNotifications({required String userId}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      log('Fetching notifications for user: $userId');

      final response = await NotificationService.getNotificationList();

      if (response.success && response.data != null) {
        // Filter notifications where userId is in recipients
        final filteredNotifications = response.data!
            .where((notification) => notification.recipients.contains(userId))
            .toList();

        // Create local notifications for new unread notifications
        for (var notification in filteredNotifications) {
          if (!notification.isReadByUser(userId)) {
            await _createLocalNotification(notification);
          }
        }

        notifications.assignAll(filteredNotifications);
        log('Fetched ${notifications.length} notifications for user: $userId');
      } else {
        errorMessage.value =
            response.message ?? 'Failed to fetch notifications';
        Get.snackbar('Error', errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = 'Unexpected error: $e';
      Get.snackbar('Error', errorMessage.value);
      log('Error fetching notifications: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Check for notification updates
  Future<void> checkForUpdates(String userId) async {
    try {
      // Fetch new notifications
      final response = await NotificationService.getNotificationList();

      if (response.success && response.data != null) {
        final filteredNotifications = response.data!
            .where((notification) => notification.recipients.contains(userId))
            .toList();

        // Find new notifications
        final newNotifications = filteredNotifications
            .where(
              (newNotif) => !notifications.any(
                (oldNotif) => oldNotif.id == newNotif.id,
              ),
            )
            .toList();

        // Create local notifications for new unread notifications
        for (var notification in newNotifications) {
          if (!notification.isReadByUser(userId)) {
            await _createLocalNotification(notification);
          }
        }

        // Update notifications list
        notifications.assignAll(filteredNotifications);
        log('Updated notifications: ${notifications.length} total notifications');
      }
    } catch (e) {
      log('Error checking for notification updates: $e');
    }
  }

  // Mark notification as read by updating status to 'read' for specific user
  Future<void> markNotificationAsRead(String notificationId, String userId) async {
    try {
      final response = await NotificationService.updateNotificationStatus(
        notificationId,
        NotificationStatus.read.toJsonString,
      );

      if (response.success && response.data == true) {
        final index = notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          // Update the notification status for this user
          final updatedNotificationStatus = List<UserNotificationStatus>.from(
            notifications[index].notificationStatus,
          );
          
          final existingStatusIndex = updatedNotificationStatus.indexWhere(
            (status) => status.userId == userId,
          );
          
          if (existingStatusIndex != -1) {
            // Update existing status
            updatedNotificationStatus[existingStatusIndex] = UserNotificationStatus(
              userId: userId,
              status: NotificationStatus.read,
              id: updatedNotificationStatus[existingStatusIndex].id,
            );
          } else {
            // Add new status
            updatedNotificationStatus.add(
              UserNotificationStatus(
                userId: userId,
                status: NotificationStatus.read,
                id: DateTime.now().millisecondsSinceEpoch.toString(),
              ),
            );
          }

          notifications[index] = notifications[index].copyWith(
            notificationStatus: updatedNotificationStatus,
            updatedAt: DateTime.now(),
          );
          
          log('Notification marked as read for user $userId: $notificationId');
        }
      } else {
        log('Failed to mark notification as read: ${response.message}');
      }
    } catch (e) {
      log('Error marking notification as read: $e');
    }
  }

  Future<void> createTestNotification({
    required List<String> recipients,
    required String title,
    required String body,
    String? courseId,
    String type = 'test',
    String status = 'sent',
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await NotificationService.createTestNotification(
        recipients: recipients,
        title: title,
        body: body,
        courseId: courseId,
        type: type,
        status: status,
      );

      if (response.success && response.data != null) {
        notifications.add(response.data!);
        // Create a local notification for the new test notification
        if (recipients.contains(Get.find<LoginController>().user.value?.id)) {
          await _createLocalNotification(response.data!);
        }
        log('Test notification created successfully');
      } else {
        errorMessage.value =
            response.message ?? 'Failed to create notification';
        Get.snackbar('Error', errorMessage.value);
        log('Notification creation failed: ${response.message}');
      }
    } catch (e) {
      errorMessage.value = 'Unexpected error: $e';
      Get.snackbar('Error', errorMessage.value);
      log('Error creating notification: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<my_model.NotificationModel?> getNotificationById(
    String notificationId,
  ) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await NotificationService.getNotificationById(
        notificationId,
      );

      if (response.success && response.data != null) {
        final index = notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          notifications[index] = response.data!;
        } else {
          notifications.add(response.data!);
        }
        return response.data!;
      } else {
        errorMessage.value = response.message ?? 'Failed to fetch notification';
        Get.snackbar('Error', errorMessage.value);
        return null;
      }
    } catch (e) {
      errorMessage.value = 'Unexpected error: $e';
      Get.snackbar('Error', errorMessage.value);
      log('Error fetching notification by ID: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateNotificationStatus(
    String notificationId,
    NotificationStatus status,
  ) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await NotificationService.updateNotificationStatus(
        notificationId,
        status.toJsonString,
      );

      if (response.success && response.data == true) {
        final index = notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          notifications[index] = notifications[index].copyWith(
            status: status,
            updatedAt: DateTime.now(),
          );
          Get.snackbar(
            'Success',
            'Notification status updated to ${status.toJsonString}',
          );
        }
      } else {
        errorMessage.value =
            response.message ?? 'Failed to update notification status';
        Get.snackbar('Error', errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = 'Unexpected error: $e';
      Get.snackbar('Error', errorMessage.value);
      log('Error updating notification status: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void clearError() {
    errorMessage.value = '';
  }
}