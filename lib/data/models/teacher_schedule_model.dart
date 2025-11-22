class TeacherScheduleModel {
  final String id;
  final String classId;
  final String className;
  // ✅ THÊM CourseName
  final String courseName;
  final String dayOfWeek;
  final String startTime;
  final String endTime;

  // ✅ CẬP NHẬT Tên Room
  final String roomName;
  // Bạn có thể giữ RoomId nếu cần, nhưng tôi sẽ dùng RoomName để đơn giản

  final DateTime startDate;
  final DateTime endDate;
  final String teacherName;

  TeacherScheduleModel({
    required this.id,
    required this.classId,
    required this.className,
    required this.courseName, // ✅ Mới
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.roomName, // ✅ Đã sửa
    required this.startDate,
    required this.endDate,
    required this.teacherName,
  });

  factory TeacherScheduleModel.fromJson(Map<String, dynamic> json) {
    return TeacherScheduleModel(
      id: json['id'],
      classId: json['classId'],
      className: json['className'] ?? '',
      courseName: json['courseName'] ?? '', // ✅ Map CourseName
      dayOfWeek: json['dayOfWeek'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      roomName: json['roomName'] ?? 'Unknown', // ✅ Map RoomName
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      teacherName: json['teacherName'] ?? '',
    );
  }

  // Phương thức toJson nên được cập nhật cẩn thận để gửi lại đúng format API Backend mong muốn
  // Hiện tại, Controller chỉ là GET, nên tôi chỉ sửa FromJson.
  // Tuy nhiên, nếu dùng để POST/PUT, cần kiểm tra cấu trúc JSON đầu vào (ví dụ: có cần DayOfWeek dạng int không?)
  // Với JSON hiện tại cho POST/PUT, tôi giữ nguyên phương thức toJson, nhưng lưu ý: Backend cần DayOfWeek là số (int).

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'classId': classId,
      'className': className,
      // 'courseName': courseName, // Thường không gửi lại
      'dayOfWeek': _convertDayOfWeekToInt(dayOfWeek),
      'startTime': startTime,
      'endTime': endTime,
      // 'room' trong Model cũ của bạn, nhưng API C# dùng RoomId cho POST/PUT.
      // Tôi sẽ giả định POST/PUT cần 'DayOfWeek' (int), 'StartTime', 'EndTime', 'RoomId', 'ClassId', 'TeacherId'
      // Để đơn giản, tôi giữ nguyên cấu trúc cũ, nhưng lưu ý cần xem lại POST/PUT DTO.
      // Dưới đây là Json cho mục đích kiểm tra.

      // ✅ GIỮ NGUYÊN toJson, nhưng lưu ý trường Room và RoomId
      // Hiện tại, model không có roomId, tôi dùng roomName cho trường 'room' cũ
      'room': roomName,
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
