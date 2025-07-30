// group_chat_service.dart

import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:get/get.dart' as token;
import '../../core/constant/api_url.dart';
import '../../core/helpers/internet_connection.dart';
import '../controller/auth/login_controller.dart';
import '../model/api_response_model.dart';
import '../model/group chat/group_chat_model.dart';

class GroupChatService {
  static const String groupChatEndpoint = '/group-chat';

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

  // Send a message to group chat
  static Future<ApiResponse<GroupChatModel>> sendMessage(
    String message,
    String courseId,
  ) async {
    try {
      log('Sending message to group chat for course: $courseId');

      // Check internet connection
      if (!await ConnectivityService.hasInternetConnection()) {
        return ApiResponse<GroupChatModel>(
          success: false,
          message: 'No internet connection. Please check your network.',
        );
      }

      // Initialize Dio if not already done
      GroupChatService()._initializeDio();

      // Validate required fields
      if (message.isEmpty || courseId.isEmpty) {
        return ApiResponse<GroupChatModel>(
          success: false,
          message: 'Message and course ID are required.',
        );
      }

      final response = await _dio.post(
        groupChatEndpoint,
        data: {'message': message.trim(), 'courseId': courseId.trim()},
        options: Options(contentType: 'application/json'),
      );

      log('Send message response: ${response.data}');

      // Handle successful response
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse<GroupChatModel>(
          success: true,
          message: 'Message sent successfully',
          data: GroupChatModel.fromJson(response.data),
          statusCode: response.statusCode,
        );
      } else {
        return _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      log('DioException in sendMessage: ${e.message}');
      return _handleDioError(e);
    } catch (e) {
      log('Unexpected error in sendMessage: $e');
      return ApiResponse<GroupChatModel>(
        success: false,
        message:
            'An unexpected error occurred while sending message: ${e.toString()}',
      );
    }
  }

  // Get all messages for a course
  static Future<ApiResponse<List<GroupChatModel>>> getCourseMessages(
    String courseId,
  ) async {
    try {
      log('Fetching messages for course: $courseId');

      // Check internet connection
      if (!await ConnectivityService.hasInternetConnection()) {
        return ApiResponse<List<GroupChatModel>>(
          success: false,
          message: 'No internet connection. Please check your network.',
        );
      }

      // Initialize Dio if not already done
      GroupChatService()._initializeDio();

      // Validate required fields
      if (courseId.isEmpty) {
        return ApiResponse<List<GroupChatModel>>(
          success: false,
          message: 'Course ID is required.',
        );
      }

      final response = await _dio.get(
        '$groupChatEndpoint/$courseId',
        options: Options(contentType: 'application/json'),
      );

      log('Course messages response: ${response.data}');

      // Handle successful response
      if (response.statusCode == 200) {
        try {
          List<GroupChatModel> messages = [];

          // Check if response.data is a List directly
          if (response.data is List) {
            messages = (response.data as List)
                .map((messageJson) => GroupChatModel.fromJson(messageJson))
                .toList();
          }
          // Or if it's wrapped in an object like {messages: [...]}
          else if (response.data is Map<String, dynamic>) {
            final data = response.data as Map<String, dynamic>;
            if (data.containsKey('messages') && data['messages'] is List) {
              messages = (data['messages'] as List)
                  .map((messageJson) => GroupChatModel.fromJson(messageJson))
                  .toList();
            } else if (data.containsKey('data') && data['data'] is List) {
              messages = (data['data'] as List)
                  .map((messageJson) => GroupChatModel.fromJson(messageJson))
                  .toList();
            }
          }

          log('Parsed ${messages.length} messages successfully');

          return ApiResponse<List<GroupChatModel>>(
            success: true,
            message: 'Messages fetched successfully',
            data: messages,
            statusCode: response.statusCode,
          );
        } catch (parseError) {
          log('Error parsing messages: $parseError');
          return ApiResponse<List<GroupChatModel>>(
            success: false,
            message: 'Failed to parse message data: ${parseError.toString()}',
            statusCode: response.statusCode,
          );
        }
      } else {
        return _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      log('DioException in getCourseMessages: ${e.message}');
      return _handleDioError(e);
    } catch (e) {
      log('Unexpected error in getCourseMessages: $e');
      return ApiResponse<List<GroupChatModel>>(
        success: false,
        message:
            'An unexpected error occurred while fetching messages: ${e.toString()}',
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
            message: 'Chat or course not found',
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
