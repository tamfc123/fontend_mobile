class ClassScheduleModel {
  final String id;
  final String classId;
  final String className;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final String roomId;
  final String? roomName;
  final String? teacherName;
  final DateTime startDate;
  final DateTime endDate;
  final String teacherId;

  ClassScheduleModel({
    required this.id,
    required this.classId,
    required this.className,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.roomId,
    required this.roomName,
    required this.teacherName,
    required this.startDate,
    required this.endDate,
    required this.teacherId,
  });

  factory ClassScheduleModel.fromJson(Map<String, dynamic> json) {
    return ClassScheduleModel(
      id: json['id'],
      classId: json['classId'],
      className: json['className'] ?? '',
      dayOfWeek: json['dayOfWeek'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      roomId: json['roomId'] ?? '',
      roomName: json['roomName'],

      teacherName: json['teacherName'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      teacherId: json['teacherId'],
    );
  }

  // Dùng khi gọi API PUT/POST lẻ (ClassScheduleRequestDTO)
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "classId": classId,
      "dayOfWeek": _convertDayOfWeekToInt(dayOfWeek),
      "startTime": startTime,
      "endTime": endTime,
      "roomId": roomId,
      "teacherName": teacherName,
      "startDate": startDate.toIso8601String(),
      "endDate": endDate.toIso8601String(),
      "teacherId": teacherId,
    };
  }

  // Cập nhật copyWith
  ClassScheduleModel copyWith({
    String? id,
    String? classId,
    String? className,
    String? dayOfWeek,
    String? startTime,
    String? endTime,
    String? roomId,
    String? roomName,
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
      roomId: roomId ?? this.roomId,
      roomName: roomName ?? this.roomName,
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
