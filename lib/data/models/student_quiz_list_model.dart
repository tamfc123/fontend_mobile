class StudentQuizListModel {
  final int id;
  final String title;
  final int timeLimitMinutes;
  final int questionCount;
  final String status; // "Pending" hoặc "Submitted"

  // ✅ THÊM MỚI
  final String skillType;

  StudentQuizListModel({
    required this.id,
    required this.title,
    required this.timeLimitMinutes,
    required this.questionCount,
    required this.status,
    // ✅ THÊM MỚI
    required this.skillType,
  });

  factory StudentQuizListModel.fromJson(Map<String, dynamic> json) {
    return StudentQuizListModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      timeLimitMinutes: json['timeLimitMinutes'] ?? 0,
      questionCount: json['questionCount'] ?? 0,
      status: json['status'] ?? 'Pending',

      // ✅ THÊM MỚI
      skillType: json['skillType'] ?? 'READING', // Mặc định là READING
    );
  }
}
