// === Model Cha ===
class StudentQuizTakeModel {
  final String id;
  final String title;
  final String? description;
  final int timeLimitMinutes;
  final String skillType;
  final String? readingPassage;

  final List<StudentQuestionModel> questions;

  StudentQuizTakeModel({
    required this.id,
    required this.title,
    this.description,
    required this.timeLimitMinutes,
    required this.questions,
    required this.skillType,
    this.readingPassage,
  });

  factory StudentQuizTakeModel.fromJson(Map<String, dynamic> json) {
    return StudentQuizTakeModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'],
      timeLimitMinutes: json['timeLimitMinutes'] ?? 0,
      skillType: json['skillType'] ?? 'READING',
      readingPassage: json['readingPassage'],

      questions:
          (json['questions'] as List? ?? []) // 👈 Thêm an toàn
              .map((q) => StudentQuestionModel.fromJson(q))
              .toList(),
    );
  }
}

// === Model Câu hỏi (Con) ===
class StudentQuestionModel {
  final String id;
  final String questionText;
  final String? audioUrl;
  final String questionType;
  final List<StudentOptionModel> options;

  StudentQuestionModel({
    required this.id,
    required this.questionText,
    required this.options,
    this.audioUrl,
    required this.questionType,
  });

  factory StudentQuestionModel.fromJson(Map<String, dynamic> json) {
    return StudentQuestionModel(
      id: json['id'] ?? 0,
      questionText: json['questionText'] ?? '',
      audioUrl: json['audioUrl'],
      questionType: json['questionType'] ?? 'MULTIPLE_CHOICE',

      options:
          (json['options'] as List? ?? [])
              .map((o) => StudentOptionModel.fromJson(o))
              .toList(),
    );
  }
}

// === Model Lựa chọn (Con) ===
class StudentOptionModel {
  final String id;
  final String optionText;

  StudentOptionModel({required this.id, required this.optionText});

  factory StudentOptionModel.fromJson(Map<String, dynamic> json) {
    return StudentOptionModel(
      id: json['id'] ?? 0,
      optionText: json['optionText'] ?? '',
    );
  }
}
