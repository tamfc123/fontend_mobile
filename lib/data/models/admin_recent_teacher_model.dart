// Model này khớp với AdminRecentTeacherDTO của C#
class AdminRecentTeacherModel {
  final String id;
  final String name;
  final String email;
  final DateTime createdAt;
  final bool isActive;

  AdminRecentTeacherModel({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
    required this.isActive,
  });

  factory AdminRecentTeacherModel.fromJson(Map<String, dynamic> json) {
    return AdminRecentTeacherModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isActive: json['isActive'] as bool,
    );
  }
}
