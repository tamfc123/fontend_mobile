import 'dart:convert'; // Để xử lý jsonDecode cho SkillAnalysisJson

// ==========================================
// 1. MODEL DANH SÁCH (Màn hình danh sách bài tập)
// ==========================================
class StudentQuizListModel {
  final String id;
  final String title;
  final int timeLimitMinutes;
  final int questionCount;
  final String status; // "Pending" | "Submitted"
  final String skillType; // "READING" | "LISTENING" | "WRITING"

  StudentQuizListModel({
    required this.id,
    required this.title,
    required this.timeLimitMinutes,
    required this.questionCount,
    required this.status,
    required this.skillType,
  });

  factory StudentQuizListModel.fromJson(Map<String, dynamic> json) {
    return StudentQuizListModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      timeLimitMinutes: json['timeLimitMinutes'] ?? 0,
      questionCount: json['questionCount'] ?? 0,
      status: json['status'] ?? 'Pending',
      skillType: json['skillType'] ?? 'READING',
    );
  }
}

// ==========================================
// 2. MODEL LÀM BÀI (Màn hình Taking Quiz)
// ==========================================
class StudentQuizTakeModel {
  final String id;
  final String title;
  final String? description;
  final int timeLimitMinutes;
  final String classId;
  final String skillType;
  final String? readingPassage;

  // ✅ BỔ SUNG: MediaUrl (Cho bài Listening)
  final String? mediaUrl;

  final List<StudentQuestionModel> questions;

  StudentQuizTakeModel({
    required this.id,
    required this.title,
    this.description,
    required this.timeLimitMinutes,
    required this.classId,
    required this.skillType,
    this.readingPassage,
    this.mediaUrl,
    required this.questions,
  });

  factory StudentQuizTakeModel.fromJson(Map<String, dynamic> json) {
    var list = json['questions'] as List? ?? [];
    List<StudentQuestionModel> questionsList =
        list.map((i) => StudentQuestionModel.fromJson(i)).toList();

    return StudentQuizTakeModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      timeLimitMinutes: json['timeLimitMinutes'] ?? 0,
      classId: json['classId']?.toString() ?? '',
      skillType: json['skillType'] ?? 'READING',
      readingPassage: json['readingPassage'],
      mediaUrl: json['mediaUrl'], // ✅ Map MediaUrl
      questions: questionsList,
    );
  }
}

class StudentQuestionModel {
  final String id;
  final String questionText;
  final String? audioUrl;
  final String questionType;
  final List<StudentOptionModel> options;

  // Biến tạm để lưu trạng thái làm bài trên UI (không đến từ API)
  String? selectedAnswerText;
  String? selectedOptionId;

  StudentQuestionModel({
    required this.id,
    required this.questionText,
    this.audioUrl,
    required this.questionType,
    required this.options,
    this.selectedAnswerText,
    this.selectedOptionId,
  });

  factory StudentQuestionModel.fromJson(Map<String, dynamic> json) {
    var list = json['options'] as List? ?? [];
    List<StudentOptionModel> optionsList =
        list.map((i) => StudentOptionModel.fromJson(i)).toList();

    return StudentQuestionModel(
      id: json['id']?.toString() ?? '',
      questionText: json['questionText'] ?? '',
      audioUrl: json['audioUrl'],
      questionType: json['questionType'] ?? 'MULTIPLE_CHOICE',
      options: optionsList,
    );
  }
}

class StudentOptionModel {
  final String id;
  final String optionText;

  StudentOptionModel({required this.id, required this.optionText});

  factory StudentOptionModel.fromJson(Map<String, dynamic> json) {
    return StudentOptionModel(
      id: json['id']?.toString() ?? '',
      optionText: json['optionText'] ?? '',
    );
  }
}

// ==========================================
// 3. MODEL NỘP BÀI (Gửi lên Server)
// ==========================================
class StudentSubmissionModel {
  final List<StudentAnswerInputModel> answers;

  StudentSubmissionModel({required this.answers});

  Map<String, dynamic> toJson() {
    return {'answers': answers.map((e) => e.toJson()).toList()};
  }
}

class StudentAnswerInputModel {
  final String questionId;
  final String? selectedOptionId;
  final String? answerText;

  StudentAnswerInputModel({
    required this.questionId,
    this.selectedOptionId,
    this.answerText,
  });

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'selectedOptionId': selectedOptionId,
      'answerText': answerText,
    };
  }
}

// ==========================================
// 4. MODEL KẾT QUẢ (Review / Radar Chart)
// ==========================================
class StudentQuizReviewModel {
  final String submissionId;
  final double score;
  final String quizTitle;
  final DateTime submittedAt;
  final String? skillAnalysisJson;
  final String? readingPassage;
  final String? skillType; // ✅ Added for listening quiz
  final String? mediaUrl; // ✅ Added for listening audio

  final List<StudentQuestionReviewModel> questions;

  StudentQuizReviewModel({
    required this.submissionId,
    required this.score,
    required this.quizTitle,
    required this.submittedAt,
    this.skillAnalysisJson,
    this.readingPassage,
    this.skillType,
    this.mediaUrl,
    required this.questions,
  });

  AiAssessmentResult? get aiAssessment {
    if (skillAnalysisJson == null || skillAnalysisJson!.isEmpty) return null;
    return AiAssessmentResult.fromJson(skillAnalysisJson!);
  }

