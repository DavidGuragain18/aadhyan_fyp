// test_question_service.dart

import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:get/get.dart' as token;
import '../../core/constant/api_url.dart';
import '../../core/helpers/internet_connection.dart';
import '../controller/auth/login_controller.dart';
import '../model/api_response_model.dart';
import '../model/course/course_test_model.dart';

class CourseTestServices {
  static const String courseTestQuestionEndpoint = '/course-tests';

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

  static Future<ApiResponse<List<CourseTestModel>>> getTestQuestionList({
    required String courseId,
  }) async {
    try {
      log('Fetching test question list for course: $courseId');

      // Check internet connection
      if (!await ConnectivityService.hasInternetConnection()) {
        return ApiResponse<List<CourseTestModel>>(
          success: false,
          message: 'No internet connection. Please check your network.',
        );
      }

      // Validate required fields
      if (courseId.isEmpty) {
        return ApiResponse<List<CourseTestModel>>(
          success: false,
          message: 'course ID is required.',
        );
      }

      // Initialize Dio if not already done
      CourseTestServices()._initializeDio();

      final response = await _dio.get(
        '$courseTestQuestionEndpoint/$courseId',
        options: Options(contentType: 'application/json'),
      );

      log('course Test question list response: ${response.data}');

      // Handle successful response
      if (response.statusCode == 200) {
        try {
          List<CourseTestModel> testQuestions = [];

          // Check if response.data is a List directly
          if (response.data is List) {
            testQuestions = (response.data as List)
                .map((questionJson) => CourseTestModel.fromJson(questionJson))
                .toList();
          }
          // Or if it's wrapped in an object like {questions: [...]} or {data: [...]}
          else if (response.data is Map<String, dynamic>) {
            final data = response.data as Map<String, dynamic>;
            if (data.containsKey('questions') && data['questions'] is List) {
              testQuestions = (data['questions'] as List)
                  .map((questionJson) => CourseTestModel.fromJson(questionJson))
                  .toList();
            } else if (data.containsKey('data') && data['data'] is List) {
              testQuestions = (data['data'] as List)
                  .map((questionJson) => CourseTestModel.fromJson(questionJson))
                  .toList();
            }
          }

          log('Parsed ${testQuestions.length} test questions successfully');

          return ApiResponse<List<CourseTestModel>>(
            success: true,
            message: 'Test questions fetched successfully',
            data: testQuestions,
            statusCode: response.statusCode,
          );
        } catch (parseError) {
          log('Error parsing test questions: $parseError');
          return ApiResponse<List<CourseTestModel>>(
            success: false,
            message:
                'Failed to parse test question data: ${parseError.toString()}',
            statusCode: response.statusCode,
          );
        }
      } else {
        return _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      log('DioException in getTestQuestionList: ${e.message}');
      return _handleDioError(e);
    } catch (e) {
      log('Unexpected error in getTestQuestionList: $e');
      return ApiResponse<List<CourseTestModel>>(
        success: false,
        message:
            'An unexpected error occurred while fetching test questions: ${e.toString()}',
      );
    }
  }

  static Future<ApiResponse<CourseTestModel>> getTestQuestionById({
    required String courseId,
    required String testId,
  }) async {
    try {
      log('Fetching test question by ID: $testId for course: $courseId');

      // Check internet connection
      if (!await ConnectivityService.hasInternetConnection()) {
        return ApiResponse<CourseTestModel>(
          success: false,
          message: 'No internet connection. Please check your network.',
        );
      }

      // Validate required fields
      if (courseId.isEmpty || testId.isEmpty) {
        return ApiResponse<CourseTestModel>(
          success: false,
          message: 'Course ID and Test ID are required.',
        );
      }

      // Initialize Dio if not already done
      CourseTestServices()._initializeDio();

      final response = await _dio.get(
        '$courseTestQuestionEndpoint/$testId',
        options: Options(contentType: 'application/json'),
      );

      log('Test question response: ${response.data}');

      // Handle successful response
      if (response.statusCode == 200) {
        try {
          CourseTestModel testQuestion;

          // Parse the test question from response
          if (response.data is Map<String, dynamic>) {
            final data = response.data as Map<String, dynamic>;

            // Check different possible response structures
            if (data.containsKey('question')) {
              testQuestion = CourseTestModel.fromJson(data['question']);
            } else if (data.containsKey('data')) {
              testQuestion = CourseTestModel.fromJson(data['data']);
            } else {
              testQuestion = CourseTestModel.fromJson(data);
            }
          } else {
            throw Exception('Invalid response format');
          }

          log('Test question fetched successfully: ${testQuestion.title}');

          return ApiResponse<CourseTestModel>(
            success: true,
            message: 'Test question fetched successfully',
            data: testQuestion,
            statusCode: response.statusCode,
          );
        } catch (parseError) {
          log('Error parsing test question: $parseError');
          return ApiResponse<CourseTestModel>(
            success: false,
            message:
                'Failed to parse test question data: ${parseError.toString()}',
            statusCode: response.statusCode,
          );
        }
      } else {
        return _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      log('DioException in getTestQuestionById: ${e.message}');
      return _handleDioError(e);
    } catch (e) {
      log('Unexpected error in getTestQuestionById: $e');
      return ApiResponse<CourseTestModel>(
        success: false,
        message:
            'An unexpected error occurred while fetching test question: ${e.toString()}',
      );
    }
  }

  static Future<ApiResponse<CourseTestModel>> createTestQuestion({
    required String courseId,
    required String title,
    required List<CourseTestQuestion> questions,
    required int correctAnswer,
  }) async {
    try {
      log('Creating new test question for course: $courseId');

      // Check internet connection
      if (!await ConnectivityService.hasInternetConnection()) {
        return ApiResponse<CourseTestModel>(
          success: false,
          message: 'No internet connection. Please check your network.',
        );
      }

      // Initialize Dio if not already done
      CourseTestServices()._initializeDio();

      // Validate required fields
      if (courseId.isEmpty || title.isEmpty || questions.isEmpty) {
        return ApiResponse<CourseTestModel>(
          success: false,
          message: 'course ID, title, and questions are required.',
        );
      }

      final requestData = {
        'title': title.trim(),
        'course': courseId.trim(),
        'questions': questions.map((q) => q.toJson()).toList(),
        'correctAnswer': correctAnswer,
      };

      final response = await _dio.post(
        '$courseTestQuestionEndpoint',
        data: requestData,
        options: Options(contentType: 'application/json'),
      );

      log('Create test question response: ${response.data}');

      // Handle successful response
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          CourseTestModel testQuestion;

          // Parse the created test question from response
          if (response.data is Map<String, dynamic>) {
            final data = response.data as Map<String, dynamic>;

            // Check different possible response structures
            if (data.containsKey('question')) {
              testQuestion = CourseTestModel.fromJson(data['question']);
            } else if (data.containsKey('data')) {
              testQuestion = CourseTestModel.fromJson(data['data']);
            } else {
              testQuestion = CourseTestModel.fromJson(data);
            }
          } else {
            throw Exception('Invalid response format');
          }

          log('Test question created successfully: ${testQuestion.title}');

          return ApiResponse<CourseTestModel>(
            success: true,
            message: 'Test question created successfully',
            data: testQuestion,
            statusCode: response.statusCode,
          );
        } catch (parseError) {
          log('Error parsing created test question: $parseError');
          return ApiResponse<CourseTestModel>(
            success: false,
            message:
                'Test question created but failed to parse response: ${parseError.toString()}',
            statusCode: response.statusCode,
          );
        }
      } else {
        return _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      log('DioException in createTestQuestion: ${e.message}');
      return _handleDioError(e);
    } catch (e) {
      log('Unexpected error in createTestQuestion: $e');
      return ApiResponse<CourseTestModel>(
        success: false,
        message:
            'An unexpected error occurred while creating test question: ${e.toString()}',
      );
    }
  }

  // Modified deleteTestQuestion method - now requires courseId parameter
  static Future<ApiResponse<bool>> deleteTestQuestion({
    required String courseId,
    required String testId,
  }) async {
    try {
      log('Deleting test question: $testId for course: $courseId');

      // Check internet connection
      if (!await ConnectivityService.hasInternetConnection()) {
        return ApiResponse<bool>(
          success: false,
          message: 'No internet connection. Please check your network.',
        );
      }

      // Initialize Dio if not already done
      CourseTestServices()._initializeDio();

      // Validate required fields
      if (courseId.isEmpty || testId.isEmpty) {
        return ApiResponse<bool>(
          success: false,
          message: 'course ID and Test ID are required.',
        );
      }

      final response = await _dio.delete(
        '$courseTestQuestionEndpoint/$testId',
        options: Options(contentType: 'application/json'),
      );

      log('Delete test question response: ${response.statusCode}');

      // Handle successful response
      if (response.statusCode == 200 || response.statusCode == 204) {
        log('Test question deleted successfully: $testId');

        return ApiResponse<bool>(
          success: true,
          message: 'Test question deleted successfully',
          data: true,
          statusCode: response.statusCode,
        );
      } else {
        return _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      log('DioException in deleteTestQuestion: ${e.message}');
      return _handleDioError(e);
    } catch (e) {
      log('Unexpected error in deleteTestQuestion: $e');
      return ApiResponse<bool>(
        success: false,
        message:
            'An unexpected error occurred while deleting test question: ${e.toString()}',
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
            message: 'Test question not found',
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
