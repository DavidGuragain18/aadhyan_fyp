import '../auth/user_model.dart';
import 'course_model.dart';

class CourseRemarkModel {
  final String id; // Added missing id field
  final CourseModel course;
  final UserModel user;
  final int rating;
  final String comment;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version; // Added missing version field (__v)

  CourseRemarkModel({
    required this.id,
    required this.course,
    required this.user,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
  });

  // Factory constructor to create CourseRemark from JSON
  factory CourseRemarkModel.fromJson(Map<String, dynamic> json) {
    return CourseRemarkModel(
      id: json['_id'] as String,
      course: CourseModelExtension.fromCourseRemarkJson(json['course']),
      user: UserModelExtension.fromCourseRemarkJson(
        json['user'] as Map<String, dynamic>,
      ),
      rating: json['rating'] as int,
      comment: json['comment'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      version: json['__v'] as int, // Map __v to version
    );
  }

  // Method to convert CourseRemark to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'course': course.toJson(),
      'user': user.toJson(),
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': version,
    };
  }

  // Method to create a copy with modified fields
  CourseRemarkModel copyWith({
    String? id,
    CourseModel? course,
    UserModel? user,
    int? rating,
    String? comment,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
  }) {
    return CourseRemarkModel(
      id: id ?? this.id,
      course: course ?? this.course,
      user: user ?? this.user,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
    );
  }

  @override
  String toString() {
    return 'CourseRemark{id: $id, courseTitle: ${course.title}, userName: ${user.name}, rating: $rating, comment: $comment}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CourseRemarkModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Enhanced UserModel extension for CourseRemark compatibility
extension UserModelExtension on UserModel {
  // Create a minimal UserModel from CourseRemark user data
  static UserModel fromCourseRemarkJson(Map<String, dynamic> userJson) {
    return UserModel(
      id: userJson['_id'] ?? '',
      email: userJson['email'] ?? '',
      name: userJson['name'] ?? 'Default Name',
      image: null,
      role: '',
      token: '',
      enrollments: [],
      notificationTokens: userJson['notification_tokens'] ?? [],
      isSuspended: userJson['isSuspended'] ?? false,

    );
  }
}

extension CourseModelExtension on CourseModel {
  static CourseModel fromCourseRemarkJson(dynamic courseJson) {
    if (courseJson is String) {
      // Only ID was provided
      return CourseModel(
        id: courseJson,
        title: '',
        description: '',
        coverImage: '',
        lessons: [],
        lessonIds: [],
        teacherId: '',
        reviewIds: [],
        version: 0,
      );
    } else if (courseJson is Map<String, dynamic>) {
      // Full object - Updated to handle the actual JSON structure
      return CourseModel(
        id: courseJson['_id'] ?? '',
        title: courseJson['title'] ?? '',
        description:
            courseJson['description'] ?? '', // Keep default if not provided
        coverImage:
            courseJson['coverImage'] ?? '', // Keep default if not provided
        lessons: [], // Not provided in this JSON, keep empty
        lessonIds: [], // Not provided in this JSON, keep empty
        teacherId:
            courseJson['teacherId'] ?? '', // Keep default if not provided
        reviewIds: [], // Not provided in this JSON, keep empty
        version: courseJson['__v'] ?? 0, // Map __v if present
      );
    } else {
      throw Exception('Invalid course data in CourseRemark JSON');
    }
  }
}

// Helper class for parsing list of CourseRemarks
class CourseRemarkList {
  static List<CourseRemarkModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => CourseRemarkModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  static List<Map<String, dynamic>> toJsonList(
    List<CourseRemarkModel> remarks,
  ) {
    return remarks.map((remark) => remark.toJson()).toList();
  }
}
