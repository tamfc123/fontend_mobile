import 'package:flutter/material.dart';
import 'package:mobile/data/datasources/teacher_schedule_data_source.dart';
import 'package:mobile/data/models/teacher_schedule_model.dart';
import 'package:mobile/screens/teacher/manage_schedule/manage_teacher_schedule_view_model.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class TeacherScheduleScreen extends StatefulWidget {
  const TeacherScheduleScreen({super.key});

  @override
  State<TeacherScheduleScreen> createState() => _TeacherScheduleScreenState();
}

class _TeacherScheduleScreenState extends State<TeacherScheduleScreen> {
  final CalendarController _calendarController = CalendarController();
  TeacherScheduleModel? _selectedSchedule;
  String _selectedDay = 'Tất cả';
  final Map<String, int?> _dayOptions = {
    'Tất cả': null,
    'Thứ 2': 2,
    'Thứ 3': 3,
    'Thứ 4': 4,
    'Thứ 5': 5,
    'Thứ 6': 6,
    'Thứ 7': 7,
    'Chủ nhật': 8,
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ManageTeacherScheduleViewModel>().fetchSchedules();
    });
  }

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
    final viewModel = context.watch<ManageTeacherScheduleViewModel>();
    final schedules = viewModel.schedules;
    final isLoading = viewModel.isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Lịch giảng dạy',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Filter Bar + Thống kê
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Filter dropdown
                    DropdownButton<String>(
                      value: _selectedDay,
                      items:
                          _dayOptions.keys
                              .map(
                                (day) => DropdownMenuItem(
                                  value: day,
                                  child: Text(day),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedDay = value);
                          final dayValue = _dayOptions[_selectedDay];
                          viewModel.fetchSchedules(dayOfWeek: dayValue);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    if (schedules.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              color: Colors.blue,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Tổng số lịch học: ${schedules.length}',
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Tuần trước / tuần sau
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: _goToPreviousWeek,
                  icon: const Icon(Icons.arrow_back, color: Colors.blue),
                  label: const Text(
                    "Tuần trước",
                    style: TextStyle(color: Colors.blue),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Colors.blue, width: 1.5),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: _goToNextWeek,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Colors.blue, width: 1.5),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text("Tuần sau", style: TextStyle(color: Colors.blue)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, color: Colors.blue),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Calendar + Panel chi tiết
            Expanded(
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : schedules.isEmpty
                      ? Center(
                        child: Text(
                          'Chưa có lịch học nào.',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                      )
                      : Row(
                        children: [
                          // Calendar
                          Expanded(
                            flex: 2,
                            child: SfCalendar(
                              controller: _calendarController,
                              view: CalendarView.week,
                              firstDayOfWeek: 1,
                              dataSource: TeacherScheduleDataSource(schedules),
                              onTap: (details) {
                                if (details.appointments != null &&
                                    details.appointments!.isNotEmpty) {
                                  final Appointment appointment =
                                      details.appointments!.first
                                          as Appointment;

                                  final schedule =
                                      appointment.id
                                          as TeacherScheduleModel; // ✅ lấy lại object gốc

                                  setState(() {
                                    _selectedSchedule = schedule;
                                  });
                                }
                              },
                              timeSlotViewSettings: const TimeSlotViewSettings(
                                startHour: 7,
                                endHour: 24,
                                timeInterval: Duration(minutes: 60),
                                timeFormat: 'HH:mm',
                              ),
                              headerStyle: CalendarHeaderStyle(
                                backgroundColor: Colors.blue.shade200,
                                textAlign: TextAlign.center,
                                textStyle: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              todayHighlightColor: Colors.blue,
                              appointmentTextStyle: const TextStyle(
                                color: Colors.white,
                              ),
                              appointmentBuilder: (context, details) {
                                final appointment = details.appointments.first;
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade300,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  padding: const EdgeInsets.all(6),
                                  child: Text(
                                    appointment.subject,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Panel chi tiết
                          Expanded(
                            flex: 1,
                            child:
                                _selectedSchedule == null
                                    ? Center(
                                      child: Text(
                                        'Chọn một lịch học để xem chi tiết',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    )
                                    : Card(
                                      color: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Lớp: ${_selectedSchedule!.className}",
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              "Phòng: ${_selectedSchedule!.roomName}",
                                            ),
                                            Text(
                                              "Thời gian: ${_selectedSchedule!.startTime} - ${_selectedSchedule!.endTime}",
                                            ),
                                            Text(
                                              "Ngày: ${_selectedSchedule!.dayOfWeek}",
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                          ),
                        ],
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
