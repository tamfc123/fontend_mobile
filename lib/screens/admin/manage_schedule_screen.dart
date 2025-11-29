import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/data/datasources/schedule_data_source.dart';
import 'package:mobile/data/models/class_schedule_model.dart';
import 'package:mobile/services/admin/admin_room_service.dart';
import 'package:mobile/services/admin/admin_schedule_service.dart';
import 'package:mobile/shared_widgets/admin/comfirm_delete_dialog.dart';
import 'package:mobile/widgets/admin/schedule_form_dialog.dart';
import 'package:mobile/widgets/admin/schedule_filter_bar.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart';

class ManageScheduleScreen extends StatefulWidget {
  const ManageScheduleScreen({super.key});

  @override
  State<ManageScheduleScreen> createState() => _ManageScheduleScreenState();
}

class _ManageScheduleScreenState extends State<ManageScheduleScreen> {
  final CalendarController _calendarController = CalendarController();
  ClassScheduleModel? _selectedSchedule;

  static const Color primaryBlue = Colors.blue;
  static const Color backgroundBlue = Color(0xFFF3F8FF);
  static const Color surfaceBlue = Color(0xFFE3F2FD);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    context.read<AdminScheduleService>().fetchSchedules();
    context.read<AdminRoomService>().fetchAllActiveRooms();
  }

  Future<void> _navigateToAddScreen() async {
    await context.push('/admin/schedules/bulk-create');
    _loadData();
  }

  void _openEditDialog(ClassScheduleModel schedule) {
    showDialog(
      context: context,
      builder: (_) => ScheduleFormDialog(schedule: schedule),
    );
  }

  void _confirmDelete(ClassScheduleModel schedule) {
    showDialog(
      context: context,
      builder:
          (_) => ConfirmDeleteDialog(
            title: 'Xác nhận xóa',
            content:
                'Bạn có chắc muốn xóa thời khóa biểu lớp "${schedule.className}"?',
            itemName: schedule.className,
            onConfirm: () async {
              await context.read<AdminScheduleService>().deleteSchedule(
                schedule.id,
              );
              setState(() {
                _selectedSchedule = null;
              });
            },
          ),
    );
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
  Widget build(BuildContext buildContext) {
    final scheduleService = context.watch<AdminScheduleService>();
    final schedules = scheduleService.schedules;
    final roomService = context.watch<AdminRoomService>();
    final rooms = roomService.allActiveRooms;
    final isLoading =
        scheduleService.isLoading || (roomService.isLoading && rooms.isEmpty);

    final dataSource = ScheduleDataSource(schedules, rooms);

    return Scaffold(
      backgroundColor: backgroundBlue,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1600),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === HEADER ===
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: surfaceBlue,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.calendar_month,
                                color: primaryBlue,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Quản lý Lịch học',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E3A8A),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Lịch học của tất cả lớp trong hệ thống',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            ElevatedButton.icon(
                              onPressed: _navigateToAddScreen,
                              icon: const Icon(Icons.add, size: 20),
                              label: const Text(
                                'Thêm Lịch học',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryBlue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 22,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(24, 0, 24, 20),
                        child: ScheduleFilterBar(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // === CALENDAR ===
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
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
                                icon: const Icon(
                                  Icons.arrow_back_ios_new,
                                  size: 16,
                                ),
                                label: const Text('Tuần trước'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: primaryBlue,
                                ),
                              ),
                              const SizedBox(width: 12),
                              OutlinedButton.icon(
                                onPressed: _goToNextWeek,
                                icon: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                ),
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
                                  ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                  : Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: SfCalendar(
                                          controller: _calendarController,
                                          view: CalendarView.timelineWeek,
                                          firstDayOfWeek: 1,
                                          dataSource: dataSource,
                                          // ✅ FIX: Sửa logic onTap để lấy đúng Model từ Appointment
                                          onTap: (details) {
                                            if (details
                                                    .appointments
                                                    ?.isNotEmpty ??
                                                false) {
                                              // Lấy Appointment wrapper ra trước
                                              final Appointment appointment =
                                                  details.appointments!.first;
                                              // Sau đó lấy model gốc từ thuộc tính id của Appointment
                                              if (appointment.id
                                                  is ClassScheduleModel) {
                                                setState(
                                                  () =>
                                                      _selectedSchedule =
                                                          appointment.id
                                                              as ClassScheduleModel,
                                                );
                                              }
                                            } else {
                                              setState(
                                                () => _selectedSchedule = null,
                                              );
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
                                      Container(
                                        width: 1,
                                        color: Colors.grey.shade300,
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child:
                                            _selectedSchedule == null
                                                ? const Center(
                                                  child: Text(
                                                    'Chọn lịch để xem chi tiết',
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                )
                                                : _buildDetailPanel(),
                                      ),
                                    ],
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailPanel() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lớp: ${_selectedSchedule!.className}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 20),
          _buildDetailRow(
            Icons.room,
            'Phòng:',
            _selectedSchedule!.roomName ?? 'Chưa có',
          ),
          _buildDetailRow(
            Icons.person,
            'Giảng viên:',
            _selectedSchedule!.teacherName ?? 'Chưa có',
          ),
          _buildDetailRow(
            Icons.access_time,
            'Thời gian:',
            '${_selectedSchedule!.startTime} - ${_selectedSchedule!.endTime}',
          ),
          _buildDetailRow(
            Icons.date_range,
            'Ngày:',
            DateFormat('dd/MM/yyyy').format(_selectedSchedule!.startDate),
          ),

          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildActionButton(
                Icons.edit,
                Colors.orange.shade600,
                'Sửa',
                () => _openEditDialog(_selectedSchedule!),
              ),
              const SizedBox(width: 12),
              _buildActionButton(
                Icons.delete,
                Colors.redAccent,
                'Xóa',
                () => _confirmDelete(_selectedSchedule!),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: primaryBlue),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 6),
          Expanded(child: Text(value, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    Color color,
    String label,
    VoidCallback onPressed,
  ) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: color),
      label: Text(label, style: TextStyle(color: color)),
      style: OutlinedButton.styleFrom(side: BorderSide(color: color)),
    );
  }
}
