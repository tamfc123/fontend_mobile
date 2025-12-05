import 'package:flutter/material.dart';
import 'package:mobile/data/datasources/schedule_data_source.dart';
import 'package:mobile/data/models/class_schedule_model.dart';
import 'package:mobile/screens/admin/manage_schedule/manage_schedule_view_model.dart';
import 'package:mobile/screens/admin/manage_schedule/widgets/schedule_detail_panel.dart';
import 'package:mobile/screens/admin/manage_schedule/widgets/schedule_form_dialog.dart';
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
                    // Previous Week Button
                    GestureDetector(
                      onTap: _goToPreviousWeek,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: primaryBlue.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.chevron_left,
                              color: primaryBlue,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Tuần trước',
                              style: TextStyle(
                                color: primaryBlue,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Next Week Button
                    GestureDetector(
                      onTap: _goToNextWeek,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: primaryBlue.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Tuần sau',
                              style: TextStyle(
                                color: primaryBlue,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.chevron_right,
                              color: primaryBlue,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child:
                    isLoading && schedules.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : _buildResponsiveCalendar(
                          context,
                          schedules,
                          rooms,
                          dataSource,
                        ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResponsiveCalendar(
    BuildContext context,
    List<ClassScheduleModel> schedules,
    List<dynamic> rooms,
    ScheduleDataSource dataSource,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    if (isMobile) {
      // MOBILE: Full-width calendar, detail in bottom sheet
      return SfCalendar(
        controller: _calendarController,
        view: CalendarView.timelineWeek,
        firstDayOfWeek: 1,
        dataSource: dataSource,
        onTap: (details) {
          if (details.appointments?.isNotEmpty ?? false) {
            final Appointment appointment = details.appointments!.first;
            if (appointment.id is ClassScheduleModel) {
              final schedule = appointment.id as ClassScheduleModel;
              _showScheduleBottomSheet(context, schedule);
            }
          }
        },
        timeSlotViewSettings: const TimeSlotViewSettings(
          startHour: 7,
          endHour: 22,
          timeFormat: 'HH:mm',
        ),
      );
    } else {
      // DESKTOP: Calendar + fixed sidebar
      return Row(
        children: [
          Expanded(
            flex: 3,
            child: SfCalendar(
              controller: _calendarController,
              view: CalendarView.timelineWeek,
              firstDayOfWeek: 1,
              dataSource: dataSource,
              onTap: (details) {
                if (details.appointments?.isNotEmpty ?? false) {
                  final Appointment appointment = details.appointments!.first;
                  if (appointment.id is ClassScheduleModel) {
                    setState(
                      () =>
                          _selectedSchedule =
                              appointment.id as ClassScheduleModel,
                    );
                  }
                } else {
                  setState(() => _selectedSchedule = null);
                }
              },
              timeSlotViewSettings: const TimeSlotViewSettings(
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
      );
    }
  }

  void _showScheduleBottomSheet(
    BuildContext context,
    ClassScheduleModel schedule,
  ) {
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
              MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Chi tiết lịch học',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _openEditDialog(context, schedule);
                      },
                      icon: Icon(Icons.edit, color: Colors.orange.shade600),
                      tooltip: 'Sửa lịch',
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _confirmDelete(context, schedule);
                      },
                      icon: Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Xóa lịch',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDetailRow('Lớp', schedule.className, Icons.class_),
                _buildDetailRow(
                  'Phòng',
                  schedule.roomName ?? 'Chưa có',
                  Icons.meeting_room,
                ),
                _buildDetailRow(
                  'Giảng viên',
                  schedule.teacherName ?? 'Chưa có',
                  Icons.person,
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
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Đóng', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
    );
  }

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

  void _openEditDialog(BuildContext context, ClassScheduleModel schedule) {
    // Get viewModel for data
    final viewModel = context.read<ManageScheduleViewModel>();

    showDialog(
      context: context,
      builder:
          (dialogContext) => ChangeNotifierProvider.value(
            value: viewModel,
            child: ScheduleFormDialog(
              schedule: schedule,
              classes: viewModel.classes,
              rooms: viewModel.activeRooms,
            ),
          ),
    ).then((_) {
      // Reload data after edit
      viewModel.loadData();
    });
  }

  void _confirmDelete(BuildContext context, ClassScheduleModel schedule) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Xác nhận xóa'),
            content: Text(
              'Bạn có chắc chắn muốn xóa lịch học của lớp "${schedule.className}" không?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  final viewModel = context.read<ManageScheduleViewModel>();
                  await viewModel.deleteSchedule(schedule.id);
                  if (mounted) {
                    setState(() => _selectedSchedule = null);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Xóa', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );
  }
}
