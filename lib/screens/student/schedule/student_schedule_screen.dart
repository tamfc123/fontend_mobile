import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/data/datasources/student_schedule_data_source.dart';
import 'package:mobile/data/models/student_schedule_model.dart';
import 'package:mobile/screens/student/schedule/student_schedule_view_model.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class StudentScheduleScreen extends StatefulWidget {
  const StudentScheduleScreen({super.key});

  @override
  State<StudentScheduleScreen> createState() => _StudentScheduleScreenState();
}

class _StudentScheduleScreenState extends State<StudentScheduleScreen> {
  final CalendarController _calendarController = CalendarController();

  static const Color primaryBlue = Color(0xFF3B82F6);
  static const Color darkBlue = Color(0xFF1E3A8A);
  static const Color lightBlueBg = Color(0xFFEFF6FF);

  // Màu nền cho khối lịch Ngày/Tuần (Xanh nhạt theo yêu cầu)
  static final Color blockBgColor = primaryBlue.withValues(alpha: 0.1);

  CalendarView _currentView = CalendarView.schedule;

  final Map<CalendarView, String> _viewNames = {
    CalendarView.schedule: 'Lịch trình',
    CalendarView.day: 'Ngày',
    CalendarView.week: 'Tuần',
    CalendarView.month: 'Tháng',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentScheduleViewModel>().loadSchedules(dayOfWeek: 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<StudentScheduleViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Thời khóa biểu',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: lightBlueBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: primaryBlue.withValues(alpha: 0.1)),
            ),
            child: IconButton(
              icon: const Icon(Icons.today_rounded, color: primaryBlue),
              tooltip: 'Hôm nay',
              onPressed: () {
                _calendarController.displayDate = DateTime.now();
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Center(
              // 1. Dùng Center để căn giữa SingleChildScrollView
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  // 2. Dùng Row với mainAxisSize.min để co lại vừa nội dung
                  mainAxisSize: MainAxisSize.min,
                  children:
                      _viewNames.entries.map((entry) {
                        final isSelected = _currentView == entry.key;
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                          ), // Padding đều 2 bên cho cân đối
                          child: ChoiceChip(
                            label: Text(entry.value),
                            selected: isSelected,
                            onSelected: (bool selected) {
                              if (selected) {
                                setState(() {
                                  _currentView = entry.key;
                                  _calendarController.view = entry.key;
                                });
                              }
                            },
                            selectedColor: lightBlueBg,
                            backgroundColor: Colors.white,
                            labelStyle: TextStyle(
                              color:
                                  isSelected
                                      ? primaryBlue
                                      : Colors.grey.shade600,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color:
                                    isSelected
                                        ? primaryBlue.withValues(alpha: 0.3)
                                        : Colors.grey.shade200,
                              ),
                            ),
                            showCheckmark: false,
                          ),
                        );
                      }).toList(),
                ),
              ),
            ),
          ),
          // 2. CALENDAR
          Expanded(
            child:
                service.isLoading
                    ? const Center(
                      child: CircularProgressIndicator(color: primaryBlue),
                    )
                    : service.schedules.isEmpty
                    ? _buildEmptyState()
                    : SfCalendar(
                      controller: _calendarController,
                      view: _currentView,
                      headerHeight: 0,
                      dataSource: StudentScheduleDataSource(service.schedules),

                      // Cấu hình giao diện Lịch trình
                      scheduleViewSettings: const ScheduleViewSettings(
                        appointmentItemHeight: 90,
                        monthHeaderSettings: MonthHeaderSettings(
                          height: 70,
                          backgroundColor: Colors.white,
                          monthTextStyle: TextStyle(
                            color: darkBlue,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        hideEmptyScheduleWeek: true,
                        weekHeaderSettings: WeekHeaderSettings(
                          startDateFormat: 'dd MMM',
                          endDateFormat: 'dd MMM',
                          weekTextStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      // Cấu hình giao diện Tháng
                      monthViewSettings: const MonthViewSettings(
                        appointmentDisplayMode:
                            MonthAppointmentDisplayMode.indicator,
                        showAgenda: true,
                        agendaItemHeight: 70,
                        agendaStyle: AgendaStyle(
                          backgroundColor: lightBlueBg,
                          dateTextStyle: TextStyle(
                            color: darkBlue,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          dayTextStyle: TextStyle(
                            color: darkBlue,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // ✅ FIX LỖI TUYỆT ĐỐI:
                      // Dùng toán tử 3 ngôi để gán null cho Month View.
                      // Các view khác (Schedule, Day, Week) dùng hàm builder luôn trả về Widget.
                      appointmentBuilder:
                          _currentView == CalendarView.month
                              ? null
                              : (
                                BuildContext context,
                                CalendarAppointmentDetails details,
                              ) {
                                // Logic: Nếu là Schedule -> Card Schedule
                                // Nếu là Day/Week -> Card DayWeek
                                // Không bao giờ trả về null trong này
                                if (_currentView == CalendarView.schedule) {
                                  return _buildScheduleCard(context, details);
                                }
                                // Fallback cho Day/Week
                                return _buildDayWeekCard(context, details);
                              },

                      timeSlotViewSettings: const TimeSlotViewSettings(
                        startHour: 7,
                        endHour: 22,
                        timeFormat: 'HH:mm',
                        timeTextStyle: TextStyle(color: Colors.grey),
                      ),

                      todayHighlightColor: primaryBlue,

                      selectionDecoration: BoxDecoration(
                        color: primaryBlue.withValues(alpha: 0.15),
                        border: Border.all(color: primaryBlue, width: 2),
                        borderRadius: BorderRadius.circular(4),
                      ),

                      onTap: (details) {
                        if (details.appointments != null &&
                            details.appointments!.isNotEmpty) {
                          final dynamic firstAppt = details.appointments!.first;
                          if (firstAppt is Appointment) {
                            final StudentScheduleModel? model =
                                firstAppt.id as StudentScheduleModel?;
                            if (model != null) {
                              _showScheduleDetail(context, model);
                            }
                          }
                        }
                      },
                    ),
          ),
        ],
      ),
    );
  }

  // Widget Lịch trình (Schedule View)
  Widget _buildScheduleCard(
    BuildContext context,
    CalendarAppointmentDetails details,
  ) {
    final Appointment appointment = details.appointments.first;
    final StudentScheduleModel? model = appointment.id as StudentScheduleModel?;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (model != null) _showScheduleDetail(context, model);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 50,
                  decoration: BoxDecoration(
                    color: primaryBlue,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('HH:mm').format(appointment.startTime),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: darkBlue,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: lightBlueBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        DateFormat('HH:mm').format(appointment.endTime),
                        style: const TextStyle(
                          fontSize: 11,
                          color: primaryBlue,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Container(width: 1, height: 36, color: Colors.grey.shade200),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        model?.className ?? appointment.subject,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF334155),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            size: 13,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              model?.room ?? 'Chưa xếp phòng',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ WIDGET CHO NGÀY/TUẦN (Đã fix overflow và màu xanh nhạt)
  Widget _buildDayWeekCard(
    BuildContext context,
    CalendarAppointmentDetails details,
  ) {
    final Appointment appointment = details.appointments.first;
    final StudentScheduleModel? model = appointment.id as StudentScheduleModel?;

    return Container(
      decoration: BoxDecoration(
        color: blockBgColor, // Xanh nhạt
        borderRadius: BorderRadius.circular(4),
        border: const Border(
          left: BorderSide(color: primaryBlue, width: 4), // Viền trái đậm
        ),
      ),
      padding: const EdgeInsets.fromLTRB(6, 2, 2, 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              model?.className ?? appointment.subject,
              style: const TextStyle(
                color: darkBlue,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (model?.room != null)
            Flexible(
              child: Text(
                model!.room!,
                style: TextStyle(
                  color: primaryBlue.withValues(alpha: 0.8),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  void _showScheduleDetail(
    BuildContext context,
    StudentScheduleModel schedule,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(context).padding.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: lightBlueBg,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.class_rounded,
                          color: primaryBlue,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              schedule.className,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: darkBlue,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              schedule.courseName,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildDetailRow(
                    Icons.access_time_filled_rounded,
                    'Thời gian',
                    '${schedule.startTime} - ${schedule.endTime}',
                    primaryBlue,
                  ),
                  _buildDetailRow(
                    Icons.calendar_today_rounded,
                    'Thứ',
                    'Thứ ${schedule.dayOfWeek == 8 ? "Chủ nhật" : schedule.dayOfWeek}',
                    Colors.orange,
                  ),
                  _buildDetailRow(
                    Icons.location_on_rounded,
                    'Phòng học',
                    schedule.room ?? 'Chưa cập nhật',
                    Colors.redAccent,
                  ),
                  _buildDetailRow(
                    Icons.person_rounded,
                    'Giảng viên',
                    schedule.teacherName ?? 'Chưa cập nhật',
                    Colors.teal,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        shadowColor: primaryBlue.withValues(alpha: 0.4),
                      ),
                      child: const Text(
                        'Đóng',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    Color iconColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: lightBlueBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              size: 60,
              color: primaryBlue,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Chưa có lịch học',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: darkBlue,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Các lớp học bạn tham gia sẽ hiển thị tại đây',
            style: TextStyle(color: Colors.grey, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
