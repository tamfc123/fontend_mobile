class StudentDetailModel {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String? phoneNumber;
  final DateTime? birthday;
  final int level;
  final int exp;
  final int streak;
  final DateTime joinedAt;

  StudentDetailModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.phoneNumber,
    this.birthday,
    required this.level,
    required this.exp,
    required this.streak,
    required this.joinedAt,
  });

  factory StudentDetailModel.fromJson(Map<String, dynamic> json) {
    return StudentDetailModel(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      avatarUrl: json['avatarUrl'],
      phoneNumber: json['phoneNumber'],
      birthday:
          json['birthday'] != null ? DateTime.parse(json['birthday']) : null,
      level: json['level'] ?? 1,
      exp: json['experiencePoints'] ?? 0,
      streak: json['currentStreak'] ?? 0,
      joinedAt: DateTime.parse(json['joinedClassAt']),
    );
  }
}
