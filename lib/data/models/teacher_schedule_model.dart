class TeacherScheduleModel {
  final int id;
  final int classId;
  final String className;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final String? room;
  final DateTime startDate;
  final DateTime endDate;
  final String? teacherName;

  TeacherScheduleModel({
    required this.id,
    required this.classId,
    required this.className,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.room,
    required this.startDate,
    required this.endDate,
    this.teacherName,
  });

  factory TeacherScheduleModel.fromJson(Map<String, dynamic> json) {
    return TeacherScheduleModel(
      id: json['id'] ?? 0,
      classId: json['classId'] ?? 0,
      className: json['className'] ?? '',
      dayOfWeek: json['dayOfWeek'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      room: json['room'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      teacherName: json['teacherName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'classId': classId,
      'className': className,
      'dayOfWeek': _convertDayOfWeekToInt(dayOfWeek),
      'startTime': startTime,
      'endTime': endTime,
      'room': room,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'teacherName': teacherName,
    };
  }

  static int _convertDayOfWeekToInt(String day) {
    switch (day) {
      case "Thứ 2":
        return 2;
      case "Thứ 3":
        return 3;
      case "Thứ 4":
        return 4;
      case "Thứ 5":
        return 5;
      case "Thứ 6":
        return 6;
      case "Thứ 7":
        return 7;
      case "Chủ nhật":
        return 8;
      default:
        return 0;
    }
  }
}
