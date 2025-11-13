// === Model Cha ===
class StudentQuizTakeModel {
  final int id;
  final String title;
  final String? description;
  final int timeLimitMinutes;

  // ✅ THÊM MỚI
  final String skillType;
  final String? readingPassage;

  final List<StudentQuestionModel> questions;

  StudentQuizTakeModel({
    required this.id,
    required this.title,
    this.description,
    required this.timeLimitMinutes,
    required this.questions,
    // ✅ THÊM MỚI
    required this.skillType,
    this.readingPassage,
  });

  factory StudentQuizTakeModel.fromJson(Map<String, dynamic> json) {
    return StudentQuizTakeModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'],
      timeLimitMinutes: json['timeLimitMinutes'] ?? 0,

      // ✅ THÊM MỚI
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
  final int id;
  final String questionText;

  // ✅ THÊM MỚI
  final String? audioUrl;
  final String questionType;

  final List<StudentOptionModel> options;

  // Constructor (đầy đủ)
  StudentQuestionModel({
    required this.id,
    required this.questionText,
    required this.options,
    // ✅ THÊM MỚI
    this.audioUrl,
    required this.questionType,
  });

  factory StudentQuestionModel.fromJson(Map<String, dynamic> json) {
    return StudentQuestionModel(
      id: json['id'] ?? 0,
      questionText: json['questionText'] ?? '',

      // ✅ THÊM MỚI
      audioUrl: json['audioUrl'],
      questionType: json['questionType'] ?? 'MULTIPLE_CHOICE',

      options:
          (json['options'] as List? ?? []) // 👈 Thêm an toàn
              .map((o) => StudentOptionModel.fromJson(o))
              .toList(),
    );
  }
}

// === Model Lựa chọn (Con) ===
class StudentOptionModel {
  final int id;
  final String optionText;

  // Constructor (đầy đủ)
  StudentOptionModel({required this.id, required this.optionText});

  factory StudentOptionModel.fromJson(Map<String, dynamic> json) {
    return StudentOptionModel(
      id: json['id'] ?? 0,
      optionText: json['optionText'] ?? '',
    );
  }
}