  Map<String, double> getRadarChartData() {
    if (skillAnalysisJson == null || skillAnalysisJson!.isEmpty) return {};
    try {
      final Map<String, dynamic> decoded = jsonDecode(skillAnalysisJson!);
      return decoded.map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      );
    } catch (e) {
      return {};
    }
  }

  factory StudentQuizReviewModel.fromJson(Map<String, dynamic> json) {
    var list = json['questions'] as List? ?? [];
    List<StudentQuestionReviewModel> questionsList =
        list.map((i) => StudentQuestionReviewModel.fromJson(i)).toList();

    return StudentQuizReviewModel(
      submissionId: json['submissionId']?.toString() ?? '',
      score: (json['score'] as num? ?? 0.0).toDouble(),
      quizTitle: json['quizTitle'] ?? '',
      submittedAt:
          json['submittedAt'] != null
              ? DateTime.tryParse(json['submittedAt']) ?? DateTime.now()
              : DateTime.now(),
      skillAnalysisJson: json['skillAnalysisJson'] ?? json['SkillAnalysisJson'],
      readingPassage: json['readingPassage'],
      skillType: json['skillType'], // ✅ Map skillType
      mediaUrl: json['mediaUrl'], // ✅ Map mediaUrl
      questions: questionsList,
    );
  }
}

class StudentQuestionReviewModel {
  final String questionId;
  final String questionText;
  final String? audioUrl;
  final String questionType;
  final String? correctAnswerText;
  final String? studentAnswerText;
  final String? selectedOptionId;
  final bool isCorrect;
  final String? explanation;

  final List<StudentOptionReviewModel> options;

  StudentQuestionReviewModel({
    required this.questionId,
    required this.questionText,
    this.audioUrl,
    required this.questionType,
    this.correctAnswerText,
    this.studentAnswerText,
    this.selectedOptionId,
    required this.isCorrect,
    this.explanation,
    required this.options,
  });

  factory StudentQuestionReviewModel.fromJson(Map<String, dynamic> json) {
    var list = json['options'] as List? ?? [];
    List<StudentOptionReviewModel> optionsList =
        list.map((i) => StudentOptionReviewModel.fromJson(i)).toList();

    return StudentQuestionReviewModel(
      questionId: json['questionId']?.toString() ?? '',
      questionText: json['questionText'] ?? '',
      audioUrl: json['audioUrl'],
      questionType: json['questionType'] ?? 'MULTIPLE_CHOICE',
      correctAnswerText: json['correctAnswerText'],
      studentAnswerText: json['studentAnswerText'],
      selectedOptionId: json['selectedOptionId']?.toString(),
      isCorrect: json['isCorrect'] ?? false,
      explanation: json['explanation'], // ✅ Map Explanation
      options: optionsList,
    );
  }
}

class StudentOptionReviewModel {
  final String optionId;
  final String optionText;
  final bool isCorrect; // Đáp án đúng để tô màu xanh

  StudentOptionReviewModel({
    required this.optionId,
    required this.optionText,
    required this.isCorrect,
  });

  factory StudentOptionReviewModel.fromJson(Map<String, dynamic> json) {
    return StudentOptionReviewModel(
      optionId: json['optionId']?.toString() ?? '',
      optionText: json['optionText'] ?? '',
      isCorrect: json['isCorrect'] ?? false,
    );
  }
}

// ... (Các class cũ giữ nguyên)

// ==========================================
// 5. MODEL KẾT QUẢ PHÂN TÍCH TỪ AI (Gemini)
// ==========================================
class AiAssessmentResult {
  final double score;
  final String feedback;
  final Map<String, double> radarChart;
  final List<AiCorrection> corrections;

  AiAssessmentResult({
    required this.score,
    required this.feedback,
    required this.radarChart,
    required this.corrections,
  });

  factory AiAssessmentResult.fromJson(String jsonString) {
    try {
      final Map<String, dynamic> json = jsonDecode(jsonString);

      // Parse Radar Chart
      Map<String, double> radar = {};
      if (json['radar_chart'] != null) {
        (json['radar_chart'] as Map<String, dynamic>).forEach((key, value) {
          radar[key] = (value as num).toDouble();
        });
      }

      // Parse Corrections
      var list = json['corrections'] as List? ?? [];
      List<AiCorrection> correctionsList =
          list.map((i) => AiCorrection.fromJson(i)).toList();

      return AiAssessmentResult(
        score: (json['score'] as num? ?? 0.0).toDouble(),
        feedback: json['feedback'] ?? '',
        radarChart: radar,
        corrections: correctionsList,
      );
    } catch (e) {
      // Trả về object rỗng nếu lỗi parse để tránh crash app
      return AiAssessmentResult(
        score: 0,
        feedback: "Không thể đọc dữ liệu từ AI.",
        radarChart: {},
        corrections: [],
      );
    }
  }
}

class AiCorrection {
  final String original;
  final String fixed;
  final String explanation;

  AiCorrection({
    required this.original,
    required this.fixed,
    required this.explanation,
  });

  factory AiCorrection.fromJson(Map<String, dynamic> json) {
    return AiCorrection(
      original: json['original'] ?? '',
      fixed: json['fixed'] ?? '',
      explanation: json['explanation'] ?? '',
    );
  }
}
