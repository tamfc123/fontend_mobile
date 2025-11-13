class StudentInClassModel {
  final String studentId;
  final String studentName;
  final String email;
  final String? avatarUrl;
  final DateTime joinedAt;
  final int? level;
  final int experiencePoints;

  StudentInClassModel({
    required this.studentId,
    required this.studentName,
    required this.email,
    this.avatarUrl,
    required this.joinedAt,
    this.level,
    required this.experiencePoints,
  });

  // Factory constructor để parse JSON
  factory StudentInClassModel.fromJson(Map<String, dynamic> json) {
    return StudentInClassModel(
      studentId: json['studentId'],
      studentName: json['studentName'],
      email: json['email'],
      avatarUrl: json['avatarUrl'],
      joinedAt: DateTime.parse(json['joinedAt']), // Chuyển string sang DateTime
      level: json['level'],
      experiencePoints: json['experiencePoints'],
    );
  }
}
