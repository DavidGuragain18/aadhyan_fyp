// course_service.dart

import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart' as token;
import '../../core/constant/api_url.dart';
import '../../core/helpers/internet_connection.dart';
import '../controller/auth/login_controller.dart';
import '../model/api_response_model.dart';
import '../model/course/course_model.dart';

class CourseService {
  static const String courseEndpoint = '/course';

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

  // Get all courses
  static Future<ApiResponse<List<CourseModel>>> getCourseList() async {
    try {
      log('Fetching course list...');

      // Check internet connection
      if (!await ConnectivityService.hasInternetConnection()) {
        return ApiResponse<List<CourseModel>>(
          success: false,
          message: 'No internet connection. Please check your network.',
        );
      }

      // Initialize Dio if not already done
      CourseService()._initializeDio();

      final response = await _dio.get(
        courseEndpoint,
        options: Options(contentType: 'application/json'),
      );

      log('Course list response: ${response.data}');

      // Handle successful response
      if (response.statusCode == 200) {
        try {
          List<CourseModel> courses = [];

          // Check if response.data is a List directly (your current format)
          if (response.data is List) {
            courses = (response.data as List)
                .map((courseJson) => CourseModel.fromJson(courseJson))
                .toList();
          }
          // Or if it's wrapped in an object like {courses: [...]}
          else if (response.data is Map<String, dynamic>) {
            final data = response.data as Map<String, dynamic>;
            if (data.containsKey('courses') && data['courses'] is List) {
              courses = (data['courses'] as List)
                  .map((courseJson) => CourseModel.fromJson(courseJson))
                  .toList();
            } else if (data.containsKey('data') && data['data'] is List) {
              courses = (data['data'] as List)
                  .map((courseJson) => CourseModel.fromJson(courseJson))
                  .toList();
            }
          }

          log('Parsed ${courses.length} courses successfully');

          return ApiResponse<List<CourseModel>>(
            success: true,
            message: 'Courses fetched successfully',
            data: courses,
            statusCode: response.statusCode,
          );
        } catch (parseError) {
          log('Error parsing courses: $parseError');
          return ApiResponse<List<CourseModel>>(
            success: false,
            message: 'Failed to parse course data: ${parseError.toString()}',
            statusCode: response.statusCode,
          );
        }
      } else {
        return _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      log('DioException in getCourseList: ${e.message}');
      return _handleDioError(e);
    } catch (e) {
      log('Unexpected error in getCourseList: $e');
      return ApiResponse<List<CourseModel>>(
        success: false,
        message:
            'An unexpected error occurred while fetching courses: ${e.toString()}',
      );
    }
  }

  // Create a new course
  static Future<ApiResponse<CourseModel>> createCourse(
    String title,
    String description, {
    String? image,
  }) async {
    try {
      log('Creating new course: $title');

      // Check internet connection
      if (!await ConnectivityService.hasInternetConnection()) {
        return ApiResponse<CourseModel>(
          success: false,
          message: 'No internet connection. Please check your network.',
        );
      }

      // Initialize Dio if not already done
      CourseService()._initializeDio();

      // Validate required fields
      if (title.isEmpty || description.isEmpty) {
        return ApiResponse<CourseModel>(
          success: false,
          message: 'Title and description are required.',
        );
      }

      // Check if image is provided and exists
      bool hasImage =
          image != null && image.isNotEmpty && File(image).existsSync();

      Response response;

      if (hasImage) {
        // Create FormData for request with image
        FormData formData = FormData();

        // Add text fields
        formData.fields.add(MapEntry('title', title.trim()));
        formData.fields.add(MapEntry('description', description.trim()));

        // Add image file
        final file = File(image);
        formData.files.add(
          MapEntry(
            'coverImage',
            await MultipartFile.fromFile(
              file.path,
              filename: file.path.split('/').last,
            ),
          ),
        );

        // Send request with FormData (multipart)
        response = await _dio.post(courseEndpoint, data: formData);
      } else {
        // Send request with JSON data only (no image)
        response = await _dio.post(
          courseEndpoint,
          data: {'title': title.trim(), 'description': description.trim()},
          options: Options(contentType: 'application/json'),
        );
      }

      // Handle successful response
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          CourseModel course;

          // Parse the created course from response
          if (response.data is Map<String, dynamic>) {
            final data = response.data as Map<String, dynamic>;

            // Check different possible response structures
            if (data.containsKey('course')) {
              course = CourseModel.fromJson(data['course']);
            } else if (data.containsKey('data')) {
              course = CourseModel.fromJson(data['data']);
            } else {
              course = CourseModel.fromJson(data);
            }
          } else {
            throw Exception('Invalid response format');
          }

          log('Course created successfully: ${course.title}');

          return ApiResponse<CourseModel>(
            success: true,
            message: 'Course created successfully',
            data: course,
            statusCode: response.statusCode,
          );
        } catch (parseError) {
          log('Error parsing created course: $parseError');
          return ApiResponse<CourseModel>(
            success: false,
            message:
                'Course created but failed to parse response: ${parseError.toString()}',
            statusCode: response.statusCode,
          );
        }
      } else {
        return _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      log('DioException in createCourse: ${e.message}');
      return _handleDioError(e);
    } catch (e) {
      log('Unexpected error in createCourse: $e');
      return ApiResponse<CourseModel>(
        success: false,
        message:
            'An unexpected error occurred while creating course: ${e.toString()}',
      );
    }
  }

