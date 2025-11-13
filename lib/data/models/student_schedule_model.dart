class StudentScheduleModel {
  final int id;
  final int classId;
  final String className;
  final String courseName;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final String? room;
  final String? teacherName;

  StudentScheduleModel({
    required this.id,
    required this.classId,
    required this.className,
    required this.courseName,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.room,
    this.teacherName,
  });

  factory StudentScheduleModel.fromJson(Map<String, dynamic> json) {
    return StudentScheduleModel(
      id: json['id'],
      classId: json['classId'],
      className: json['className'],
      courseName: json['courseName'],
      dayOfWeek: json['dayOfWeek'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      room: json['room'],
      teacherName: json['teacherName'],
    );
  }
}
