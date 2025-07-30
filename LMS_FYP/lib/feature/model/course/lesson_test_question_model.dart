class TestQuestion {
  final String? id;
  final String question;
  final List<String> options;

  TestQuestion({this.id, required this.question, required this.options});

  factory TestQuestion.fromJson(Map<String, dynamic> json) {
    return TestQuestion(
      id: json['_id'] ?? json['id'],
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'question': question,
      'options': options,
    };
  }

  TestQuestion copyWith({String? id, String? question, List<String>? options}) {
    return TestQuestion(
      id: id ?? this.id,
      question: question ?? this.question,
      options: options ?? this.options,
    );
  }

  @override
  String toString() {
    return 'TestQuestion(id: $id, question: $question, options: $options)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TestQuestion &&
        other.id == id &&
        other.question == question;
  }

  @override
  int get hashCode {
    return id.hashCode ^ question.hashCode;
  }
}

// Model for the complete test/quiz
class LessonTestQuestionModel {
  final String? id;
  final String title;
  final String lessonId;
  final List<TestQuestion> questions;
  final int correctAnswer;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  LessonTestQuestionModel({
    this.id,
    required this.title,
    required this.lessonId,
    required this.questions,
    required this.correctAnswer,
    this.createdAt,
    this.updatedAt,
  });

  factory LessonTestQuestionModel.fromJson(Map<String, dynamic> json) {
    return LessonTestQuestionModel(
      id: json['_id'] ?? json['id'],
      title: json['title'] ?? '',
      lessonId: json['lesson'] is String
          ? json['lesson']
          : json['lesson'] is Map<String, dynamic>
          ? json['lesson']['_id'] ?? json['lessonId'] ?? ''
          : json['lessonId'] ?? '',
      questions:
          (json['questions'] as List<dynamic>?)
              ?.map((q) => TestQuestion.fromJson(q as Map<String, dynamic>))
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
      if (id != null) '_id': id,
      'title': title,
      'lesson': lessonId,
      'questions': questions.map((q) => q.toJson()).toList(),
      'correctAnswer': correctAnswer,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  LessonTestQuestionModel copyWith({
    String? id,
    String? title,
    String? lessonId,
    List<TestQuestion>? questions,
    int? correctAnswer,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
  }) {
    return LessonTestQuestionModel(
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
    return 'TestQuestionModel(id: $id, title: $title, lessonId: $lessonId, questions: ${questions.length}, correctAnswer: $correctAnswer)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LessonTestQuestionModel &&
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
