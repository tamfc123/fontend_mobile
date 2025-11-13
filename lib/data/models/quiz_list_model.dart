// lib/data/models/quiz_list_model.dart

class QuizListModel {
  final int id;
  final String title;
  final String? description;
  final int timeLimitMinutes;
  final int questionCount;

  // ✅ THÊM MỚI
  final String skillType;

  QuizListModel({
    required this.id,
    required this.title,
    this.description,
    required this.timeLimitMinutes,
    required this.questionCount,

    // ✅ THÊM MỚI
    required this.skillType,
  });

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  factory QuizListModel.fromJson(Map<String, dynamic> json) {
    return QuizListModel(
      id: _parseInt(json['id']),
      title: json['title'] ?? '',
      description: json['description'],
      timeLimitMinutes: _parseInt(json['timeLimitMinutes']),
      questionCount: _parseInt(json['questionCount']),

      // ✅ THÊM MỚI (Lấy từ API)
      skillType: json['skillType'] ?? 'READING', // Mặc định là READING
    );
  }
}
