// Individual Question model

class QuestionModel {
  final String? id;
  final String question;
  final List<String> options;

  QuestionModel({this.id, required this.question, required this.options});

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
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
}
