class AdminDashboardStatsModel {
  final int totalUsers;
  final int totalTeachers;
  final int totalStudents;
  final int totalClasses;
  final int totalQuizzes;

  AdminDashboardStatsModel({
    required this.totalUsers,
    required this.totalTeachers,
    required this.totalStudents,
    required this.totalClasses,
    required this.totalQuizzes,
  });

  factory AdminDashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return AdminDashboardStatsModel(
      totalUsers: json['totalUsers'] ?? 0,
      totalTeachers: json['totalTeachers'] ?? 0,
      totalStudents: json['totalStudents'] ?? 0,
      totalClasses: json['totalClasses'] ?? 0,
      totalQuizzes: json['totalQuizzes'] ?? 0,
    );
  }
}
