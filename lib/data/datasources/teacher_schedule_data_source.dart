import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:mobile/data/models/teacher_schedule_model.dart';

class TeacherScheduleDataSource extends CalendarDataSource {
  TeacherScheduleDataSource(List<TeacherScheduleModel> source) {
    appointments = _expandSchedules(source);
  }

  List<Appointment> _expandSchedules(List<TeacherScheduleModel> source) {
    final List<Appointment> expanded = [];

    for (var schedule in source) {
      DateTime current = schedule.startDate;
      final weekday = _dayStringToInt(schedule.dayOfWeek);

      while (!current.isAfter(schedule.endDate)) {
        if (current.weekday == weekday) {
          // tách giờ: "08:00"
          final startParts = schedule.startTime.split(":");
          final endParts = schedule.endTime.split(":");

          final startDate = DateTime(
            current.year,
            current.month,
            current.day,
            int.parse(startParts[0]),
            int.parse(startParts[1]),
          );

          final endDate = DateTime(
            current.year,
            current.month,
            current.day,
            int.parse(endParts[0]),
            int.parse(endParts[1]),
          );

          expanded.add(
            Appointment(
              startTime: startDate,
              endTime: endDate,
              subject:
                  "${schedule.className}\nPhòng: ${schedule.roomName ?? 'N/A'}\nGV: ${schedule.teacherName ?? ''}\nGiờ: ${schedule.startTime} - ${schedule.endTime}",
              color: Colors.blue.shade300,
              id: schedule,
            ),
          );
        }
        current = current.add(const Duration(days: 1));
      }
    }

    return expanded;
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
        return DateTime.monday;
    }
  }
}
