import 'package:flutter/material.dart';
import 'package:mobile/data/models/class_schedule_model.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class ScheduleDataSource extends CalendarDataSource {
  ScheduleDataSource(List<ClassScheduleModel> source) {
    appointments = _expandSchedules(source);
  }

  List<Appointment> _expandSchedules(List<ClassScheduleModel> source) {
    List<Appointment> expanded = [];

    for (var schedule in source) {
      DateTime current = schedule.startDate;
      final weekday = _dayStringToInt(schedule.dayOfWeek);

      while (!current.isAfter(schedule.endDate)) {
        if (current.weekday == weekday) {
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
                  "${schedule.className}\nPhòng: ${schedule.room ?? 'N/A'}\nGV: ${schedule.teacherName ?? ''}\nGiờ: ${schedule.startTime} - ${schedule.endTime}",
              color: Colors.blue.shade100,
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
        return 1;
      case 'thứ 3':
        return 2;
      case 'thứ 4':
        return 3;
      case 'thứ 5':
        return 4;
      case 'thứ 6':
        return 5;
      case 'thứ 7':
        return 6;
      case 'chủ nhật':
        return 7;
      default:
        return 1;
    }
  }
}
