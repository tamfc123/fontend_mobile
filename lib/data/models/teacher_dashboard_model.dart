// DTO cho các thẻ thống kê
class TeacherDashboardStatsModel {
  final int totalClasses;
  final int totalStudents;
  final int totalQuizzes;
  final int todayClasses;
  final int passCount;
  final int failCount;
  final List<int> gradeDistribution; // Backend gửi List<int>

  TeacherDashboardStatsModel({
    required this.totalClasses,
    required this.totalStudents,
    required this.totalQuizzes,
    required this.todayClasses,
    required this.passCount,
    required this.failCount,
    required this.gradeDistribution,
  });

  factory TeacherDashboardStatsModel.fromJson(Map<String, dynamic> json) {
    // Xử lý parse List<int> một cách an toàn
    final List<dynamic> gradesJson = json['gradeDistribution'] ?? [];
    final List<int> grades = gradesJson.map((e) => e as int).toList();

    return TeacherDashboardStatsModel(
      totalClasses: json['totalClasses'] ?? 0,
      totalStudents: json['totalStudents'] ?? 0,
      totalQuizzes: json['totalQuizzes'] ?? 0,
      todayClasses: json['todayClasses'] ?? 0,
      passCount: json['passCount'] ?? 0,
      failCount: json['failCount'] ?? 0,
      gradeDistribution: grades.isEmpty ? [0, 0, 0, 0, 0] : grades,
    );
  }
}

// DTO cho lịch học sắp tới (GIỮ NGUYÊN)
class TeacherUpcomingScheduleModel {
  final String scheduleId;
  final String className;
  final String courseName;
  final DateTime startTime; // Đã parse
  final String roomName;

  TeacherUpcomingScheduleModel({
    required this.scheduleId,
    required this.className,
    required this.courseName,
    required this.startTime,
    required this.roomName,
  });

  factory TeacherUpcomingScheduleModel.fromJson(Map<String, dynamic> json) {
    return TeacherUpcomingScheduleModel(
      scheduleId: json['scheduleId'],
      className: json['className'],
      courseName: json['courseName'],
      startTime: DateTime.parse(json['startTime']), // Parse string
      roomName: json['roomName'],
    );
  }
}

// DTO cho các lớp (truy cập nhanh) (GIỮ NGUYÊN)
class TeacherQuickClassModel {
  final String classId;
  final String className;
  final String courseName;
  final int studentCount;

  TeacherQuickClassModel({
    required this.classId,
    required this.className,
    required this.courseName,
    required this.studentCount,
  });

  factory TeacherQuickClassModel.fromJson(Map<String, dynamic> json) {
    return TeacherQuickClassModel(
      classId: json['classId'],
      className: json['className'],
      courseName: json['courseName'],
      studentCount: json['studentCount'],
    );
  }
}

// DTO tổng hợp (GIỮ NGUYÊN)
class TeacherDashboardModel {
  final TeacherDashboardStatsModel stats;
  final List<TeacherUpcomingScheduleModel> upcomingSchedules;
  final List<TeacherQuickClassModel> myClasses;

  TeacherDashboardModel({
    required this.stats,
    required this.upcomingSchedules,
    required this.myClasses,
  });

  factory TeacherDashboardModel.fromJson(Map<String, dynamic> json) {
    return TeacherDashboardModel(
      stats: TeacherDashboardStatsModel.fromJson(json['stats']),
      upcomingSchedules:
          (json['upcomingSchedules'] as List)
              .map((e) => TeacherUpcomingScheduleModel.fromJson(e))
              .toList(),
      myClasses:
          (json['myClasses'] as List)
              .map((e) => TeacherQuickClassModel.fromJson(e))
              .toList(),
    );
  }
}
