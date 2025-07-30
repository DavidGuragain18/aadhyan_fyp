class CourseTestQuestion {
  final String? id;
  final String question;
  final List<String> options;
  final int correctAnswer; // Add this field

  CourseTestQuestion({
    this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
  });

  factory CourseTestQuestion.fromJson(Map<String, dynamic> json) {
    return CourseTestQuestion(
      id: json['_id'] ?? json['id'],
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswer: json['correctAnswer'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
    };
  }
}
// Model for the complete test/quiz
class CourseTestModel {
  final String id;
  final String title;
  final String lessonId;
  final List<CourseTestQuestion> questions;
  final int correctAnswer;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CourseTestModel({
    required this.id,
    required this.title,
    required this.lessonId,
    required this.questions,
    required this.correctAnswer,
    this.createdAt,
    this.updatedAt,
  });

  factory CourseTestModel.fromJson(Map<String, dynamic> json) {
    return CourseTestModel(
      id: json['_id'] ?? json['id'],
      title: json['title'] ?? '',
      lessonId: json['lesson'] is String
          ? json['lesson']
          : json['lesson'] is Map<String, dynamic>
          ? json['lesson']['_id'] ?? json['lessonId'] ?? ''
          : json['lessonId'] ?? '',
      questions:
          (json['questions'] as List<dynamic>?)
              ?.map(
                (q) => CourseTestQuestion.fromJson(q as Map<String, dynamic>),
              )
              .toList() ??
          [],
      correctAnswer: json['correctAnswer'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'lesson': lessonId,
      'questions': questions.map((q) => q.toJson()).toList(),
      'correctAnswer': correctAnswer,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  CourseTestModel copyWith({
    String? id,
    String? title,
    String? lessonId,
    List<CourseTestQuestion>? questions,
    int? correctAnswer,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
  }) {
    return CourseTestModel(
      id: id ?? this.id,
      title: title ?? this.title,
      lessonId: lessonId ?? this.lessonId,
      questions: questions ?? this.questions,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'CorseTestQuestionModel(id: $id, title: $title, lessonId: $lessonId, questions: ${questions.length}, correctAnswer: $correctAnswer)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CourseTestModel &&
        other.id == id &&
        other.title == title &&
        other.lessonId == lessonId &&
        other.correctAnswer == correctAnswer;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        lessonId.hashCode ^
        correctAnswer.hashCode;
  }
}
