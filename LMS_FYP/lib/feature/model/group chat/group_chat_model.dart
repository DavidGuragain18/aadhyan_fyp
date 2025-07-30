import 'dart:developer';
import '../auth/user_model.dart';
import '../course/course_model.dart';

class GroupChatModel {
  final String id;
  final String message;
  final CourseModel course;
  final UserModel user;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  GroupChatModel({
    required this.id,
    required this.message,
    required this.course,
    required this.user,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  // Factory constructor to create GroupChatModel from JSON
  factory GroupChatModel.fromJson(Map<String, dynamic> json) {
    // Handle course - can be either string ID or full object
    CourseModel course;
    if (json['course'] is String) {
      // If course is just an ID (from POST response), create minimal CourseModel
      course = CourseModel(
        id: json['course'] as String,
        title: '', // Empty since we only have ID
        description: '',
        lessons: [],
        lessonIds: [],
        reviewIds: [],
        version: 0,
      );
    } else if (json['course'] is Map<String, dynamic>) {
      // If course is a full object (from GET response), parse it
      final courseJson = json['course'] as Map<String, dynamic>;
      course = CourseModel(
        id: courseJson['_id'] as String? ?? '',
        title: courseJson['title'] as String? ?? '',
        description: '', // Not present in API response
        coverImage: null, // Not present in API response
        lessons: [], // Not present in API response
        lessonIds: [], // Not present in API response
        teacherId: null, // Not present in API response
        reviewIds: [], // Not present in API response
        version: 0, // Not present in API response
      );
    } else {
      // Fallback for null or unexpected types
      course = CourseModel(
        id: '',
        title: '',
        description: '',
        lessons: [],
        lessonIds: [],
        reviewIds: [],
        version: 0,
      );
    }

    // Handle user - can be either string ID or full object
    UserModel user;
    if (json['user'] is String) {
      // If user is just an ID (from POST response), create minimal UserModel
      user = UserModel(
        id: json['user'] as String,
        email: '',
        name: 'Unknown User', // Default name when we only have ID
        role: '',
        token: '',
        enrollments: [],
        notificationTokens: [], // Not present in POST response
        isSuspended: false, // Default value
      );
    } else if (json['user'] is Map<String, dynamic>) {
      // If user is a full object (from GET response), parse it
      final userJson = json['user'] as Map<String, dynamic>;
      user = UserModel(
        id: userJson['_id'] as String? ?? '',
        email: userJson['email'] as String? ?? '',
        name: userJson['name'] as String? ?? 'Default Name',
        image: null, // Not present in API response
        role: '', // Not present in API response
        token: '', // Not present in API response
        enrollments: [], // Not present in API response
        notificationTokens:
            userJson['notification_tokens'] as List<dynamic>? ?? [],
        isSuspended: userJson['isSuspended'] as bool? ?? false,
      );
    } else {
      // Fallback for null or unexpected types
      user = UserModel(
        id: '',
        email: '',
        name: 'Unknown User',
        role: '',
        token: '',
        enrollments: [],
        notificationTokens: [], // Not present in POST response
        isSuspended: false, // Default value
      );
    }

    return GroupChatModel(
      id: json['_id'] as String? ?? '',
      message: json['message'] as String? ?? '',
      course: course,
      user: user,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
      v: json['__v'] as int? ?? 0,
    );
  }

  // Method to convert GroupChatModel to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'message': message,
      'course': course.toJson(),
      'user': user.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': v,
    };
  }

  // Helper methods to check if we have full data
  bool get hasFullCourseData => course.title.isNotEmpty;
  bool get hasFullUserData => user.email.isNotEmpty;

  // Get IDs for when you need to fetch full data
  String get courseId => course.id;
  String get userId => user.id;

  // Helper method to update with full course and user data
  GroupChatModel copyWithFullData({
    CourseModel? fullCourse,
    UserModel? fullUser,
  }) {
    return GroupChatModel(
      id: id,
      message: message,
      course: fullCourse ?? course,
      user: fullUser ?? user,
      createdAt: createdAt,
      updatedAt: updatedAt,
      v: v,
    );
  }
}
