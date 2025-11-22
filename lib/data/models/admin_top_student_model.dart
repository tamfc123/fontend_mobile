// Model này khớp với AdminTopStudentDTO của C#
class AdminTopStudentModel {
  final String id;
  final String name;
  final String email;
  final int level;
  final int experiencePoints;
  final String? avatarUrl; // ✅ Đã thêm avatar

  AdminTopStudentModel({
    required this.id,
    required this.name,
    required this.email,
    required this.level,
    required this.experiencePoints,
    this.avatarUrl,
  });

  factory AdminTopStudentModel.fromJson(Map<String, dynamic> json) {
    return AdminTopStudentModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      level: json['level'] as int,
      experiencePoints: json['experiencePoints'] as int,
      avatarUrl: json['avatarUrl'] as String?, // ✅ Thêm avatar
    );
  }
}
