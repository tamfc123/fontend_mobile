class StudentScheduleModel {
  final String id;
  final String classId;
  final String className;
  final String courseName;
  final String? room;
  final String? teacherName;
  final int dayOfWeek;
  final String startTime;
  final String endTime;
  final DateTime startDate;
  final DateTime endDate;

  StudentScheduleModel({
    required this.id,
    required this.classId,
    required this.className,
    required this.courseName,
    this.room,
    this.teacherName,
    required this.dayOfWeek, // ✅
    required this.startTime,
    required this.endTime,
    required this.startDate,
    required this.endDate,
  });

  factory StudentScheduleModel.fromJson(Map<String, dynamic> json) {
    return StudentScheduleModel(
      id: json['id'],
      classId: json['classId'],
      className: json['className'] ?? '',
      courseName: json['courseName'] ?? '',
      room: json['room'],
      teacherName: json['teacherName'],
      dayOfWeek: json['dayOfWeek'] ?? 0,
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
    );
  }
}
