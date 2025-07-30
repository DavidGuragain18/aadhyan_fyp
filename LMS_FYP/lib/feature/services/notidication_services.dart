// notification_service.dart

import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:get/get.dart' as token;
import '../../core/constant/api_url.dart';
import '../../core/helpers/internet_connection.dart';
import '../controller/auth/login_controller.dart';
import '../model/api_response_model.dart';
import '../model/notification_model.dart';

class NotificationService {
  static const String notificationEndpoint = '/notifications';

  static const Duration timeoutDuration = Duration(seconds: 30);
  static late Dio _dio;

  final LoginController loginController = token.Get.find<LoginController>();

  // Initialize Dio instance
  void _initializeDio() {
    String authToken = loginController.user.value!.token;
    log('Auth token found: $authToken');

    _dio = Dio(
      BaseOptions(
        baseUrl: BASE_API,
        connectTimeout: timeoutDuration,
        receiveTimeout: timeoutDuration,
        sendTimeout: timeoutDuration,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => print(obj),
      ),
    );
  }

  // Get all notifications for user
  static Future<ApiResponse<List<NotificationModel>>>
  getNotificationList() async {
    try {
      log('Fetching notification list...');

      // Check internet connection
      if (!await ConnectivityService.hasInternetConnection()) {
        return ApiResponse<List<NotificationModel>>(
          success: false,
          message: 'No internet connection. Please check your network.',
        );
      }

      // Initialize Dio if not already done
      NotificationService()._initializeDio();

      final response = await _dio.get(
        notificationEndpoint,
        options: Options(contentType: 'application/json'),
      );

      log('Notification list response: ${response.data}');

      // Handle successful response
      if (response.statusCode == 200) {
        try {
          List<NotificationModel> notifications = [];

          // Check if response.data is a List directly
          if (response.data is List) {
            notifications = (response.data as List)
                .map(
                  (notificationJson) =>
                      NotificationModel.fromJson(notificationJson),
                )
                .toList();
          }
          // Or if it's wrapped in an object like {notifications: [...]}
          else if (response.data is Map<String, dynamic>) {
            final data = response.data as Map<String, dynamic>;
            if (data.containsKey('notifications') &&
                data['notifications'] is List) {
              notifications = (data['notifications'] as List)
                  .map(
                    (notificationJson) =>
                        NotificationModel.fromJson(notificationJson),
                  )
                  .toList();
            } else if (data.containsKey('data') && data['data'] is List) {
              notifications = (data['data'] as List)
                  .map(
                    (notificationJson) =>
                        NotificationModel.fromJson(notificationJson),
                  )
                  .toList();
            }
          }

          log('Parsed ${notifications.length} notifications successfully');

          return ApiResponse<List<NotificationModel>>(
            success: true,
            message: 'Notifications fetched successfully',
            data: notifications,
            statusCode: response.statusCode,
          );
        } catch (parseError) {
          log('Error parsing notifications: $parseError');
          return ApiResponse<List<NotificationModel>>(
            success: false,
            message:
                'Failed to parse notification data: ${parseError.toString()}',
            statusCode: response.statusCode,
          );
        }
      } else {
        return _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      log('DioException in getNotificationList: ${e.message}');
      return _handleDioError(e);
    } catch (e) {
      log('Unexpected error in getNotificationList: $e');
      return ApiResponse<List<NotificationModel>>(
        success: false,
        message:
            'An unexpected error occurred while fetching notifications: ${e.toString()}',
      );
    }
  }

  // Create a test notification
  static Future<ApiResponse<NotificationModel>> createTestNotification({
    required List<String> recipients,
    required String title,
    required String body,
    String? courseId,
    String type = 'test',
    String status = 'sent',
  }) async {
    try {
    

      // Check internet connection
      if (!await ConnectivityService.hasInternetConnection()) {
        return ApiResponse<NotificationModel>(
          success: false,
          message: 'No internet connection. Please check your network.',
        );
      }

      // Initialize Dio if not already done
      NotificationService()._initializeDio();

      // Validate required fields
      if (title.isEmpty || body.isEmpty) {
        return ApiResponse<NotificationModel>(
          success: false,
          message: 'Title and body are required.',
        );
      }

      // Prepare request data to match API exactly
      Map<String, dynamic> requestData = {
        'courseId': courseId?.trim() ?? '',
        'title': title.trim(),
        'body': body.trim(),
        'status': status,
        'type': type,
      };

      log('Sending request data: $requestData');

      final response = await _dio.post(
        '$notificationEndpoint/create-test-notification',
        data: requestData,
        options: Options(contentType: 'application/json'),
      );

      log('API Response: ${response.data}');
      log('Status Code: ${response.statusCode}');

      // Handle successful response
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          NotificationModel notification;

          // Parse the created notification from response
          if (response.data is Map<String, dynamic>) {
            final data = response.data as Map<String, dynamic>;

            // Check different possible response structures
            if (data.containsKey('notification')) {
              notification = NotificationModel.fromJson(data['notification']);
            } else if (data.containsKey('data')) {
              notification = NotificationModel.fromJson(data['data']);
            } else {
              notification = NotificationModel.fromJson(data);
            }
          } else {
            throw Exception('Invalid response format: ${response.data}');
          }

          log('Test notification created successfully: ${notification.title}');

          return ApiResponse<NotificationModel>(
            success: true,
            message: 'Test notification created successfully',
            data: notification,
            statusCode: response.statusCode,
          );
        } catch (parseError) {
          log('Error parsing created notification: $parseError');
          log('Raw response data: ${response.data}');
          return ApiResponse<NotificationModel>(
            success: false,
            message:
                'Notification created but failed to parse response: ${parseError.toString()}',
            statusCode: response.statusCode,
          );
        }
      } else {
        log('Non-success status code: ${response.statusCode}');
        return _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      log('DioException in createTestNotification: ${e.message}');
      log('DioException type: ${e.type}');
      log('DioException response: ${e.response?.data}');
      return _handleDioError(e);
    } catch (e) {
      log('Unexpected error in createTestNotification: $e');
      return ApiResponse<NotificationModel>(
        success: false,
        message:
            'An unexpected error occurred while creating notification: ${e.toString()}',
      );
    }
  }

