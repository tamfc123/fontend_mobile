// === Model Cha ===
class StudentQuizReviewModel {
  final int submissionId;
  final double score;
  final String quizTitle;
  final DateTime submittedAt;
  final List<StudentQuestionReviewModel> questions;

  StudentQuizReviewModel({
    required this.submissionId,
    required this.score,
    required this.quizTitle,
    required this.submittedAt,
    required this.questions,
  });

  factory StudentQuizReviewModel.fromJson(Map<String, dynamic> json) {
    return StudentQuizReviewModel(
      submissionId: json['submissionId'] ?? 0,
      score: (json['score'] as num? ?? 0.0).toDouble(), // 👈 Thêm an toàn
      quizTitle: json['quizTitle'] ?? '',
      submittedAt:
          DateTime.tryParse(json['submittedAt'] ?? '') ??
          DateTime.now(), // 👈 Thêm an toàn
      questions:
          (json['questions'] as List? ?? []) // 👈 Thêm an toàn
              .map((q) => StudentQuestionReviewModel.fromJson(q))
              .toList(),
    );
  }
}

// === Model Câu hỏi (Con) ===
class StudentQuestionReviewModel {
  final int questionId;
  final String questionText;

  // ✅ THÊM MỚI (Từ API)
  final String? audioUrl;
  final String questionType;
  final String? correctAnswerText; // Đáp án đúng bài Viết
  final String? studentAnswerText; // Bài Viết của SV
  final bool isCorrect; // SV làm Đúng hay Sai

  final int? selectedOptionId; // Đáp án SV đã chọn (Trắc nghiệm)
  final List<StudentOptionReviewModel> options;

  StudentQuestionReviewModel({
    required this.questionId,
    required this.questionText,
    this.selectedOptionId,
    required this.options,

    // ✅ THÊM MỚI
    this.audioUrl,
    required this.questionType,
    this.correctAnswerText,
    this.studentAnswerText,
    required this.isCorrect,
  });

  factory StudentQuestionReviewModel.fromJson(Map<String, dynamic> json) {
    return StudentQuestionReviewModel(
      questionId: json['questionId'] ?? 0,
      questionText: json['questionText'] ?? '',
      selectedOptionId: json['selectedOptionId'],

      // ✅ THÊM MỚI
      audioUrl: json['audioUrl'],
      questionType: json['questionType'] ?? 'MULTIPLE_CHOICE',
      correctAnswerText: json['correctAnswerText'],
      studentAnswerText: json['studentAnswerText'],
      isCorrect: json['isCorrect'] ?? false,

      options:
          (json['options'] as List? ?? []) // 👈 Thêm an toàn
              .map((o) => StudentOptionReviewModel.fromJson(o))
              .toList(),
    );
  }
}

// === Model Lựa chọn (Con) ===
class StudentOptionReviewModel {
  final int optionId;
  final String optionText;
  final bool isCorrect; // Đáp án đúng

  StudentOptionReviewModel({
    required this.optionId,
    required this.optionText,
    required this.isCorrect,
  });

  factory StudentOptionReviewModel.fromJson(Map<String, dynamic> json) {
    return StudentOptionReviewModel(
      optionId: json['optionId'] ?? 0,
      optionText: json['optionText'] ?? '',
      isCorrect: json['isCorrect'] ?? false,
    );
  }
}
