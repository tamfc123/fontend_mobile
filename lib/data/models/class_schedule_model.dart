class ClassScheduleModel {
  final int id;
  final int classId;
  final String className;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final String? room;
  final String? teacherName;
  final DateTime startDate; // <-- mới
  final DateTime endDate; // <-- mới
  final String teacherId;

  ClassScheduleModel({
    required this.id,
    required this.classId,
    required this.className,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.room,
    required this.teacherName,
    required this.startDate,
    required this.endDate,
    required this.teacherId,
  });

  factory ClassScheduleModel.fromJson(Map<String, dynamic> json) {
    return ClassScheduleModel(
      id: json['id'] ?? 0,
      classId: json['classId'],
      className: json['className'],
      dayOfWeek: json['dayOfWeek'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      room: json['room'],
      teacherName: json['teacherName'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      teacherId: json['teacherId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "classId": classId,
      "dayOfWeek": _convertDayOfWeekToInt(dayOfWeek),
      "startTime": startTime,
      "endTime": endTime,
      "room": room,
      "teacherName": teacherName,
      "startDate": startDate.toIso8601String(),
      "endDate": endDate.toIso8601String(),
      "teacherId": teacherId,
    };
  }

  // Thêm copyWith
  ClassScheduleModel copyWith({
    int? id,
    int? classId,
    String? className,
    String? dayOfWeek,
    String? startTime,
    String? endTime,
    String? room,
    String? teacherName,
    DateTime? startDate,
    DateTime? endDate,
    String? teacherId,
  }) {
    return ClassScheduleModel(
      id: id ?? this.id,
      classId: classId ?? this.classId,
      className: className ?? this.className,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      room: room ?? this.room,
      teacherName: teacherName ?? this.teacherName,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      teacherId: teacherId ?? this.teacherId,
    );
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
