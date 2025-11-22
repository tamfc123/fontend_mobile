// Helpers để parse dữ liệu an toàn
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

// ==========================================
// 1. MODEL DANH SÁCH (Nhẹ, dùng cho màn hình List)
// ==========================================
class QuizListModel {
  final String id;
  final String title;
  final String? description;
  final int timeLimitMinutes;
  final int questionCount;
  final String skillType;

  QuizListModel({
    required this.id,
    required this.title,
    this.description,
    required this.timeLimitMinutes,
    required this.questionCount,
    required this.skillType,
  });

  factory QuizListModel.fromJson(Map<String, dynamic> json) {
    return QuizListModel(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'],
      timeLimitMinutes: _parseInt(json['timeLimitMinutes']),
      questionCount: _parseInt(json['questionCount']),
      skillType: json['skillType'] ?? 'READING',
    );
  }
}

// ==========================================
// 2. MODEL CHI TIẾT (Nặng, dùng cho màn hình Detail/Create)
// ==========================================
class QuizDetailModel {
  final String id;
  final String title;
  final String? description;
  final int timeLimitMinutes;

  // 🔄 ĐỔI: classId -> courseId
  final String courseId;

  final String skillType;
  final String? readingPassage;

  // 🟢 MỚI: Link file nghe chung (cho bài Listening)
  final String? mediaUrl;

  final List<QuestionDetailModel> questions;

  QuizDetailModel({
    required this.id,
    required this.title,
    this.description,
    required this.timeLimitMinutes,
    required this.courseId,
    required this.skillType,
    this.readingPassage,
    this.mediaUrl,
    required this.questions,
  });

  // Phương thức copyWith để hỗ trợ cập nhật UI cục bộ (Optimistic UI)
  QuizDetailModel copyWith({
    String? title,
    int? questionCount, // Dùng ảo để cập nhật list
    List<QuestionDetailModel>? questions,
  }) {
    return QuizDetailModel(
      id: id,
      title: title ?? this.title,
      description: description,
      timeLimitMinutes: timeLimitMinutes,
      courseId: courseId,
      skillType: skillType,
      readingPassage: readingPassage,
      mediaUrl: mediaUrl,
      questions: questions ?? this.questions,
    );
  }

  factory QuizDetailModel.fromJson(Map<String, dynamic> json) {
    var questionList = json['questions'] as List? ?? [];
    List<QuestionDetailModel> questions =
        questionList.map((i) => QuestionDetailModel.fromJson(i)).toList();

    return QuizDetailModel(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'],
      timeLimitMinutes: _parseInt(json['timeLimitMinutes']),

      // ✅ Cập nhật map từ courseId
      courseId: json['courseId'] ?? '',

      skillType: json['skillType'] ?? 'READING',
      readingPassage: json['readingPassage'],

      // ✅ Map mediaUrl
      mediaUrl: json['mediaUrl'],

      questions: questions,
    );
  }
}

// ==========================================
// 3. MODEL CÂU HỎI
// ==========================================
class QuestionDetailModel {
  final String id;
  final String questionText;
  final String? audioUrl;
  final String questionType;
  final String? correctAnswerText;

  // 🟢 MỚI: Tag để vẽ biểu đồ Radar (VD: VOCABULARY)
  final String? tag;

  // 🟢 MỚI: Giải thích đáp án
  final String? explanation;

  final List<OptionDetailModel> options;

  QuestionDetailModel({
    required this.id,
    required this.questionText,
    this.audioUrl,
    required this.questionType,
    this.correctAnswerText,
    this.tag,
    this.explanation,
    required this.options,
  });

  factory QuestionDetailModel.fromJson(Map<String, dynamic> json) {
    var optionList = json['options'] as List? ?? [];
    List<OptionDetailModel> options =
        optionList.map((i) => OptionDetailModel.fromJson(i)).toList();

    return QuestionDetailModel(
      id: json['id'],
      questionText: json['questionText'] ?? '',
      audioUrl: json['audioUrl'],
      questionType: json['questionType'] ?? 'MULTIPLE_CHOICE',
      correctAnswerText: json['correctAnswerText'],

      // ✅ Map Tag và Explanation
      tag: json['tag'],
      explanation: json['explanation'],

      options: options,
    );
  }
}

// ==========================================
// 4. MODEL LỰA CHỌN (OPTION)
// ==========================================
class OptionDetailModel {
  final String id;
  final String optionText;

  // Lưu ý: Chỉ Admin mới thấy field này là true/false
  // Student model sau này sẽ không có field này hoặc luôn là null
  final bool isCorrect;

  OptionDetailModel({
    required this.id,
    required this.optionText,
    required this.isCorrect,
  });

  factory OptionDetailModel.fromJson(Map<String, dynamic> json) {
    return OptionDetailModel(
      id: json['id'],
      optionText: json['optionText'] ?? '',
      isCorrect: _parseBool(json['isCorrect']),
    );
  }
}
