// course_lesson_service.dart

import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart' as token;
import 'package:http_parser/http_parser.dart';
import '../../core/constant/api_url.dart';
import '../../core/helpers/internet_connection.dart';
import '../controller/auth/login_controller.dart';
import '../model/api_response_model.dart';
import '../model/course/course_lesson_model.dart';

class CourseLessonService {
  static const String courseLessonEndpoint = '/lessons';
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

  // Get all lessons for a specific course
  static Future<ApiResponse<List<CourseLessonModel>>> getCourseLessons(
    String courseId,
  ) async {
    try {
      log('Fetching lessons for course: $courseId');

      // Check internet connection
      if (!await ConnectivityService.hasInternetConnection()) {
        return ApiResponse<List<CourseLessonModel>>(
          success: false,
          message: 'No internet connection. Please check your network.',
        );
      }

      // Validate course ID
      if (courseId.isEmpty) {
        return ApiResponse<List<CourseLessonModel>>(
          success: false,
          message: 'Course ID is required.',
        );
      }

      // Initialize Dio if not already done
      CourseLessonService()._initializeDio();

      final response = await _dio.get(
        "$courseLessonEndpoint/$courseId",
        options: Options(contentType: 'application/json'),
      );

      log('Course lessons response: ${response.data}');

      // Handle successful response
      if (response.statusCode == 200) {
        try {
          List<CourseLessonModel> lessons = [];

          // Check if response.data is a List directly
          if (response.data is List) {
            lessons = (response.data as List)
                .map((lessonJson) => CourseLessonModel.fromJson(lessonJson))
                .toList();
          }
          // Or if it's wrapped in an object like {lessons: [...]}
          else if (response.data is Map<String, dynamic>) {
            final data = response.data as Map<String, dynamic>;
            if (data.containsKey('lessons') && data['lessons'] is List) {
              lessons = (data['lessons'] as List)
                  .map((lessonJson) => CourseLessonModel.fromJson(lessonJson))
                  .toList();
            } else if (data.containsKey('data') && data['data'] is List) {
              lessons = (data['data'] as List)
                  .map((lessonJson) => CourseLessonModel.fromJson(lessonJson))
                  .toList();
            }
          }

          log('Parsed ${lessons.length} lessons successfully');

          return ApiResponse<List<CourseLessonModel>>(
            success: true,
            message: 'Lessons fetched successfully',
            data: lessons,
            statusCode: response.statusCode,
          );
        } catch (parseError) {
          log('Error parsing lessons: $parseError');
          return ApiResponse<List<CourseLessonModel>>(
            success: false,
            message: 'Failed to parse lesson data: ${parseError.toString()}',
            statusCode: response.statusCode,
          );
        }
      } else {
        return _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      log('DioException in getCourseLessons: ${e.message}');
      return _handleDioError(e);
    } catch (e) {
      log('Unexpected error in getCourseLessons: $e');
      return ApiResponse<List<CourseLessonModel>>(
        success: false,
        message:
            'An unexpected error occurred while fetching lessons: ${e.toString()}',
      );
    }
  }

  // Get a specific lesson by ID
  static Future<ApiResponse<CourseLessonModel>> getCourseLessonByID(
    String courseId,
    String lessonId,
  ) async {
    try {
      log('Fetching lesson: $lessonId for course: $courseId');

      // Check internet connection
      if (!await ConnectivityService.hasInternetConnection()) {
        return ApiResponse<CourseLessonModel>(
          success: false,
          message: 'No internet connection. Please check your network.',
        );
      }

      // Validate IDs
      if (courseId.isEmpty || lessonId.isEmpty) {
        return ApiResponse<CourseLessonModel>(
          success: false,
          message: 'Course ID and Lesson ID are required.',
        );
      }

      // Initialize Dio if not already done
      CourseLessonService()._initializeDio();

      final response = await _dio.get(
        '$courseLessonEndpoint/$courseId/lessons/$lessonId',
        options: Options(contentType: 'application/json'),
      );

      log('Course lesson response: ${response.data}');

      // Handle successful response
      if (response.statusCode == 200) {
        try {
          CourseLessonModel lesson;

          // Parse the lesson from response
          if (response.data is Map<String, dynamic>) {
            final data = response.data as Map<String, dynamic>;

            // Check different possible response structures
            if (data.containsKey('lesson')) {
              lesson = CourseLessonModel.fromJson(data['lesson']);
            } else if (data.containsKey('data')) {
              lesson = CourseLessonModel.fromJson(data['data']);
            } else {
              lesson = CourseLessonModel.fromJson(data);
            }
          } else {
            throw Exception('Invalid response format');
          }

          log('Lesson fetched successfully: ${lesson.title}');

          return ApiResponse<CourseLessonModel>(
            success: true,
            message: 'Lesson fetched successfully',
            data: lesson,
            statusCode: response.statusCode,
          );
        } catch (parseError) {
          log('Error parsing lesson: $parseError');
          return ApiResponse<CourseLessonModel>(
            success: false,
            message: 'Failed to parse lesson data: ${parseError.toString()}',
            statusCode: response.statusCode,
          );
        }
      } else {
        return _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      log('DioException in getCourseLesson: ${e.message}');
      return _handleDioError(e);
    } catch (e) {
      log('Unexpected error in getCourseLesson: $e');
      return ApiResponse<CourseLessonModel>(
        success: false,
        message:
            'An unexpected error occurred while fetching lesson: ${e.toString()}',
      );
    }
  }

  // Create a new lesson for a course
  static Future<ApiResponse<CourseLessonModel>> createCourseLesson(
    String courseId,
    String title,
    String description,
    int readingDuration,
    List<String> keywords, {
    String? pdfPath,
  }) async {
    try {
      log('Creating new lesson: $title for course: $courseId');

      // Check internet connection
      if (!await ConnectivityService.hasInternetConnection()) {
        return ApiResponse<CourseLessonModel>(
          success: false,
          message: 'No internet connection. Please check your network.',
        );
      }

      // Initialize Dio if not already done
      CourseLessonService()._initializeDio();

      // Validate required fields
      if (courseId.isEmpty ||
          title.isEmpty ||
          description.isEmpty ||
          readingDuration <= 0) {
        return ApiResponse<CourseLessonModel>(
          success: false,
          message:
              'Course ID, title, description, and reading duration are required.',
        );
      }

      // Check if PDF is provided and exists
      bool hasPdf =
          pdfPath != null && pdfPath.isNotEmpty && File(pdfPath).existsSync();

      Response response;

      if (hasPdf) {
        // Create FormData for request with PDF
        FormData formData = FormData();

        // Add text fields
        formData.fields.add(MapEntry('title', title.trim()));
        formData.fields.add(MapEntry('description', description.trim()));
        formData.fields.add(
          MapEntry('readingDuration', readingDuration.toString()),
        );

        // Add keywords as separate fields or as JSON array
        for (int i = 0; i < keywords.length; i++) {
          formData.fields.add(MapEntry('keywords[$i]', keywords[i]));
        }

        // Add PDF file
        final file = File(pdfPath);
        formData.files.add(
          MapEntry(
            'pdfUrl',
            await MultipartFile.fromFile(
              file.path,
              filename: file.path.split('/').last,
              contentType: MediaType('application', 'pdf'),
            ),
          ),
        );

        // Log all fields
        log('--- FormData Fields ---');
        for (final field in formData.fields) {
          log('${field.key}: ${field.value}');
        }

        // Log all files
        log('--- FormData Files ---');
        for (final fileEntry in formData.files) {
          final file = fileEntry.value;
          log('${fileEntry.key}: ${file.filename} (${file.length} bytes)');
        }

        // Send request with FormData (multipart)
        response = await _dio.post(
          '$courseLessonEndpoint/$courseId',
          data: formData,
        );
      } else {
        // Send request with JSON data only (no PDF)
        response = await _dio.post(
          '$courseLessonEndpoint/$courseId',
          data: {
            'title': title.trim(),
            'description': description.trim(),
            'readingDuration': readingDuration,
            'keywords': keywords,
          },
          options: Options(contentType: 'application/json'),
        );
      }

      // Handle successful response
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          CourseLessonModel lesson;

          // Parse the created lesson from response
          if (response.data is Map<String, dynamic>) {
            final data = response.data as Map<String, dynamic>;

            // Check different possible response structures
            if (data.containsKey('lesson')) {
              lesson = CourseLessonModel.fromJson(data['lesson']);
            } else if (data.containsKey('data')) {
              lesson = CourseLessonModel.fromJson(data['data']);
            } else {
              lesson = CourseLessonModel.fromJson(data);
            }
          } else {
            throw Exception('Invalid response format');
          }

          log('Lesson created successfully: ${lesson.title}');

          return ApiResponse<CourseLessonModel>(
            success: true,
            message: 'Lesson created successfully',
            data: lesson,
            statusCode: response.statusCode,
          );
        } catch (parseError) {
          log('Error parsing created lesson: $parseError');
          return ApiResponse<CourseLessonModel>(
            success: false,
            message:
                'Lesson created but failed to parse response: ${parseError.toString()}',
            statusCode: response.statusCode,
          );
        }
      } else {
        return _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      log('DioException in createCourseLesson: ${e.message}');
      return _handleDioError(e);
    } catch (e) {
      log('Unexpected error in createCourseLesson: $e');
      return ApiResponse<CourseLessonModel>(
        success: false,
        message:
            'An unexpected error occurred while creating lesson: ${e.toString()}',
      );
    }
  }

  // Update an existing lesson
  static Future<ApiResponse<CourseLessonModel>> updateCourseLesson(
    String courseId,
    String lessonId,
    String title,
    String description,
    int readingDuration,
    List<String> keywords, {
    String? pdfPath,
  }) async {
    try {
      log('Updating lesson: $lessonId for course: $courseId');

      // Check internet connection
      if (!await ConnectivityService.hasInternetConnection()) {
        return ApiResponse<CourseLessonModel>(
          success: false,
          message: 'No internet connection. Please check your network.',
        );
      }

      // Initialize Dio if not already done
      CourseLessonService()._initializeDio();

      // Validate required fields
      if (courseId.isEmpty ||
          lessonId.isEmpty ||
          title.isEmpty ||
          description.isEmpty ||
          readingDuration <= 0) {
        return ApiResponse<CourseLessonModel>(
          success: false,
          message:
              'Course ID, Lesson ID, title, description, and reading duration are required.',
        );
      }

      // Check if PDF is provided and exists
      bool hasPdf =
          pdfPath != null && pdfPath.isNotEmpty && File(pdfPath).existsSync();

      Response response;

      if (hasPdf) {
        // Create FormData for request with PDF
        FormData formData = FormData();

        // Add text fields
        formData.fields.add(MapEntry('title', title.trim()));
        formData.fields.add(MapEntry('description', description.trim()));
        formData.fields.add(
          MapEntry('readingDuration', readingDuration.toString()),
        );

        // Add keywords as separate fields or as JSON array
        for (int i = 0; i < keywords.length; i++) {
          formData.fields.add(MapEntry('keywords[$i]', keywords[i]));
        }

        // Add PDF file
        final file = File(pdfPath);
        formData.files.add(
          MapEntry(
            'pdfUrl',
            await MultipartFile.fromFile(
              file.path,
              filename: file.path.split('/').last,
              contentType: MediaType('application', 'pdf'),
            ),
          ),
        );

        // Send request with FormData (multipart)
        response = await _dio.put(
          '$courseLessonEndpoint/$lessonId',
          // '$courseLessonEndpoint/$courseId/lessons/$lessonId',
          data: formData,
        );
      } else {
        // Send request with JSON data only (no PDF)
        response = await _dio.put(
          '$courseLessonEndpoint/$lessonId',
          data: {
            'title': title.trim(),
            'description': description.trim(),
            'readingDuration': readingDuration,
            'keywords': keywords,
          },
          options: Options(contentType: 'application/json'),
        );
      }

      // Handle successful response
      if (response.statusCode == 200) {
        try {
          CourseLessonModel lesson;

          // Parse the updated lesson from response
          if (response.data is Map<String, dynamic>) {
            final data = response.data as Map<String, dynamic>;

            // Check different possible response structures
            if (data.containsKey('lesson')) {
              lesson = CourseLessonModel.fromJson(data['lesson']);
            } else if (data.containsKey('data')) {
              lesson = CourseLessonModel.fromJson(data['data']);
            } else {
              lesson = CourseLessonModel.fromJson(data);
            }
          } else {
            throw Exception('Invalid response format');
          }

          log('Lesson updated successfully: ${lesson.title}');

          return ApiResponse<CourseLessonModel>(
            success: true,
            message: 'Lesson updated successfully',
            data: lesson,
            statusCode: response.statusCode,
          );
        } catch (parseError) {
          log('Error parsing updated lesson: $parseError');
          return ApiResponse<CourseLessonModel>(
            success: false,
            message:
                'Lesson updated but failed to parse response: ${parseError.toString()}',
            statusCode: response.statusCode,
          );
        }
      } else {
        return _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      log('DioException in updateCourseLesson: ${e.message}');
      return _handleDioError(e);
    } catch (e) {
      log('Unexpected error in updateCourseLesson: $e');
      return ApiResponse<CourseLessonModel>(
        success: false,
        message:
            'An unexpected error occurred while updating lesson: ${e.toString()}',
      );
    }
  }

  // Delete a lesson
  static Future<ApiResponse<bool>> deleteCourseLesson(
    String courseId,
    String lessonId,
  ) async {
    try {
      log('Deleting lesson: $lessonId from course: $courseId');

      // Check internet connection
      if (!await ConnectivityService.hasInternetConnection()) {
        return ApiResponse<bool>(
          success: false,
          message: 'No internet connection. Please check your network.',
        );
      }

      // Initialize Dio if not already done
      CourseLessonService()._initializeDio();

      // Validate required fields
      if (courseId.isEmpty || lessonId.isEmpty) {
        return ApiResponse<bool>(
          success: false,
          message: 'Course ID and Lesson ID are required.',
        );
      }

      final response = await _dio.delete(
        '$courseLessonEndpoint/$lessonId',
        // '$courseLessonEndpoint/$courseId/lessons/$lessonId',
        options: Options(contentType: 'application/json'),
      );

      // Handle successful response
      if (response.statusCode == 200 || response.statusCode == 204) {
        log('Lesson deleted successfully: $lessonId');

        return ApiResponse<bool>(
          success: true,
          message: 'Lesson deleted successfully',
          data: true,
          statusCode: response.statusCode,
        );
      } else {
        return _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      log('DioException in deleteCourseLesson: ${e.message}');
      return _handleDioError(e);
    } catch (e) {
      log('Unexpected error in deleteCourseLesson: $e');
      return ApiResponse<bool>(
        success: false,
        message:
            'An unexpected error occurred while deleting lesson: ${e.toString()}',
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
            message: 'Course or lesson not found',
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
