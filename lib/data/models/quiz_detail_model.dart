// lib/data/models/quiz_detail_model.dart

// 🔽 [THÊM] Hàm helper an toàn (giống như file list)
int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

bool _parseBool(dynamic value) {
  if (value == null) return false;
  if (value is bool) return value;
  if (value is String) return value.toLowerCase() == 'true';
  return false;
}

// === QuizDetailModel ===
class QuizDetailModel {
  final int id;
  final String title;
  final String? description;
  final int timeLimitMinutes;
  final int classId;

  // ✅ THÊM MỚI
  final String skillType;
  final String? readingPassage;

  final List<QuestionDetailModel> questions;

  QuizDetailModel({
    required this.id,
    required this.title,
    this.description,
    required this.timeLimitMinutes,
    required this.classId,
    required this.questions,

    // ✅ THÊM MỚI
    required this.skillType,
    this.readingPassage,
  });

  factory QuizDetailModel.fromJson(Map<String, dynamic> json) {
    var questionList = json['questions'] as List? ?? []; // 👈 Thêm an toàn
    List<QuestionDetailModel> questions =
        questionList.map((i) => QuestionDetailModel.fromJson(i)).toList();

    return QuizDetailModel(
      id: _parseInt(json['id']), // 👈 Dùng helper
      title: json['title'] ?? '',
      description: json['description'],
      timeLimitMinutes: _parseInt(json['timeLimitMinutes']), // 👈 Dùng helper
      classId: _parseInt(json['classId']), // 👈 Dùng helper
      questions: questions,

      // ✅ THÊM MỚI
      skillType: json['skillType'] ?? 'READING',
      readingPassage: json['readingPassage'],
    );
  }
}

// === QuestionDetailModel ===
class QuestionDetailModel {
  final int id;
  final String questionText;

  // ✅ THÊM MỚI
  final String? audioUrl;
  final String questionType;
  final String? correctAnswerText;

  final List<OptionDetailModel> options;

  QuestionDetailModel({
    required this.id,
    required this.questionText,
    required this.options,

    // ✅ THÊM MỚI
    this.audioUrl,
    required this.questionType,
    this.correctAnswerText,
  });

  factory QuestionDetailModel.fromJson(Map<String, dynamic> json) {
    var optionList = json['options'] as List? ?? []; // 👈 Thêm an toàn
    List<OptionDetailModel> options =
        optionList.map((i) => OptionDetailModel.fromJson(i)).toList();

    return QuestionDetailModel(
      id: _parseInt(json['id']), // 👈 Dùng helper
      questionText: json['questionText'] ?? '',

      // ✅ THÊM MỚI
      audioUrl: json['audioUrl'],
      questionType: json['questionType'] ?? 'MULTIPLE_CHOICE',
      correctAnswerText: json['correctAnswerText'],

      options: options,
    );
  }
}

// === OptionDetailModel ===
class OptionDetailModel {
  final int id;
  final String optionText;
  final bool isCorrect;

  OptionDetailModel({
    required this.id,
    required this.optionText,
    required this.isCorrect,
  });

  factory OptionDetailModel.fromJson(Map<String, dynamic> json) {
    return OptionDetailModel(
      id: _parseInt(json['id']), // 👈 Dùng helper
      optionText: json['optionText'] ?? '',
      isCorrect: _parseBool(json['isCorrect']), // 👈 Dùng helper
    );
  }
}
