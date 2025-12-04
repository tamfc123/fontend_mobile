import 'package:flutter/material.dart';
import 'package:mobile/data/datasources/schedule_data_source.dart';
import 'package:mobile/data/models/class_schedule_model.dart';
import 'package:mobile/screens/admin/manage_schedule/manage_schedule_view_model.dart';
import 'package:mobile/screens/admin/manage_schedule/widgets/schedule_detail_panel.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class ScheduleCalendar extends StatefulWidget {
  const ScheduleCalendar({super.key});

  @override
  State<ScheduleCalendar> createState() => _ScheduleCalendarState();
}

class _ScheduleCalendarState extends State<ScheduleCalendar> {
  final CalendarController _calendarController = CalendarController();
  ClassScheduleModel? _selectedSchedule;
  static const Color primaryBlue = Colors.blue;

  void _goToPreviousWeek() {
    _calendarController.displayDate = _calendarController.displayDate!.subtract(
      const Duration(days: 7),
    );
  }

  void _goToNextWeek() {
    _calendarController.displayDate = _calendarController.displayDate!.add(
      const Duration(days: 7),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ManageScheduleViewModel>(
      builder: (context, viewModel, child) {
        final schedules = viewModel.schedules;
        final rooms = viewModel.activeRooms;
        final isLoading = viewModel.isLoading;

        final dataSource = ScheduleDataSource(schedules, rooms);

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _goToPreviousWeek,
                      icon: const Icon(Icons.arrow_back_ios_new, size: 16),
                      label: const Text('Tuần trước'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: _goToNextWeek,
                      icon: const Icon(Icons.arrow_forward_ios, size: 16),
                      label: const Text('Tuần sau'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child:
                    isLoading && schedules.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: SfCalendar(
                                controller: _calendarController,
                                view: CalendarView.timelineWeek,
                                firstDayOfWeek: 1,
                                dataSource: dataSource,
                                onTap: (details) {
                                  if (details.appointments?.isNotEmpty ??
                                      false) {
                                    final Appointment appointment =
                                        details.appointments!.first;
                                    if (appointment.id is ClassScheduleModel) {
                                      setState(
                                        () =>
                                            _selectedSchedule =
                                                appointment.id
                                                    as ClassScheduleModel,
                                      );
                                    }
                                  } else {
                                    setState(() => _selectedSchedule = null);
                                  }
                                },
                                timeSlotViewSettings:
                                    const TimeSlotViewSettings(
                                      startHour: 7,
                                      endHour: 22,
                                      timeFormat: 'HH:mm',
                                    ),
                              ),
                            ),
                            Container(width: 1, color: Colors.grey.shade300),
                            Expanded(
                              flex: 1,
                              child: ScheduleDetailPanel(
                                schedule: _selectedSchedule,
                                onDeleted: () {
                                  setState(() {
                                    _selectedSchedule = null;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
              ),
            ],
          ),
        );
      },
    );
  }
}