  // Get notification by ID
  static Future<ApiResponse<NotificationModel>> getNotificationById(
    String notificationId,
  ) async {
    try {
      log('Fetching notification: $notificationId');

      // Check internet connection
      if (!await ConnectivityService.hasInternetConnection()) {
        return ApiResponse<NotificationModel>(
          success: false,
          message: 'No internet connection. Please check your network.',
        );
      }

      // Initialize Dio if not already done
      NotificationService()._initializeDio();

      // Validate required fields
      if (notificationId.isEmpty) {
        return ApiResponse<NotificationModel>(
          success: false,
          message: 'Notification ID is required.',
        );
      }

      final response = await _dio.get(
        '$notificationEndpoint/$notificationId',
        options: Options(contentType: 'application/json'),
      );

      // Handle successful response
      if (response.statusCode == 200) {
        try {
          NotificationModel notification;

          // Parse the notification from response
          if (response.data is Map<String, dynamic>) {
            final data = response.data as Map<String, dynamic>;

            // Check different possible response structures
            if (data.containsKey('notification')) {
              notification = NotificationModel.fromJson(data['notification']);
            } else if (data.containsKey('data')) {
              notification = NotificationModel.fromJson(data['data']);
            } else {
              notification = NotificationModel.fromJson(data);
            }
          } else {
            throw Exception('Invalid response format');
          }

          log('Notification fetched successfully: ${notification.title}');

          return ApiResponse<NotificationModel>(
            success: true,
            message: 'Notification fetched successfully',
            data: notification,
            statusCode: response.statusCode,
          );
        } catch (parseError) {
          log('Error parsing notification: $parseError');
          return ApiResponse<NotificationModel>(
            success: false,
            message:
                'Failed to parse notification data: ${parseError.toString()}',
            statusCode: response.statusCode,
          );
        }
      } else {
        return _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      log('DioException in getNotificationById: ${e.message}');
      return _handleDioError(e);
    } catch (e) {
      log('Unexpected error in getNotificationById: $e');
      return ApiResponse<NotificationModel>(
        success: false,
        message:
            'An unexpected error occurred while fetching notification: ${e.toString()}',
      );
    }
  }


  // Get count of unread notifications
  static Future<ApiResponse<int>> getUnreadNotificationCount() async {
    try {
      log('Fetching unread notification count...');

      // Check internet connection
      if (!await ConnectivityService.hasInternetConnection()) {
        return ApiResponse<int>(
          success: false,
          message: 'No internet connection. Please check your network.',
        );
      }

      // Initialize Dio if not already done
      NotificationService()._initializeDio();

      final response = await _dio.get(
        '$notificationEndpoint/unread/count',
        options: Options(contentType: 'application/json'),
      );

      // Handle successful response
      if (response.statusCode == 200) {
        try {
          int count = 0;

          // Parse the count from response
          if (response.data is Map<String, dynamic>) {
            final data = response.data as Map<String, dynamic>;
            count = data['count'] ?? data['unreadCount'] ?? 0;
          } else if (response.data is int) {
            count = response.data;
          }

          log('Unread notification count: $count');

          return ApiResponse<int>(
            success: true,
            message: 'Unread count fetched successfully',
            data: count,
            statusCode: response.statusCode,
          );
        } catch (parseError) {
          log('Error parsing unread count: $parseError');
          return ApiResponse<int>(
            success: false,
            message: 'Failed to parse unread count: ${parseError.toString()}',
            statusCode: response.statusCode,
          );
        }
      } else {
        return _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      log('DioException in getUnreadNotificationCount: ${e.message}');
      return _handleDioError(e);
    } catch (e) {
      log('Unexpected error in getUnreadNotificationCount: $e');
      return ApiResponse<int>(
        success: false,
        message:
            'An unexpected error occurred while fetching unread count: ${e.toString()}',
      );
    }
  }

  // Mark notification as read
  static Future<ApiResponse<bool>> markNotificationAsRead(
    String notificationId,
  ) async {
    try {
      log('Marking notification as read: $notificationId');

      // Check internet connection
      if (!await ConnectivityService.hasInternetConnection()) {
        return ApiResponse<bool>(
          success: false,
          message: 'No internet connection. Please check your network.',
        );
      }

      // Initialize Dio if not already done
      NotificationService()._initializeDio();

      // Validate required fields
      if (notificationId.isEmpty) {
        return ApiResponse<bool>(
          success: false,
          message: 'Notification ID is required.',
        );
      }

      final response = await _dio.put(
        '$notificationEndpoint/$notificationId/read',
        options: Options(contentType: 'application/json'),
      );

      // Handle successful response
      if (response.statusCode == 200) {
        log('Notification marked as read successfully: $notificationId');

        return ApiResponse<bool>(
          success: true,
          message: 'Notification marked as read successfully',
          data: true,
          statusCode: response.statusCode,
        );
      } else {
        return _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      log('DioException in markNotificationAsRead: ${e.message}');
      return _handleDioError(e);
    } catch (e) {
      log('Unexpected error in markNotificationAsRead: $e');
      return ApiResponse<bool>(
        success: false,
        message:
            'An unexpected error occurred while marking notification as read: ${e.toString()}',
      );
    }
  }

  // Mark all notifications as read
  static Future<ApiResponse<bool>> markAllNotificationsAsRead() async {
    try {
      log('Marking all notifications as read...');

      // Check internet connection
      if (!await ConnectivityService.hasInternetConnection()) {
        return ApiResponse<bool>(
          success: false,
          message: 'No internet connection. Please check your network.',
        );
      }

      // Initialize Dio if not already done
      NotificationService()._initializeDio();

      final response = await _dio.put(
        '$notificationEndpoint/read/all',
        options: Options(contentType: 'application/json'),
      );

      // Handle successful response
      if (response.statusCode == 200) {
        log('All notifications marked as read successfully');

        return ApiResponse<bool>(
          success: true,
          message: 'All notifications marked as read successfully',
          data: true,
          statusCode: response.statusCode,
        );
      } else {
        return _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      log('DioException in markAllNotificationsAsRead: ${e.message}');
      return _handleDioError(e);
    } catch (e) {
      log('Unexpected error in markAllNotificationsAsRead: $e');
      return ApiResponse<bool>(
        success: false,
        message:
            'An unexpected error occurred while marking all notifications as read: ${e.toString()}',
      );
    }
  }

  // Update notification status
  static Future<ApiResponse<bool>> updateNotificationStatus(
    String notificationId,
    String status,
  ) async {
    try {
      log('Updating notification status: $notificationId to $status');

      // Check internet connection
      if (!await ConnectivityService.hasInternetConnection()) {
        return ApiResponse<bool>(
          success: false,
          message: 'No internet connection. Please check your network.',
        );
      }

      // Initialize Dio if not already done
      NotificationService()._initializeDio();

      // Validate required fields
      if (notificationId.isEmpty || status.isEmpty) {
        return ApiResponse<bool>(
          success: false,
          message: 'Notification ID and status are required.',
        );
      }

      final response = await _dio.put(
        '$notificationEndpoint/$notificationId/status',
        data: {'status': status},
        options: Options(contentType: 'application/json'),
      );

      // Handle successful response
      if (response.statusCode == 200) {
        log('Notification status updated successfully: $notificationId');

        return ApiResponse<bool>(
          success: true,
          message: 'Notification status updated successfully',
          data: true,
          statusCode: response.statusCode,
        );
      } else {
        return _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      log('DioException in updateNotificationStatus: ${e.message}');
      return _handleDioError(e);
    } catch (e) {
      log('Unexpected error in updateNotificationStatus: $e');
      return ApiResponse<bool>(
        success: false,
        message:
            'An unexpected error occurred while updating notification status: ${e.toString()}',
      );
    }
  }

  // Handle error responses
  static ApiResponse<T> _handleErrorResponse<T>(Response response) {
    try {
      final Map<String, dynamic> responseData =
          response.data is Map<String, dynamic>
          ? response.data
          : <String, dynamic>{};

      // Handle message that can be either String or List<String>
      String getMessage(dynamic message) {
        if (message is String) {
          return message;
        } else if (message is List) {
          return message.join(', ');
        }
        return '';
      }

      switch (response.statusCode) {
        case 400:
          return ApiResponse<T>(
            success: false,
            message: getMessage(responseData['message']) ?? 'Bad request',
            statusCode: response.statusCode,
          );
        case 401:
          return ApiResponse<T>(
            success: false,
            message: 'Unauthorized access',
            statusCode: response.statusCode,
          );
        case 403:
          return ApiResponse<T>(
            success: false,
            message: 'Access forbidden',
            statusCode: response.statusCode,
          );
        case 404:
          return ApiResponse<T>(
            success: false,
            message: 'Notification not found',
            statusCode: response.statusCode,
          );
        case 422:
          return ApiResponse<T>(
            success: false,
            message: getMessage(responseData['message']) ?? 'Validation failed',
            statusCode: response.statusCode,
          );
        case 500:
          return ApiResponse<T>(
            success: false,
            message: 'Server error. Please try again later.',
            statusCode: response.statusCode,
          );
        default:
          return ApiResponse<T>(
            success: false,
            message:
                getMessage(responseData['message']) ?? 'Unknown error occurred',
            statusCode: response.statusCode,
          );
      }
    } catch (e) {
      log('Failed to parse error response: $e');
      return ApiResponse<T>(
        success: false,
        message: 'Failed to parse server response',
        statusCode: response.statusCode,
      );
    }
  }

  // Handle Dio errors
  static ApiResponse<T> _handleDioError<T>(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiResponse<T>(
          success: false,
          message: 'Connection timeout. Please check your internet connection.',
        );
      case DioExceptionType.connectionError:
        return ApiResponse<T>(
          success: false,
          message: 'No internet connection. Please check your network.',
        );
      case DioExceptionType.badResponse:
        // Handle HTTP error responses
        if (e.response != null) {
          return _handleErrorResponse(e.response!);
        }
        return ApiResponse<T>(
          success: false,
          message: 'Server error occurred. Please try again.',
        );
      case DioExceptionType.cancel:
        return ApiResponse<T>(
          success: false,
          message: 'Request was cancelled.',
        );
      case DioExceptionType.unknown:
        return ApiResponse<T>(
          success: false,
          message: 'An unexpected error occurred. Please try again.',
        );
      default:
        return ApiResponse<T>(
          success: false,
          message: 'Network error occurred: ${e.message}',
        );
    }
  }
}
