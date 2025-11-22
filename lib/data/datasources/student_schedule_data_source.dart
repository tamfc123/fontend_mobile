import 'package:flutter/material.dart';
import 'package:mobile/data/models/student_schedule_model.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class StudentScheduleDataSource extends CalendarDataSource {
  StudentScheduleDataSource(List<StudentScheduleModel> source) {
    appointments = _expandSchedules(source);
  }

  List<Appointment> _expandSchedules(List<StudentScheduleModel> source) {
    List<Appointment> expanded = [];

    for (var schedule in source) {
      DateTime startDateUtc = schedule.startDate.toUtc();
      DateTime endDateUtc = schedule.endDate.toUtc();

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

      // ✅ LOGIC CHUYỂN ĐỔI CHÍNH XÁC:
      // Backend quy ước: 2=Thứ 2, ..., 7=Thứ 7, 8=Chủ Nhật
      // Flutter DateTime: 1=Thứ 2, ..., 6=Thứ 7, 7=Chủ Nhật

      int targetFlutterWeekday;
      if (schedule.dayOfWeek == 8) {
        targetFlutterWeekday = DateTime.sunday; // 8 -> 7
      } else {
        targetFlutterWeekday =
            schedule.dayOfWeek - 1; // 2 -> 1 (Thứ 2), 3 -> 2...
      }

      // Validate
      if (targetFlutterWeekday < 1 || targetFlutterWeekday > 7) {
        // Skip nếu dữ liệu sai
        continue;
      }

      // Vòng lặp tạo lịch
      while (!current.isAfter(endLoop)) {
        if (current.weekday == targetFlutterWeekday) {
          try {
            final startParts = schedule.startTime.split(":");
            final endParts = schedule.endTime.split(":");

            if (startParts.length == 2 && endParts.length == 2) {
              final hourStart = int.parse(startParts[0]);
              final minuteStart = int.parse(startParts[1]);
              final hourEnd = int.parse(endParts[0]);
              final minuteEnd = int.parse(endParts[1]);

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

              expanded.add(
                Appointment(
                  startTime: apptStart,
                  endTime: apptEnd,
                  subject: schedule.className,
                  notes: 'Phòng: ${schedule.room ?? "N/A"}',
                  location: schedule.room,
                  color: _getColor(schedule.className),
                  id: schedule,
                ),
              );
            }
          } catch (e) {
            debugPrint("Lỗi parse giờ: $e");
          }
        }
        // Tăng ngày
        current = current.add(const Duration(days: 1));
      }
    }
    return expanded;
  }

  Color _getColor(String s) {
    final colors = [
      Colors.blue,
      Colors.teal,
      Colors.orange,
      Colors.purple,
      Colors.redAccent,
      Colors.indigo,
    ];
    return colors[s.hashCode.abs() % colors.length];
  }
}
