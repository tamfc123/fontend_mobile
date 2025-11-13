import 'package:flutter/material.dart';
import 'package:mobile/data/datasources/schedule_data_source.dart';
import 'package:mobile/data/models/class_schedule_model.dart';
import 'package:mobile/services/admin/schedule_service.dart';
import 'package:mobile/widgets/admin/comfirm_delete_dialog.dart';
import 'package:mobile/widgets/admin/schedule_add_edit_dialog.dart';
import 'package:mobile/widgets/admin/schedule_filter_bar.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class ManageScheduleScreen extends StatefulWidget {
  const ManageScheduleScreen({super.key});

  @override
  State<ManageScheduleScreen> createState() => _ManageScheduleScreenState();
}

class _ManageScheduleScreenState extends State<ManageScheduleScreen> {
  final CalendarController _calendarController = CalendarController();
  ClassScheduleModel? _selectedSchedule;

  // MÀU CHỦ ĐẠO (ĐỒNG NHẤT)
  static const Color primaryBlue = Colors.blue;
  static const Color backgroundBlue = Color(0xFFF3F8FF);
  static const Color surfaceBlue = Color(0xFFE3F2FD);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScheduleService>().fetchSchedules();
    });
  }

  void _openFormDialog({ClassScheduleModel? schedule}) {
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
              await context.read<ScheduleService>().deleteSchedule(schedule.id);
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
  Widget build(BuildContext context) {
    final scheduleService = context.watch<ScheduleService>();
    final schedules = scheduleService.schedules;
    final isLoading = scheduleService.isLoading;

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
                // === HEADER + FILTER + NÚT THÊM (KHÔNG CÓ BACK) ===
                Container(
                  width: double.infinity,
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
                      // HEADER ROW
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                        child: Row(
                          children: [
                            // ICON + TIÊU ĐỀ
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

                            // NÚT THÊM
                            ElevatedButton.icon(
                              onPressed: () => _openFormDialog(),
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
                                elevation: 0,
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

                      // FILTER BAR + STATS
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                        child: Column(
                          children: [
                            const ScheduleFilterBar(),
                            const SizedBox(height: 16),
                            if (schedules.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: primaryBlue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.calendar_today_rounded,
                                      color: primaryBlue,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Tổng số lịch học: ${schedules.length}',
                                      style: TextStyle(
                                        color: primaryBlue,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // === NÚT TUẦN + CALENDAR + DETAIL PANEL ===
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
                        // NÚT TUẦN
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
                                label: const Text(
                                  'Tuần trước',
                                  style: TextStyle(fontSize: 14),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: primaryBlue,
                                  side: BorderSide(
                                    color: primaryBlue,
                                    width: 1.5,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              OutlinedButton.icon(
                                onPressed: _goToNextWeek,
                                icon: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                ),
                                label: const Text(
                                  'Tuần sau',
                                  style: TextStyle(fontSize: 14),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: primaryBlue,
                                  side: BorderSide(
                                    color: primaryBlue,
                                    width: 1.5,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // CALENDAR + DETAIL
                        Expanded(
                          child:
                              isLoading
                                  ? const Center(
                                    child: CircularProgressIndicator(
                                      color: primaryBlue,
                                    ),
                                  )
                                  : schedules.isEmpty
                                  ? _buildEmptyState()
                                  : Row(
                                    children: [
                                      // CALENDAR
                                      Expanded(
                                        flex: 2,
                                        child: ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                            bottomLeft: Radius.circular(16),
                                            topLeft: Radius.circular(0),
                                          ),
                                          child: SfCalendar(
                                            controller: _calendarController,
                                            view: CalendarView.week,
                                            firstDayOfWeek: 1,
                                            dataSource: ScheduleDataSource(
                                              schedules,
                                            ),
                                            onTap: (details) {
                                              if (details
                                                      .appointments
                                                      ?.isNotEmpty ??
                                                  false) {
                                                final appointment =
                                                    details.appointments!.first
                                                        as Appointment;
                                                final schedule =
                                                    appointment.id
                                                        as ClassScheduleModel;
                                                setState(
                                                  () =>
                                                      _selectedSchedule =
                                                          schedule,
                                                );
                                              }
                                            },
                                            timeSlotViewSettings:
                                                const TimeSlotViewSettings(
                                                  startHour: 7,
                                                  endHour: 24,
                                                  timeInterval: Duration(
                                                    minutes: 60,
                                                  ),
                                                  timeFormat: 'HH:mm',
                                                  timeTextStyle: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                            headerStyle: CalendarHeaderStyle(
                                              backgroundColor: surfaceBlue,
                                              textStyle: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF1E3A8A),
                                              ),
                                            ),
                                            todayHighlightColor: primaryBlue,
                                            selectionDecoration: BoxDecoration(
                                              color: primaryBlue.withOpacity(
                                                0.2,
                                              ),
                                              border: Border.all(
                                                color: primaryBlue,
                                                width: 2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            appointmentTextStyle:
                                                const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                            appointmentBuilder: (
                                              context,
                                              details,
                                            ) {
                                              final appointment =
                                                  details.appointments.first;
                                              return Container(
                                                decoration: BoxDecoration(
                                                  color: primaryBlue
                                                      .withOpacity(0.8),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                padding: const EdgeInsets.all(
                                                  6,
                                                ),
                                                child: Text(
                                                  appointment.subject,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),

                                      // DETAIL PANEL
                                      Container(
                                        width: 1,
                                        color: Colors.grey.shade300,
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child:
                                            _selectedSchedule == null
                                                ? Center(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons.touch_app,
                                                        size: 48,
                                                        color:
                                                            Colors
                                                                .grey
                                                                .shade400,
                                                      ),
                                                      const SizedBox(
                                                        height: 12,
                                                      ),
                                                      Text(
                                                        'Chọn một lịch học để xem chi tiết',
                                                        style: TextStyle(
                                                          color:
                                                              Colors
                                                                  .grey
                                                                  .shade600,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ],
                                                  ),
                                                )
                                                : Padding(
                                                  padding: const EdgeInsets.all(
                                                    20,
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Lớp: ${_selectedSchedule!.className}',
                                                        style: const TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Color(
                                                            0xFF1E3A8A,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 12,
                                                      ),
                                                      _buildDetailRow(
                                                        Icons.room,
                                                        'Phòng:',
                                                        _selectedSchedule!
                                                                .room ??
                                                            'Chưa có',
                                                      ),
                                                      _buildDetailRow(
                                                        Icons.person,
                                                        'Giảng viên:',
                                                        _selectedSchedule!
                                                                .teacherName ??
                                                            'Chưa có',
                                                      ),
                                                      _buildDetailRow(
                                                        Icons.access_time,
                                                        'Thời gian:',
                                                        '${_selectedSchedule!.startTime} - ${_selectedSchedule!.endTime}',
                                                      ),
                                                      _buildDetailRow(
                                                        Icons.date_range,
                                                        'Từ:',
                                                        _formatDate(
                                                          _selectedSchedule!
                                                              .startDate,
                                                        ),
                                                      ),
                                                      _buildDetailRow(
                                                        Icons.date_range,
                                                        'Đến:',
                                                        _formatDate(
                                                          _selectedSchedule!
                                                              .endDate,
                                                        ),
                                                      ),
                                                      const Spacer(),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          _buildActionButton(
                                                            Icons.edit,
                                                            Colors
                                                                .orange
                                                                .shade600,
                                                            'Sửa',
                                                            () => _openFormDialog(
                                                              schedule:
                                                                  _selectedSchedule,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 12,
                                                          ),
                                                          _buildActionButton(
                                                            Icons.delete,
                                                            Colors.redAccent,
                                                            'Xóa',
                                                            () => _confirmDelete(
                                                              _selectedSchedule!,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_month_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'Chưa có lịch học nào',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Nhấn "Thêm Lịch học" để bắt đầu',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: primaryBlue),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black87, fontSize: 14),
                children: [
                  TextSpan(
                    text: '$label ',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
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
      label: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
