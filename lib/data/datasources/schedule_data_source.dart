import 'package:flutter/material.dart';
import 'package:mobile/data/models/class_schedule_model.dart';
import 'package:mobile/data/models/room_model.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class ScheduleDataSource extends CalendarDataSource {
  ScheduleDataSource(
    List<ClassScheduleModel> schedules,
    List<RoomModel> rooms,
  ) {
    // 1. Gán resources (Danh sách phòng học)
    // Syncfusion hỗ trợ ID là Object (String/Int đều được)
    resources =
        rooms.map((room) {
          return CalendarResource(
            id: room.id,
            displayName: room.name,
            color: const Color(0xFFE3F2FD), // Màu nền cột resource
          );
        }).toList();

    // 2. Gán appointments (Lịch học đã "bung" ra từng ngày)
    appointments = _expandSchedules(schedules, rooms);
  }

  // Hàm mở rộng lịch: Biến 1 Schedule (Duration dài) thành nhiều Appointment (Từng ngày lẻ)
  List<Appointment> _expandSchedules(
    List<ClassScheduleModel> source,
    List<RoomModel> rooms,
  ) {
    List<Appointment> expanded = [];

    // Tạo Set ID phòng để check nhanh xem lịch có thuộc phòng hợp lệ không
    final validRoomIds = rooms.map((r) => r.id).toSet();

    for (var schedule in source) {
      // 1. Kiểm tra xem lịch có gắn với phòng nào đang hiển thị không
      // Nếu roomId của lịch không nằm trong danh sách rooms active -> Bỏ qua
      if (!validRoomIds.contains(schedule.roomId)) {
        continue;
      }

      // 2. Xử lý ngày giờ UTC để lặp
      DateTime startDateUtc = schedule.startDate.toUtc();
      DateTime endDateUtc = schedule.endDate.toUtc();

      // Chuẩn hóa về đầu ngày (00:00:00) để loop chính xác
      DateTime current = DateTime.utc(
        startDateUtc.year,
        startDateUtc.month,
        startDateUtc.day,
      );
      DateTime endLoop = DateTime.utc(
        endDateUtc.year,
        endDateUtc.month,
        endDateUtc.day,
      );

      // Convert "Thứ 2" -> int (1..7)
      final targetWeekday = _dayStringToInt(schedule.dayOfWeek);
      if (targetWeekday == -1) {
        continue;
      }

      // 3. Vòng lặp tạo Appointment cho từng ngày
      while (!current.isAfter(endLoop)) {
        if (current.weekday == targetWeekday) {
          // Parse giờ: "07:00" -> hour=7, minute=0
          try {
            final startParts = schedule.startTime.split(":");
            final endParts = schedule.endTime.split(":");

            if (startParts.length == 2 && endParts.length == 2) {
              final hourStart = int.parse(startParts[0]);
              final minuteStart = int.parse(startParts[1]);
              final hourEnd = int.parse(endParts[0]);
              final minuteEnd = int.parse(endParts[1]);

              // Tạo DateTime Local để hiển thị lên lịch
              final apptStart = DateTime(
                current.year,
                current.month,
                current.day,
                hourStart,
                minuteStart,
              );
              final apptEnd = DateTime(
                current.year,
                current.month,
                current.day,
                hourEnd,
                minuteEnd,
              );

              // Nội dung hiển thị trên ô lịch
              final String teacher = schedule.teacherName ?? 'Chưa có GV';
              final String subject = '${schedule.className}\n$teacher';

              expanded.add(
                Appointment(
                  startTime: apptStart,
                  endTime: apptEnd,
                  subject: subject,
                  id: schedule, // ✅ Lưu Model gốc vào ID để khi Tap lấy lại được
                  color: _getColorForClass(schedule.className),
                  resourceIds: [
                    schedule.roomId,
                  ], // ✅ Map vào cột Phòng bằng GUID
                ),
              );
            }
          } catch (e) {
            debugPrint("Lỗi parse giờ cho lịch ${schedule.id}: $e");
          }
        }
        // Tăng 1 ngày
        current = current.add(const Duration(days: 1));
      }
    }
    return expanded;
  }

  // Helper: Chọn màu dựa trên tên lớp (để các ô cùng lớp cùng màu)
  Color _getColorForClass(String className) {
    final colors = [
      Colors.blue.shade400,
      Colors.teal.shade400,
      Colors.indigo.shade400,
      Colors.orange.shade400,
      Colors.purple.shade400,
      Colors.pink.shade400,
      Colors.cyan.shade400,
    ];
    return colors[className.hashCode.abs() % colors.length];
  }

  int _dayStringToInt(String day) {
    switch (day.toLowerCase()) {
      case 'thứ 2':
        return DateTime.monday;
      case 'thứ 3':
        return DateTime.tuesday;
      case 'thứ 4':
        return DateTime.wednesday;
      case 'thứ 5':
        return DateTime.thursday;
      case 'thứ 6':
        return DateTime.friday;
      case 'thứ 7':
        return DateTime.saturday;
      case 'chủ nhật':
        return DateTime.sunday;
      default:
        return -1;
    }
  }
}
