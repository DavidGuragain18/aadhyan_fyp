// enrollment_service.dart

import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:get/get.dart' as token;
import '../../core/constant/api_url.dart';
import '../../core/helpers/internet_connection.dart';
import '../controller/auth/login_controller.dart';
import '../model/api_response_model.dart';
import '../model/course/enrollment_model.dart';

class EnrollmentApiService {
  static const String enrollmentEndpoint = '/enrollments';

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

  // Create a new course enrollment
  static Future<ApiResponse<EnrollmentModel>> createEnrollment(
    String courseId,
  ) async {
    try {
      log('Creating new enrollment for course: $courseId');

      // Check internet connection
      if (!await ConnectivityService.hasInternetConnection()) {
        return ApiResponse<EnrollmentModel>(
          success: false,
          message: 'No internet connection. Please check your network.',
        );
      }

      // Initialize Dio if not already done
      EnrollmentApiService()._initializeDio();

      // Validate required fields
      if (courseId.isEmpty) {
        return ApiResponse<EnrollmentModel>(
          success: false,
          message: 'Course ID is required.',
        );
      }

      final response = await _dio.post(
        enrollmentEndpoint,
        data: {'courseId': courseId},
        options: Options(contentType: 'application/json'),
      );

      log('Enrollment response: ${response.data}');

      // Handle successful response
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          EnrollmentModel enrollment;

          // Parse the created enrollment from response
          if (response.data is Map<String, dynamic>) {
            final data = response.data as Map<String, dynamic>;

            // Check different possible response structures
            if (data.containsKey('enrollment')) {
              enrollment = EnrollmentModel.fromJson(data['enrollment']);
            } else if (data.containsKey('data')) {
              enrollment = EnrollmentModel.fromJson(data['data']);
            } else {
              enrollment = EnrollmentModel.fromJson(data);
            }
          } else {
            throw Exception('Invalid response format');
          }

          log('Enrollment created successfully: ${enrollment.id}');

          return ApiResponse<EnrollmentModel>(
            success: true,
            message: 'Enrollment created successfully',
            data: enrollment,
            statusCode: response.statusCode,
          );
        } catch (parseError) {
          log('Error parsing created enrollment: $parseError');
          return ApiResponse<EnrollmentModel>(
            success: false,
            message:
                'Enrollment created but failed to parse response: ${parseError.toString()}',
            statusCode: response.statusCode,
          );
        }
      } else {
        return _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      log('DioException in createEnrollment: ${e.message}');
      return _handleDioError(e);
    } catch (e) {
      log('Unexpected error in createEnrollment: $e');
      return ApiResponse<EnrollmentModel>(
        success: false,
        message:
            'An unexpected error occurred while creating enrollment: ${e.toString()}',
      );
    }
  }

  // Get all enrollments for a course
  static Future<ApiResponse<List<EnrollmentModel>>> getCourseEnrollments(
    String courseId,
  ) async {
    try {
      log('Fetching enrollments for course: $courseId');

      // Check internet connection
      if (!await ConnectivityService.hasInternetConnection()) {
        return ApiResponse<List<EnrollmentModel>>(
          success: false,
          message: 'No internet connection. Please check your network.',
        );
      }

      // Initialize Dio if not already done
      EnrollmentApiService()._initializeDio();

      // Validate required fields
      if (courseId.isEmpty) {
        return ApiResponse<List<EnrollmentModel>>(
          success: false,
          message: 'Course ID is required.',
        );
      }

      final response = await _dio.get(
        '$enrollmentEndpoint/course/$courseId',
        options: Options(contentType: 'application/json'),
      );

      log('Course enrollments response: ${response.data}');

      // Handle successful response
      if (response.statusCode == 200) {
        try {
          List<EnrollmentModel> enrollments = [];

          // Check if response.data is a List directly
          if (response.data is List) {
            enrollments = (response.data as List)
                .map(
                  (enrollmentJson) => EnrollmentModel.fromJson(enrollmentJson),
                )
                .toList();
          }
          // Or if it's wrapped in an object
          else if (response.data is Map<String, dynamic>) {
            final data = response.data as Map<String, dynamic>;
            if (data.containsKey('enrollments') &&
                data['enrollments'] is List) {
              enrollments = (data['enrollments'] as List)
                  .map(
                    (enrollmentJson) =>
                        EnrollmentModel.fromJson(enrollmentJson),
                  )
                  .toList();
            } else if (data.containsKey('data') && data['data'] is List) {
              enrollments = (data['data'] as List)
                  .map(
                    (enrollmentJson) =>
                        EnrollmentModel.fromJson(enrollmentJson),
                  )
                  .toList();
            }
          }

          log('Parsed ${enrollments.length} enrollments successfully');

          return ApiResponse<List<EnrollmentModel>>(
            success: true,
            message: 'Course enrollments fetched successfully',
            data: enrollments,
            statusCode: response.statusCode,
          );
        } catch (parseError) {
          log('Error parsing course enrollments: $parseError');
          return ApiResponse<List<EnrollmentModel>>(
            success: false,
            message:
                'Failed to parse enrollment data: ${parseError.toString()}',
            statusCode: response.statusCode,
          );
        }
      } else {
        return _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      log('DioException in getCourseEnrollments: ${e.message}');
      return _handleDioError(e);
    } catch (e) {
      log('Unexpected error in getCourseEnrollments: $e');
      return ApiResponse<List<EnrollmentModel>>(
        success: false,
        message:
            'An unexpected error occurred while fetching course enrollments: ${e.toString()}',
      );
    }
  }

  // Get all enrollments for the authenticated student
  static Future<ApiResponse<List<EnrollmentModel>>> getMyEnrollments() async {
    try {
      log('Fetching my enrollments...');

      // Check internet connection
      if (!await ConnectivityService.hasInternetConnection()) {
        return ApiResponse<List<EnrollmentModel>>(
          success: false,
          message: 'No internet connection. Please check your network.',
        );
      }

      // Initialize Dio if not already done
      EnrollmentApiService()._initializeDio();

      final response = await _dio.get(
        '$enrollmentEndpoint/my-enrollments',
        options: Options(contentType: 'application/json'),
      );

      log('My enrollments response: ${response.data}');

      // Handle successful response
      if (response.statusCode == 200) {
        try {
          List<EnrollmentModel> enrollments = [];

          // Check if response.data is a List directly
          if (response.data is List) {
            enrollments = (response.data as List)
                .map(
                  (enrollmentJson) => EnrollmentModel.fromJson(enrollmentJson),
                )
                .toList();
          }
          // Or if it's wrapped in an object
          else if (response.data is Map<String, dynamic>) {
            final data = response.data as Map<String, dynamic>;
            if (data.containsKey('enrollments') &&
                data['enrollments'] is List) {
              enrollments = (data['enrollments'] as List)
                  .map(
                    (enrollmentJson) =>
                        EnrollmentModel.fromJson(enrollmentJson),
                  )
                  .toList();
            } else if (data.containsKey('data') && data['data'] is List) {
              enrollments = (data['data'] as List)
                  .map(
                    (enrollmentJson) =>
                        EnrollmentModel.fromJson(enrollmentJson),
                  )
                  .toList();
            }
          }

          log('Parsed ${enrollments.length} my enrollments successfully');

          return ApiResponse<List<EnrollmentModel>>(
            success: true,
            message: 'My enrollments fetched successfully',
            data: enrollments,
            statusCode: response.statusCode,
          );
        } catch (parseError) {
          log('Error parsing my enrollments: $parseError');
          return ApiResponse<List<EnrollmentModel>>(
            success: false,
            message:
                'Failed to parse enrollment data: ${parseError.toString()}',
            statusCode: response.statusCode,
          );
        }
      } else {
        return _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      log('DioException in getMyEnrollments: ${e.message}');
      return _handleDioError(e);
    } catch (e) {
      log('Unexpected error in getMyEnrollments: $e');
      return ApiResponse<List<EnrollmentModel>>(
        success: false,
        message:
            'An unexpected error occurred while fetching my enrollments: ${e.toString()}',
      );
    }
  }

  // Get an enrollment by ID
  static Future<ApiResponse<EnrollmentModel>> getEnrollmentById(
    String enrollmentId,
  ) async {
    try {
      log('Fetching enrollment by ID: $enrollmentId');

      // Check internet connection
      if (!await ConnectivityService.hasInternetConnection()) {
        return ApiResponse<EnrollmentModel>(
          success: false,
          message: 'No internet connection. Please check your network.',
        );
      }

      // Initialize Dio if not already done
      EnrollmentApiService()._initializeDio();

      // Validate required fields
      if (enrollmentId.isEmpty) {
        return ApiResponse<EnrollmentModel>(
          success: false,
          message: 'Enrollment ID is required.',
        );
      }

      final response = await _dio.get(
        '$enrollmentEndpoint/find-one/$enrollmentId',
        options: Options(contentType: 'application/json'),
      );

      log('Enrollment by ID response: ${response.data}');

      // Handle successful response
      if (response.statusCode == 200) {
        try {
          EnrollmentModel enrollment;

          // Parse the enrollment from response
          if (response.data is Map<String, dynamic>) {
            final data = response.data as Map<String, dynamic>;

            // Check different possible response structures
            if (data.containsKey('enrollment')) {
              enrollment = EnrollmentModel.fromJson(data['enrollment']);
            } else if (data.containsKey('data')) {
              enrollment = EnrollmentModel.fromJson(data['data']);
            } else {
              enrollment = EnrollmentModel.fromJson(data);
            }
          } else {
            throw Exception('Invalid response format');
          }

          log('Enrollment fetched successfully: ${enrollment.id}');

          return ApiResponse<EnrollmentModel>(
            success: true,
            message: 'Enrollment fetched successfully',
            data: enrollment,
            statusCode: response.statusCode,
          );
        } catch (parseError) {
          log('Error parsing enrollment: $parseError');
          return ApiResponse<EnrollmentModel>(
            success: false,
            message:
                'Failed to parse enrollment data: ${parseError.toString()}',
            statusCode: response.statusCode,
          );
        }
      } else {
        return _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      log('DioException in getEnrollmentById: ${e.message}');
      return _handleDioError(e);
    } catch (e) {
      log('Unexpected error in getEnrollmentById: $e');
      return ApiResponse<EnrollmentModel>(
        success: false,
        message:
            'An unexpected error occurred while fetching enrollment: ${e.toString()}',
      );
    }
  }

  // Update an enrollment
  static Future<ApiResponse<EnrollmentModel>> updateEnrollment(
    String enrollmentId,
    Map<String, dynamic> updateData,
  ) async {
    try {
      log('Updating enrollment: $enrollmentId');

      // Check internet connection
      if (!await ConnectivityService.hasInternetConnection()) {
        return ApiResponse<EnrollmentModel>(
          success: false,
          message: 'No internet connection. Please check your network.',
        );
      }

      // Initialize Dio if not already done
      EnrollmentApiService()._initializeDio();

      // Validate required fields
      if (enrollmentId.isEmpty) {
        return ApiResponse<EnrollmentModel>(
          success: false,
          message: 'Enrollment ID is required.',
        );
      }

      final response = await _dio.put(
        '$enrollmentEndpoint/$enrollmentId',
        data: updateData,
        options: Options(contentType: 'application/json'),
      );

      log('Update enrollment response: ${response.data}');

      // Handle successful response
      if (response.statusCode == 200) {
        try {
          EnrollmentModel enrollment;

          // Parse the updated enrollment from response
          if (response.data is Map<String, dynamic>) {
            final data = response.data as Map<String, dynamic>;

            // Check different possible response structures
            if (data.containsKey('enrollment')) {
              enrollment = EnrollmentModel.fromJson(data['enrollment']);
            } else if (data.containsKey('data')) {
              enrollment = EnrollmentModel.fromJson(data['data']);
            } else {
              enrollment = EnrollmentModel.fromJson(data);
            }
          } else {
            throw Exception('Invalid response format');
          }

          log('Enrollment updated successfully: ${enrollment.id}');

          return ApiResponse<EnrollmentModel>(
            success: true,
            message: 'Enrollment updated successfully',
            data: enrollment,
            statusCode: response.statusCode,
          );
        } catch (parseError) {
          log('Error parsing updated enrollment: $parseError');
          return ApiResponse<EnrollmentModel>(
            success: false,
            message:
                'Enrollment updated but failed to parse response: ${parseError.toString()}',
            statusCode: response.statusCode,
          );
        }
      } else {
        return _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      log('DioException in updateEnrollment: ${e.message}');
      return _handleDioError(e);
    } catch (e) {
      log('Unexpected error in updateEnrollment: $e');
      return ApiResponse<EnrollmentModel>(
        success: false,
        message:
            'An unexpected error occurred while updating enrollment: ${e.toString()}',
      );
    }
  }

  // Delete an enrollment
  static Future<ApiResponse<bool>> deleteEnrollment(String enrollmentId) async {
    try {
      log('Deleting enrollment: $enrollmentId');

      // Check internet connection
      if (!await ConnectivityService.hasInternetConnection()) {
        return ApiResponse<bool>(
          success: false,
          message: 'No internet connection. Please check your network.',
        );
      }

      // Initialize Dio if not already done
      EnrollmentApiService()._initializeDio();

      // Validate required fields
      if (enrollmentId.isEmpty) {
        return ApiResponse<bool>(
          success: false,
          message: 'Enrollment ID is required.',
        );
      }

      final response = await _dio.delete(
        '$enrollmentEndpoint/$enrollmentId',
        options: Options(contentType: 'application/json'),
      );

      // Handle successful response
      if (response.statusCode == 200 || response.statusCode == 204) {
        log('Enrollment deleted successfully: $enrollmentId');

        return ApiResponse<bool>(
          success: true,
          message: 'Enrollment deleted successfully',
          data: true,
          statusCode: response.statusCode,
        );
      } else {
        return _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      log('DioException in deleteEnrollment: ${e.message}');
      return _handleDioError(e);
    } catch (e) {
      log('Unexpected error in deleteEnrollment: $e');
      return ApiResponse<bool>(
        success: false,
        message:
            'An unexpected error occurred while deleting enrollment: ${e.toString()}',
      );
    }
  }

  // Approve or reject an enrollment
  static Future<ApiResponse<EnrollmentModel>> updateEnrollmentStatus(
    String enrollmentId,
    String status, // 'approved', 'rejected', 'pending'
  ) async {
    try {
      log('Updating enrollment status: $enrollmentId to $status');

      // Check internet connection
      if (!await ConnectivityService.hasInternetConnection()) {
        return ApiResponse<EnrollmentModel>(
          success: false,
          message: 'No internet connection. Please check your network.',
        );
      }

      // Initialize Dio if not already done
      EnrollmentApiService()._initializeDio();

      // Validate required fields
      if (enrollmentId.isEmpty || status.isEmpty) {
        return ApiResponse<EnrollmentModel>(
          success: false,
          message: 'Enrollment ID and status are required.',
        );
      }

      // final response = await _dio.put(
      //   '$enrollmentEndpoint/$enrollmentId/$status',
      //   data: {'status': status},
      //   options: Options(contentType: 'application/json'),
      // );

      final response = await _dio.put(
        '$enrollmentEndpoint/$enrollmentId/status',
        queryParameters: {'status': status},
        options: Options(contentType: 'application/json'),
      );

      log('Update enrollment status response: ${response.data}');

      // Handle successful response
      if (response.statusCode == 200) {
        try {
          EnrollmentModel enrollment;

          // Parse the updated enrollment from response
          if (response.data is Map<String, dynamic>) {
            final data = response.data as Map<String, dynamic>;

            // Check different possible response structures
            if (data.containsKey('enrollment')) {
              enrollment = EnrollmentModel.fromJson(data['enrollment']);
            } else if (data.containsKey('data')) {
              enrollment = EnrollmentModel.fromJson(data['data']);
            } else {
              enrollment = EnrollmentModel.fromJson(data);
            }
          } else {
            throw Exception('Invalid response format');
          }

          log('Enrollment status updated successfully: ${enrollment.id}');

          return ApiResponse<EnrollmentModel>(
            success: true,
            message: 'Enrollment status updated successfully',
            data: enrollment,
            statusCode: response.statusCode,
          );
        } catch (parseError) {
          log('Error parsing enrollment status update: $parseError');
          return ApiResponse<EnrollmentModel>(
            success: false,
            message:
                'Enrollment status updated but failed to parse response: ${parseError.toString()}',
            statusCode: response.statusCode,
          );
        }
      } else {
        return _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      log('DioException in updateEnrollmentStatus: ${e.message}');
      return _handleDioError(e);
    } catch (e) {
      log('Unexpected error in updateEnrollmentStatus: $e');
      return ApiResponse<EnrollmentModel>(
        success: false,
        message:
            'An unexpected error occurred while updating enrollment status: ${e.toString()}',
      );
    }
  }

  // Count enrollments for a course
  static Future<ApiResponse<int>> getEnrollmentCount(String courseId) async {
    try {
      log('Getting enrollment count for course: $courseId');

      // Check internet connection
      if (!await ConnectivityService.hasInternetConnection()) {
        return ApiResponse<int>(
          success: false,
          message: 'No internet connection. Please check your network.',
        );
      }

      // Initialize Dio if not already done
      EnrollmentApiService()._initializeDio();

      // Validate required fields
      if (courseId.isEmpty) {
        return ApiResponse<int>(
          success: false,
          message: 'Course ID is required.',
        );
      }

      final response = await _dio.get(
        '$enrollmentEndpoint/count/$courseId',
        options: Options(contentType: 'application/json'),
      );

      log('Enrollment count response: ${response.data}');

      // Handle successful response
      if (response.statusCode == 200) {
        try {
          int count = 0;

          // Parse the count from response
          if (response.data is Map<String, dynamic>) {
            final data = response.data as Map<String, dynamic>;
            count = data['count'] ?? data['data'] ?? 0;
          } else if (response.data is int) {
            count = response.data;
          }

          log('Enrollment count fetched successfully: $count');

          return ApiResponse<int>(
            success: true,
            message: 'Enrollment count fetched successfully',
            data: count,
            statusCode: response.statusCode,
          );
        } catch (parseError) {
          log('Error parsing enrollment count: $parseError');
          return ApiResponse<int>(
            success: false,
            message:
                'Failed to parse enrollment count: ${parseError.toString()}',
            statusCode: response.statusCode,
          );
        }
      } else {
        return _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      log('DioException in getEnrollmentCount: ${e.message}');
      return _handleDioError(e);
    } catch (e) {
      log('Unexpected error in getEnrollmentCount: $e');
      return ApiResponse<int>(
        success: false,
        message:
            'An unexpected error occurred while fetching enrollment count: ${e.toString()}',
      );
    }
  }

  // Find all enrollments for teacher (teacher can approve/disapprove and delete)
  static Future<ApiResponse<List<EnrollmentModel>>> getEnrollmentsForTeacher(
    String? status,
  ) async {
    try {
      log('Fetching enrollments for teacher...');

      // Check internet connection
      if (!await ConnectivityService.hasInternetConnection()) {
        return ApiResponse<List<EnrollmentModel>>(
          success: false,
          message: 'No internet connection. Please check your network.',
        );
      }

      // Initialize Dio if not already done
      EnrollmentApiService()._initializeDio();

      final response = await _dio.get(
        '$enrollmentEndpoint/enrollments-for-teacher',
        options: Options(contentType: 'application/json'),
      );
      // }

      log('Teacher enrollments response: ${response.data}');

      // Handle successful response
      if (response.statusCode == 200) {
        try {
          List<EnrollmentModel> enrollments = [];

          // Check if response.data is a List directly
          if (response.data is List) {
            enrollments = (response.data as List)
                .map(
                  (enrollmentJson) => EnrollmentModel.fromJson(enrollmentJson),
                )
                .toList();
          }
          // Or if it's wrapped in an object
          else if (response.data is Map<String, dynamic>) {
            final data = response.data as Map<String, dynamic>;
            if (data.containsKey('enrollments') &&
                data['enrollments'] is List) {
              enrollments = (data['enrollments'] as List)
                  .map(
                    (enrollmentJson) =>
                        EnrollmentModel.fromJson(enrollmentJson),
                  )
                  .toList();
            } else if (data.containsKey('data') && data['data'] is List) {
              enrollments = (data['data'] as List)
                  .map(
                    (enrollmentJson) =>
                        EnrollmentModel.fromJson(enrollmentJson),
                  )
                  .toList();
            }
          }

          log('Parsed ${enrollments.length} teacher enrollments successfully');

          return ApiResponse<List<EnrollmentModel>>(
            success: true,
            message: 'Teacher enrollments fetched successfully',
            data: enrollments,
            statusCode: response.statusCode,
          );
        } catch (parseError) {
          log('Error parsing teacher enrollments: $parseError');
          return ApiResponse<List<EnrollmentModel>>(
            success: false,
            message:
                'Failed to parse enrollment data: ${parseError.toString()}',
            statusCode: response.statusCode,
          );
        }
      } else {
        return _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      log('DioException in getEnrollmentsForTeacher: ${e.message}');
      return _handleDioError(e);
    } catch (e) {
      log('Unexpected error in getEnrollmentsForTeacher: $e');
      return ApiResponse<List<EnrollmentModel>>(
        success: false,
        message:
            'An unexpected error occurred while fetching teacher enrollments: ${e.toString()}',
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
            message: 'Enrollment not found',
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
