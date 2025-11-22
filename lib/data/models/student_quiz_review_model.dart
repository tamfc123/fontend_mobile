// === Model Cha ===
class StudentQuizReviewModel {
  final String submissionId;
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
      submissionId: json['submissionId'] ?? '',
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
  final String questionId;
  final String questionText;
  final String? audioUrl;
  final String questionType;
  final String? correctAnswerText; // Đáp án đúng bài Viết
  final String? studentAnswerText; // Bài Viết của SV
  final bool isCorrect; // SV làm Đúng hay Sai

  final String? selectedOptionId; // Đáp án SV đã chọn (Trắc nghiệm)
  final List<StudentOptionReviewModel> options;

  StudentQuestionReviewModel({
    required this.questionId,
    required this.questionText,
    this.selectedOptionId,
    required this.options,
    this.audioUrl,
    required this.questionType,
    this.correctAnswerText,
    this.studentAnswerText,
    required this.isCorrect,
  });

  factory StudentQuestionReviewModel.fromJson(Map<String, dynamic> json) {
    return StudentQuestionReviewModel(
      questionId: json['questionId'] ?? '',
      questionText: json['questionText'] ?? '',
      selectedOptionId: json['selectedOptionId'] ?? '',
      audioUrl: json['audioUrl'],
      questionType: json['questionType'] ?? 'MULTIPLE_CHOICE',
      correctAnswerText: json['correctAnswerText'],
      studentAnswerText: json['studentAnswerText'],
      isCorrect: json['isCorrect'] ?? false,

      options:
          (json['options'] as List? ?? [])
              .map((o) => StudentOptionReviewModel.fromJson(o))
              .toList(),
    );
  }
}

// === Model Lựa chọn (Con) ===
class StudentOptionReviewModel {
  final String optionId;
  final String optionText;
  final bool isCorrect; // Đáp án đúng

  StudentOptionReviewModel({
    required this.optionId,
    required this.optionText,
    required this.isCorrect,
  });

  factory StudentOptionReviewModel.fromJson(Map<String, dynamic> json) {
    return StudentOptionReviewModel(
      optionId: json['optionId'] ?? '',
      optionText: json['optionText'] ?? '',
      isCorrect: json['isCorrect'] ?? false,
    );
  }
}
