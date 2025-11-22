class StudentQuizListModel {
  final String id;
  final String title;
  final int timeLimitMinutes;
  final int questionCount;
  final String status; // "Pending" hoặc "Submitted"
  final String skillType;

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
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      timeLimitMinutes: json['timeLimitMinutes'] ?? 0,
      questionCount: json['questionCount'] ?? 0,
      status: json['status'] ?? 'Pending',
      skillType: json['skillType'] ?? 'READING', // Mặc định là READING
    );
  }
}
