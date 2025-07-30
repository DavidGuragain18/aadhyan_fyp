import 'dart:developer';

class EnrollmentModel {
  final String id;
  final StudentInfo studentId;
  final CourseInfo courseId;
  final String status;
  final List<String> completedChapters;
  final DateTime enrolledAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;

  EnrollmentModel({
    required this.id,
    required this.studentId,
    required this.courseId,
    required this.status,
    required this.completedChapters,
    required this.enrolledAt,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
  });

  factory EnrollmentModel.fromJson(Map<String, dynamic> json) {
    return EnrollmentModel(
      id: json['_id'] ?? '',
      studentId: StudentInfo.fromJson(json['studentId'] ?? {}),
      courseId: CourseInfo.fromJson(json['courseId'] ?? {}),
      status: json['status'] ?? '',
      completedChapters: List<String>.from(json['completedChapters'] ?? []),
      enrolledAt: DateTime.parse(
        json['enrolledAt'] ?? DateTime.now().toIso8601String(),
      ),
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      version: json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'studentId': studentId.toJson(),
      'courseId': courseId.toJson(),
      'status': status,
      'completedChapters': completedChapters,
      'enrolledAt': enrolledAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': version,
    };
  }

  // Helper method to create a list of EnrollmentModel from JSON array
  static List<EnrollmentModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => EnrollmentModel.fromJson(json)).toList();
  }

  static int countApprovedEnrollments(
    List<EnrollmentModel> enrollments,
    String courseId,
  ) {
    return enrollments.where((enrollment) {
      log("inside countApprovedEnrollments");
      log(
        'Checking enrollment: ${enrollment.id}, Course ID: $courseId, Status: ${enrollment.status}',
      );
      return enrollment.courseId.id == courseId &&
          enrollment.status.toLowerCase() == 'approved';
    }).length;
  }

  @override
  String toString() {
    return 'EnrollmentModel(id: $id, studentId: $studentId, courseId: $courseId, status: $status, completedChapters: $completedChapters, enrolledAt: $enrolledAt, createdAt: $createdAt, updatedAt: $updatedAt, version: $version)';
  }
}

class StudentInfo {
  final String id;
  final String name;
  final String email;

  StudentInfo({required this.id, required this.name, required this.email});

  factory StudentInfo.fromJson(Map<String, dynamic> json) {
    return StudentInfo(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'name': name, 'email': email};
  }

  @override
  String toString() {
    return 'StudentInfo(id: $id, name: $name, email: $email)';
  }
}

class CourseInfo {
  final String id;
  final String title;

  CourseInfo({required this.id, required this.title});

  factory CourseInfo.fromJson(Map<String, dynamic> json) {
    return CourseInfo(id: json['_id'] ?? '', title: json['title'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'title': title};
  }

  @override
  String toString() {
    return 'CourseInfo(id: $id, title: $title)';
  }
}
