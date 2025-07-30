// course_review_service.dart

import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:get/get.dart' as token;
import '../../core/constant/api_url.dart';
import '../../core/helpers/internet_connection.dart';
import '../controller/auth/login_controller.dart';
import '../model/api_response_model.dart';
import '../model/course/course_review_model.dart';

class CourseReviewService {
  static const String courseReviewEndpoint = '/course-reviews';

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

  // Get all course reviews
  static Future<ApiResponse<List<CourseRemarkModel>>> getAllReviews() async {
    try {
      log('Fetching all course reviews...');

      // Check internet connection
      if (!await ConnectivityService.hasInternetConnection()) {
        return ApiResponse<List<CourseRemarkModel>>(
          success: false,
          message: 'No internet connection. Please check your network.',
        );
      }

      // Initialize Dio if not already done
      CourseReviewService()._initializeDio();

      final response = await _dio.get(
        courseReviewEndpoint,
        queryParameters: {'approvedOnly': false}, // Adjust limit as needed
        options: Options(contentType: 'application/json'),
      );

      log('All reviews response: ${response.data}');

      // Handle successful response
      if (response.statusCode == 200) {
        try {
          List<CourseRemarkModel> reviews = [];

          // Check if response.data is a List directly
          if (response.data is List) {
            reviews = CourseRemarkList.fromJsonList(response.data as List);
          }
          // Or if it's wrapped in an object like {reviews: [...]}
          else if (response.data is Map<String, dynamic>) {
            final data = response.data as Map<String, dynamic>;
            if (data.containsKey('reviews') && data['reviews'] is List) {
              reviews = CourseRemarkList.fromJsonList(data['reviews'] as List);
            } else if (data.containsKey('data') && data['data'] is List) {
              reviews = CourseRemarkList.fromJsonList(data['data'] as List);
            }
          }

          log('Parsed ${reviews.length} reviews successfully');

          return ApiResponse<List<CourseRemarkModel>>(
            success: true,
            message: 'Reviews fetched successfully',
            data: reviews,
            statusCode: response.statusCode,
          );
        } catch (parseError) {
          log('Error parsing reviews: $parseError');
          return ApiResponse<List<CourseRemarkModel>>(
            success: false,
            message: 'Failed to parse review data: ${parseError.toString()}',
            statusCode: response.statusCode,
          );
        }
      } else {
        return _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      log('DioException in getAllReviews: ${e.message}');
      return _handleDioError(e);
    } catch (e) {
      log('Unexpected error in getAllReviews: $e');
      return ApiResponse<List<CourseRemarkModel>>(
        success: false,
        message:
            'An unexpected error occurred while fetching reviews: ${e.toString()}',
      );
    }
  }

  // Get all reviews for a specific course
  static Future<ApiResponse<List<CourseRemarkModel>>> getReviewsForCourse(
    String courseId,
  ) async {
    try {
      log('Fetching reviews for course: $courseId');

      // Check internet connection
      if (!await ConnectivityService.hasInternetConnection()) {
        return ApiResponse<List<CourseRemarkModel>>(
          success: false,
          message: 'No internet connection. Please check your network.',
        );
      }

      // Initialize Dio if not already done
      CourseReviewService()._initializeDio();

      // Validate required fields
      if (courseId.isEmpty) {
        return ApiResponse<List<CourseRemarkModel>>(
          success: false,
          message: 'Course ID is required.',
        );
      }

      final response = await _dio.get(
        '$courseReviewEndpoint/course/$courseId',
        options: Options(contentType: 'application/json'),
      );

      log('Course reviews response: ${response.data}');

      // Handle successful response
      if (response.statusCode == 200) {
        try {
          List<CourseRemarkModel> reviews = [];

          // Check if response.data is a List directly
          if (response.data is List) {
            reviews = CourseRemarkList.fromJsonList(response.data as List);
          }
          // Or if it's wrapped in an object like {reviews: [...]}
          else if (response.data is Map<String, dynamic>) {
            final data = response.data as Map<String, dynamic>;
            if (data.containsKey('reviews') && data['reviews'] is List) {
              reviews = CourseRemarkList.fromJsonList(data['reviews'] as List);
            } else if (data.containsKey('data') && data['data'] is List) {
              reviews = CourseRemarkList.fromJsonList(data['data'] as List);
            }
          }

          log(
            'Parsed ${reviews.length} reviews for course $courseId successfully',
          );

          return ApiResponse<List<CourseRemarkModel>>(
            success: true,
            message: 'Course reviews fetched successfully',
            data: reviews,
            statusCode: response.statusCode,
          );
        } catch (parseError) {
          log('Error parsing course reviews: $parseError');
          return ApiResponse<List<CourseRemarkModel>>(
            success: false,
            message: 'Failed to parse review data: ${parseError.toString()}',
            statusCode: response.statusCode,
          );
        }
      } else {
        return _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      log('DioException in getReviewsForCourse: ${e.message}');
      return _handleDioError(e);
    } catch (e) {
      log('Unexpected error in getReviewsForCourse: $e');
      return ApiResponse<List<CourseRemarkModel>>(
        success: false,
        message:
            'An unexpected error occurred while fetching course reviews: ${e.toString()}',
      );
    }
  }

  // Get a specific review by ID
  static Future<ApiResponse<CourseRemarkModel>> getReviewById(
    String reviewId,
  ) async {
    try {
      log('Fetching review: $reviewId');

      // Check internet connection
      if (!await ConnectivityService.hasInternetConnection()) {
        return ApiResponse<CourseRemarkModel>(
          success: false,
          message: 'No internet connection. Please check your network.',
        );
      }

      // Initialize Dio if not already done
      CourseReviewService()._initializeDio();

      // Validate required fields
      if (reviewId.isEmpty) {
        return ApiResponse<CourseRemarkModel>(
          success: false,
          message: 'Review ID is required.',
        );
      }

      final response = await _dio.get(
        '$courseReviewEndpoint/$reviewId',
        options: Options(contentType: 'application/json'),
      );

      log('Review response: ${response.data}');

      // Handle successful response
      if (response.statusCode == 200) {
        try {
          CourseRemarkModel review;

          // Parse the review from response
          if (response.data is Map<String, dynamic>) {
            final data = response.data as Map<String, dynamic>;

            // Check different possible response structures
            if (data.containsKey('review')) {
              review = CourseRemarkModel.fromJson(data['review']);
            } else if (data.containsKey('data')) {
              review = CourseRemarkModel.fromJson(data['data']);
            } else {
              review = CourseRemarkModel.fromJson(data);
            }
          } else {
            throw Exception('Invalid response format');
          }

          log('Review fetched successfully: ${review.comment}');

          return ApiResponse<CourseRemarkModel>(
            success: true,
            message: 'Review fetched successfully',
            data: review,
            statusCode: response.statusCode,
          );
        } catch (parseError) {
          log('Error parsing review: $parseError');
          return ApiResponse<CourseRemarkModel>(
            success: false,
            message: 'Failed to parse review data: ${parseError.toString()}',
            statusCode: response.statusCode,
          );
        }
      } else {
        return _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      log('DioException in getReviewById: ${e.message}');
      return _handleDioError(e);
    } catch (e) {
      log('Unexpected error in getReviewById: $e');
      return ApiResponse<CourseRemarkModel>(
        success: false,
        message:
            'An unexpected error occurred while fetching review: ${e.toString()}',
      );
    }
  }

  // Create a new course review
  static Future<ApiResponse<CourseRemarkModel>> createReview(
    String courseId,
    int rating,
    String comment,
  ) async {
    try {
      log('Creating new review for course: $courseId');

      // Check internet connection
      if (!await ConnectivityService.hasInternetConnection()) {
        return ApiResponse<CourseRemarkModel>(
          success: false,
          message: 'No internet connection. Please check your network.',
        );
      }

      // Initialize Dio if not already done
      CourseReviewService()._initializeDio();

      // Validate required fields
      if (courseId.isEmpty || comment.isEmpty) {
        return ApiResponse<CourseRemarkModel>(
          success: false,
          message: 'Course ID and comment are required.',
        );
      }

      // Validate rating range
      if (rating < 1 || rating > 5) {
        return ApiResponse<CourseRemarkModel>(
          success: false,
          message: 'Rating must be between 1 and 5.',
        );
      }

      final response = await _dio.post(
        courseReviewEndpoint,
        data: {
          'course': courseId.trim(),
          'rating': rating,
          'comment': comment.trim(),
        },
        options: Options(contentType: 'application/json'),
      );

      log('Create review response: ${response.data}');

      // Handle successful response
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          CourseRemarkModel review;

          // Parse the created review from response
          if (response.data is Map<String, dynamic>) {
            final data = response.data as Map<String, dynamic>;

            // Check different possible response structures
            if (data.containsKey('review')) {
              review = CourseRemarkModel.fromJson(data['review']);
            } else if (data.containsKey('data')) {
              review = CourseRemarkModel.fromJson(data['data']);
            } else {
              review = CourseRemarkModel.fromJson(data);
            }
          } else {
            throw Exception('Invalid response format');
          }

          log('Review created successfully: ${review.comment}');

          return ApiResponse<CourseRemarkModel>(
            success: true,
            message: 'Review created successfully',
            data: review,
            statusCode: response.statusCode,
          );
        } catch (parseError) {
          log('Error parsing created review: $parseError');
          return ApiResponse<CourseRemarkModel>(
            success: false,
            message:
                'Review created but failed to parse response: ${parseError.toString()}',
            statusCode: response.statusCode,
          );
        }
      } else {
        return _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      log('DioException in createReview: ${e.message}');
      return _handleDioError(e);
    } catch (e) {
      log('Unexpected error in createReview: $e');
      return ApiResponse<CourseRemarkModel>(
        success: false,
        message:
            'An unexpected error occurred while creating review: ${e.toString()}',
      );
    }
  }

  // Update an existing review
  static Future<ApiResponse<CourseRemarkModel>> updateReview(
    String reviewId,
    String courseId,
    String userId,
    int rating,
    String comment,
    bool isApproved,
  ) async {
    try {
      log('Updating review: $reviewId');

      // Check internet connection
      if (!await ConnectivityService.hasInternetConnection()) {
        return ApiResponse<CourseRemarkModel>(
          success: false,
          message: 'No internet connection. Please check your network.',
        );
      }

      // Initialize Dio if not already done
      CourseReviewService()._initializeDio();

      // Validate required fields
      if (reviewId.isEmpty || comment.isEmpty) {
        return ApiResponse<CourseRemarkModel>(
          success: false,
          message: 'Review ID and comment are required.',
        );
      }

      // Validate rating range
      if (rating < 1 || rating > 5) {
        return ApiResponse<CourseRemarkModel>(
          success: false,
          message: 'Rating must be between 1 and 5.',
        );
      }

      final response = await _dio.put(
        '$courseReviewEndpoint/$reviewId',
        data: {
          'course': courseId,
          'user': userId,
          'rating': rating,
          'comment': comment.trim(),
          'isApproved': isApproved,
        },
        options: Options(contentType: 'application/json'),
      );

      log('Update review response: ${response.data}');

      // Handle successful response
      if (response.statusCode == 200) {
        try {
          CourseRemarkModel review;

          // Parse the updated review from response
          if (response.data is Map<String, dynamic>) {
            final data = response.data as Map<String, dynamic>;

            // Check different possible response structures
            if (data.containsKey('review')) {
              review = CourseRemarkModel.fromJson(data['review']);
            } else if (data.containsKey('data')) {
              review = CourseRemarkModel.fromJson(data['data']);
            } else {
              review = CourseRemarkModel.fromJson(data);
            }
          } else {
            throw Exception('Invalid response format');
          }

          log('Review updated successfully: ${review.comment}');

          return ApiResponse<CourseRemarkModel>(
            success: true,
            message: 'Review updated successfully',
            data: review,
            statusCode: response.statusCode,
          );
        } catch (parseError) {
          log('Error parsing updated review: $parseError');
          return ApiResponse<CourseRemarkModel>(
            success: false,
            message:
                'Review updated but failed to parse response: ${parseError.toString()}',
            statusCode: response.statusCode,
          );
        }
      } else {
        return _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      log('DioException in updateReview: ${e.message}');
      return _handleDioError(e);
    } catch (e) {
      log('Unexpected error in updateReview: $e');
      return ApiResponse<CourseRemarkModel>(
        success: false,
        message:
            'An unexpected error occurred while updating review: ${e.toString()}',
      );
    }
  }

  // Delete a review
  static Future<ApiResponse<bool>> deleteReview(String reviewId) async {
    try {
      log('Deleting review: $reviewId');

      // Check internet connection
      if (!await ConnectivityService.hasInternetConnection()) {
        return ApiResponse<bool>(
          success: false,
          message: 'No internet connection. Please check your network.',
        );
      }

      // Initialize Dio if not already done
      CourseReviewService()._initializeDio();

      // Validate required fields
      if (reviewId.isEmpty) {
        return ApiResponse<bool>(
          success: false,
          message: 'Review ID is required.',
        );
      }

      final response = await _dio.delete(
        '$courseReviewEndpoint/$reviewId',
        options: Options(contentType: 'application/json'),
      );

      log('Delete review response: ${response.statusCode}');

      // Handle successful response
      if (response.statusCode == 200 || response.statusCode == 204) {
        log('Review deleted successfully: $reviewId');

        return ApiResponse<bool>(
          success: true,
          message: 'Review deleted successfully',
          data: true,
          statusCode: response.statusCode,
        );
      } else {
        return _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      log('DioException in deleteReview: ${e.message}');
      return _handleDioError(e);
    } catch (e) {
      log('Unexpected error in deleteReview: $e');
      return ApiResponse<bool>(
        success: false,
        message:
            'An unexpected error occurred while deleting review: ${e.toString()}',
      );
    }
  }

  // Get review count for a specific course
  static Future<ApiResponse<int>> getReviewCountForCourse(
    String courseId,
  ) async {
    try {
      log('Fetching review count for course: $courseId');

      // Check internet connection
      if (!await ConnectivityService.hasInternetConnection()) {
        return ApiResponse<int>(
          success: false,
          message: 'No internet connection. Please check your network.',
        );
      }

      // Initialize Dio if not already done
      CourseReviewService()._initializeDio();

      // Validate required fields
      if (courseId.isEmpty) {
        return ApiResponse<int>(
          success: false,
          message: 'Course ID is required.',
        );
      }

      final response = await _dio.get(
        '$courseReviewEndpoint/count/$courseId',
        options: Options(contentType: 'application/json'),
      );

      log('Review count response: ${response.data}');

      // Handle successful response
      if (response.statusCode == 200) {
        try {
          int count = 0;

          // Parse the count from response
          if (response.data is Map<String, dynamic>) {
            final data = response.data as Map<String, dynamic>;

            // Check different possible response structures
            if (data.containsKey('count')) {
              count = data['count'] as int;
            } else if (data.containsKey('data')) {
              count = data['data'] as int;
            } else if (data.containsKey('reviewCount')) {
              count = data['reviewCount'] as int;
            }
          } else if (response.data is int) {
            count = response.data as int;
          }

          log('Review count fetched successfully: $count');

          return ApiResponse<int>(
            success: true,
            message: 'Review count fetched successfully',
            data: count,
            statusCode: response.statusCode,
          );
        } catch (parseError) {
          log('Error parsing review count: $parseError');
          return ApiResponse<int>(
            success: false,
            message:
                'Failed to parse review count data: ${parseError.toString()}',
            statusCode: response.statusCode,
          );
        }
      } else {
        return _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      log('DioException in getReviewCountForCourse: ${e.message}');
      return _handleDioError(e);
    } catch (e) {
      log('Unexpected error in getReviewCountForCourse: $e');
      return ApiResponse<int>(
        success: false,
        message:
            'An unexpected error occurred while fetching review count: ${e.toString()}',
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
            message: 'Review not found',
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
