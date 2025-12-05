import 'package:flutter/material.dart';
import 'package:mobile/data/datasources/teacher_schedule_data_source.dart';
import 'package:mobile/data/models/teacher_schedule_model.dart';
import 'package:mobile/screens/teacher/manage_schedule/manage_teacher_schedule_view_model.dart';
import 'package:mobile/screens/teacher/manage_schedule/widgets/teacher_schedule_header.dart';
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

    // Responsive padding
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final horizontalPadding =
        isMobile ? 12.0 : (screenWidth < 1024 ? 16.0 : 24.0);
    final verticalSpacing = isMobile ? 16.0 : 20.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Padding(
        padding: EdgeInsets.all(horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Component
            TeacherScheduleHeader(
              selectedDay: _selectedDay,
              onDayChanged: (value) {
                if (value != null) {
                  setState(() => _selectedDay = value);
                  final dayValue = _dayOptions[_selectedDay];
                  viewModel.fetchSchedules(dayOfWeek: dayValue);
                }
              },
              scheduleCount: schedules.length,
              dayOptions: _dayOptions,
            ),
            SizedBox(height: verticalSpacing),
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
                      : isMobile
                      ? // MOBILE: Full-width calendar, detail in bottom sheet
                      SfCalendar(
                        controller: _calendarController,
                        view: CalendarView.week,
                        firstDayOfWeek: 1,
                        dataSource: TeacherScheduleDataSource(schedules),
                        onTap: (details) {
                          if (details.appointments != null &&
                              details.appointments!.isNotEmpty) {
                            final Appointment appointment =
                                details.appointments!.first;
                            final schedule =
                                appointment.id as TeacherScheduleModel;

                            // Show bottom sheet on mobile
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder:
                                  (context) => Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(20),
                                      ),
                                    ),
                                    padding: EdgeInsets.fromLTRB(
                                      20,
                                      20,
                                      20,
                                      MediaQuery.of(context).viewInsets.bottom +
                                          20,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Handle bar
                                        Center(
                                          child: Container(
                                            width: 40,
                                            height: 4,
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade300,
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        Text(
                                          'Chi tiết lịch học',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1E3A8A),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        _buildDetailRow(
                                          'Lớp',
                                          schedule.className,
                                          Icons.class_,
                                        ),
                                        _buildDetailRow(
                                          'Phòng',
                                          schedule.roomName,
                                          Icons.meeting_room,
                                        ),
                                        _buildDetailRow(
                                          'Thời gian',
                                          '${schedule.startTime} - ${schedule.endTime}',
                                          Icons.access_time,
                                        ),
                                        _buildDetailRow(
                                          'Ngày',
                                          schedule.dayOfWeek,
                                          Icons.calendar_today,
                                        ),
                                        const SizedBox(height: 16),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed:
                                                () => Navigator.pop(context),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blue,
                                              padding: EdgeInsets.symmetric(
                                                vertical: 12,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: Text(
                                              'Đóng',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                            );
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
                      )
                      : // DESKTOP: Calendar + fixed sidebar
                      Row(
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
                                      details.appointments!.first;
                                  final schedule =
                                      appointment.id as TeacherScheduleModel;

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
                          // Panel chi tiết (desktop sidebar)
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

  // Helper to build detail row for bottom sheet
  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
