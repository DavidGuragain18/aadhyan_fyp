import 'dart:developer';
import 'course_lesson_model.dart';

class CourseModel {
  final String id;
  final String title;
  final String description;
  final String? coverImage;
  final List<CourseLessonModel> lessons; // Full lesson objects
  final List<String> lessonIds; // Just lesson IDs
  final String? teacherId;
  final List<String> reviewIds; // NEW: list of review IDs
  final int version;

  CourseModel({
    required this.id,
    required this.title,
    required this.description,
    this.coverImage,
    required this.lessons,
    required this.lessonIds,
    this.teacherId,
    required this.reviewIds, // NEW
    required this.version,
  });

  // Factory constructor to create CourseModel from JSON
  factory CourseModel.fromJson(Map<String, dynamic> json) {
    final String title = json['title'] ?? '';
    final String description = json['description'] ?? '';
    final String? coverImage = json['image'];
    final String? teacherId = json['teacher'];

    log('Course Title: $title');
    log('Course Description: $description');
    log('Course Cover Image: $coverImage');

    // Handle lessons parsing with null safety
    List<CourseLessonModel> parsedLessons = [];
    List<String> lessonIds = [];

    if (json['lessons'] != null && json['lessons'] is List) {
      final lessonsData = json['lessons'] as List;

      for (var lessonData in lessonsData) {
        if (lessonData != null) {
          try {
            if (lessonData is String) {
              log('Lesson ID found: $lessonData');
              lessonIds.add(lessonData);
            } else if (lessonData is Map<String, dynamic>) {
              log('Parsing Full Lesson Object: $lessonData');
              final lesson = CourseLessonModel.fromJson(
                lessonData as Map<String, dynamic>,
              );
              parsedLessons.add(lesson);
              lessonIds.add(lesson.id);
            } else {
              log('Unknown lesson data type: ${lessonData.runtimeType}');
            }
          } catch (e) {
            log('Error parsing lesson: $lessonData, Error: $e');
            continue;
          }
        }
      }
    }

    // Parse reviews (list of IDs)
    final List<String> reviewIds = json['reviews'] != null
        ? List<String>.from(json['reviews'])
        : [];

    return CourseModel(
      id: json['_id'] ?? '',
      title: title,
      description: description,
      coverImage: coverImage,
      lessons: parsedLessons,
      lessonIds: lessonIds,
      teacherId: teacherId,
      reviewIds: reviewIds,
      version: json['__v'] ?? 0,
    );
  }

  // Convert CourseModel to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'image': coverImage,
      'lessons': lessons.isNotEmpty
          ? lessons.map((lesson) => lesson.toJson()).toList()
          : lessonIds,
      'teacher': teacherId,
      'reviews': reviewIds,
      '__v': version,
    };
  }

  // Create a copy of the course with modified properties
  CourseModel copyWith({
    String? id,
    String? title,
    String? description,
    String? coverImage,
    List<CourseLessonModel>? lessons,
    List<String>? lessonIds,
    String? teacherId,
    List<String>? reviewIds,
    int? version,
  }) {
    return CourseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      coverImage: coverImage ?? this.coverImage,
      lessons: lessons ?? this.lessons,
      lessonIds: lessonIds ?? this.lessonIds,
      teacherId: teacherId ?? this.teacherId,
      reviewIds: reviewIds ?? this.reviewIds,
      version: version ?? this.version,
    );
  }

  // Helper methods
  bool get hasLessons => lessons.isNotEmpty || lessonIds.isNotEmpty;
  int get lessonCount => lessons.isNotEmpty ? lessons.length : lessonIds.length;
  bool get hasFullLessonData => lessons.isNotEmpty;
  bool get hasOnlyLessonIds => lessons.isEmpty && lessonIds.isNotEmpty;

  CourseLessonModel? getLessonById(String lessonId) {
    try {
      return lessons.firstWhere((lesson) => lesson.id == lessonId);
    } catch (e) {
      return null;
    }
  }

  bool hasLessonId(String lessonId) {
    return lessonIds.contains(lessonId) ||
        lessons.any((lesson) => lesson.id == lessonId);
  }

  List<CourseLessonModel> getLessonsByKeyword(String keyword) {
    return lessons
        .where(
          (lesson) => lesson.keywords.any(
            (k) => k.toLowerCase().contains(keyword.toLowerCase()),
          ),
        )
        .toList();
  }

  @override
  String toString() {
    return 'CourseModel{id: $id, title: $title, description: $description, '
        'lessonCount: $lessonCount, hasFullLessons: $hasFullLessonData}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CourseModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