  // Update an existing course
  static Future<ApiResponse<CourseModel>> updateCourse(
    String courseId,
    String title,
    String description, {
    String? imagePath,
  }) async {
    try {
      log('Updating course: $courseId');

      // Check internet connection
      if (!await ConnectivityService.hasInternetConnection()) {
        return ApiResponse<CourseModel>(
          success: false,
          message: 'No internet connection. Please check your network.',
        );
      }

      // Initialize Dio if not already done
      CourseService()._initializeDio();

      // Validate required fields
      if (courseId.isEmpty || title.isEmpty || description.isEmpty) {
        return ApiResponse<CourseModel>(
          success: false,
          message: 'Course ID, title and description are required.',
        );
      }

      // Check if image is provided and exists
      bool hasImage =
          imagePath != null &&
          imagePath.isNotEmpty &&
          File(imagePath).existsSync();

      Response response;

      if (hasImage) {
        // Create FormData for request with image
        FormData formData = FormData();

        // Add text fields
        formData.fields.add(MapEntry('title', title.trim()));
        formData.fields.add(MapEntry('description', description.trim()));

        // Add image file
        final file = File(imagePath);
        formData.files.add(
          MapEntry(
            'coverImage',
            await MultipartFile.fromFile(
              file.path,
              filename: file.path.split('/').last,
            ),
          ),
        );

        // Send request with FormData (multipart)
        response = await _dio.put('$courseEndpoint/$courseId', data: formData);
      } else {
        // Send request with JSON data only (no image)
        response = await _dio.put(
          '$courseEndpoint/$courseId',
          data: {'title': title.trim(), 'description': description.trim()},
          options: Options(contentType: 'application/json'),
        );
      }

      // Handle successful response
      if (response.statusCode == 200) {
        try {
          CourseModel course;

          // Parse the updated course from response
          if (response.data is Map<String, dynamic>) {
            final data = response.data as Map<String, dynamic>;

            // Check different possible response structures
            if (data.containsKey('course')) {
              course = CourseModel.fromJson(data['course']);
            } else if (data.containsKey('data')) {
              course = CourseModel.fromJson(data['data']);
            } else {
              course = CourseModel.fromJson(data);
            }
          } else {
            throw Exception('Invalid response format');
          }

          log('Course updated successfully: ${course.title}');

          return ApiResponse<CourseModel>(
            success: true,
            message: 'Course updated successfully',
            data: course,
            statusCode: response.statusCode,
          );
        } catch (parseError) {
          log('Error parsing updated course: $parseError');
          return ApiResponse<CourseModel>(
            success: false,
            message:
                'Course updated but failed to parse response: ${parseError.toString()}',
            statusCode: response.statusCode,
          );
        }
      } else {
        return _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      log('DioException in updateCourse: ${e.message}');
      return _handleDioError(e);
    } catch (e) {
      log('Unexpected error in updateCourse: $e');
      return ApiResponse<CourseModel>(
        success: false,
        message:
            'An unexpected error occurred while updating course: ${e.toString()}',
      );
    }
  }

  // Delete a course
  static Future<ApiResponse<bool>> deleteCourse(String courseId) async {
    try {
      log('Deleting course: $courseId');

      // Check internet connection
      if (!await ConnectivityService.hasInternetConnection()) {
        return ApiResponse<bool>(
          success: false,
          message: 'No internet connection. Please check your network.',
        );
      }

      // Initialize Dio if not already done
      CourseService()._initializeDio();

      // Validate required fields
      if (courseId.isEmpty) {
        return ApiResponse<bool>(
          success: false,
          message: 'Course ID is required.',
        );
      }

      final response = await _dio.delete(
        '$courseEndpoint/$courseId',
        options: Options(contentType: 'application/json'),
      );

      // Handle successful response
      if (response.statusCode == 200 || response.statusCode == 204) {
        log('Course deleted successfully: $courseId');

        return ApiResponse<bool>(
          success: true,
          message: 'Course deleted successfully',
          data: true,
          statusCode: response.statusCode,
        );
      } else {
        return _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      log('DioException in deleteCourse: ${e.message}');
      return _handleDioError(e);
    } catch (e) {
      log('Unexpected error in deleteCourse: $e');
      return ApiResponse<bool>(
        success: false,
        message:
            'An unexpected error occurred while deleting course: ${e.toString()}',
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
            message: 'Course not found',
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
