import 'package:flutter/material.dart';
import 'package:mobile/screens/admin/manage_schedule/widgets/schedule_calendar.dart';
import 'package:mobile/screens/admin/manage_schedule/widgets/schedule_header.dart';

class ManageScheduleContent extends StatelessWidget {
  const ManageScheduleContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1600),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              // === HEADER ===
              ScheduleHeader(),
              SizedBox(height: 24),

              // === CALENDAR ===
              Expanded(child: ScheduleCalendar()),
            ],
          ),
        ),
      ),
    );
  }
}
