import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/data/models/class_model.dart';
import 'package:mobile/data/models/class_schedule_model.dart';
import 'package:mobile/data/models/room_model.dart';
import 'package:mobile/screens/admin/manage_schedule/manage_schedule_view_model.dart';
import 'package:mobile/utils/toast_helper.dart';
import 'package:provider/provider.dart';

class ScheduleFormDialog extends StatefulWidget {
  final ClassScheduleModel?
  schedule; // Nếu null -> Lỗi (vì ta chỉ dùng Dialog để Sửa)
  final List<ClassModel> classes;
  final List<RoomModel> rooms;

  const ScheduleFormDialog({
    super.key,
    this.schedule,
    required this.classes,
    required this.rooms,
  });

  @override
  State<ScheduleFormDialog> createState() => _ScheduleFormDialogState();
}

class _ScheduleFormDialogState extends State<ScheduleFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;

  String? _selectedClassId;
  int? _selectedDay;
  String? _selectedRoomId;
  bool _isLoading = false;

  static const Color primaryBlue = Color(0xFF1565C0);
  static const Color lightBlue = Color(0xFF42A5F5);
  static const Color backgroundBlue = Color(0xFFF3F8FF);
  static const Color surfaceBlue = Color(0xFFE3F2FD);

  @override
  void initState() {
    super.initState();

    final s = widget.schedule;

    _startTimeController = TextEditingController(text: s?.startTime ?? '');
    _endTimeController = TextEditingController(text: s?.endTime ?? '');

    _selectedDay = s != null ? _convertDayStringToInt(s.dayOfWeek) : null;
    _selectedClassId = s?.classId;
    _selectedRoomId = s?.roomId;

    _startDateController = TextEditingController(
      text:
          s?.startDate != null
              ? DateFormat('yyyy-MM-dd').format(s!.startDate)
              : '',
    );
    _endDateController = TextEditingController(
      text:
          s?.endDate != null ? DateFormat('yyyy-MM-dd').format(s!.endDate) : '',
    );
  }

  @override
  void dispose() {
    _startTimeController.dispose();
    _endTimeController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final formattedTime =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      controller.text = formattedTime;
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedClassId == null ||
        _selectedDay == null ||
        _selectedRoomId == null) {
      ToastHelper.showError('Vui lòng chọn đủ lớp, thứ và phòng học');
      return;
    }
    setState(() => _isLoading = true);

    try {
      final selectedClass = widget.classes.firstWhere(
        (c) => c.id == _selectedClassId,
      );

      // Tạo model cập nhật
      final updatedSchedule = widget.schedule!.copyWith(
        classId: _selectedClassId,
        className: selectedClass.name,
        dayOfWeek: _convertDayIntToString(_selectedDay!),
        startTime: _startTimeController.text,
        endTime: _endTimeController.text,
        roomId: _selectedRoomId,
        // Giữ nguyên các thông tin khác hoặc lấy từ Class mới
        teacherId: selectedClass.teacherId,
        teacherName: selectedClass.teacherName,
        startDate: DateTime.parse(_startDateController.text).toUtc(),
        endDate: DateTime.parse(_endDateController.text).toUtc(),
      );

      final success = await context
          .read<ManageScheduleViewModel>()
          .updateSchedule(widget.schedule!.id, updatedSchedule);

      if (success && mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      ToastHelper.showError('Lỗi: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          color: backgroundBlue,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: primaryBlue.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Gradient Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryBlue, lightBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(Icons.schedule, color: Colors.white, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      'Chỉnh sửa lịch học',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Form Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Class Dropdown
                      _buildModernDropdown<String>(
                        label: 'Lớp học',
                        icon: Icons.class_outlined,
                        value: _selectedClassId,
                        items:
                            widget.classes
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c.id,
                                    child: Text(c.name),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            (val) => setState(() => _selectedClassId = val),
                      ),
                      const SizedBox(height: 20),

                      // Day Dropdown
                      _buildModernDropdown<int>(
                        label: 'Thứ trong tuần',
                        icon: Icons.calendar_today,
                        value: _selectedDay,
                        items:
                            List.generate(
                              7,
                              (i) => DropdownMenuItem(
                                value: i + 2,
                                child: Text(_convertDayIntToString(i + 2)),
                              ),
                            ).toList(),
                        onChanged: (val) => setState(() => _selectedDay = val),
                      ),
                      const SizedBox(height: 20),

                      // Room Dropdown
                      _buildModernDropdown<String>(
                        label: 'Phòng học',
                        icon: Icons.meeting_room_outlined,
                        value: _selectedRoomId,
                        items:
                            widget.rooms
                                .map(
                                  (r) => DropdownMenuItem(
                                    value: r.id,
                                    child: Text(r.name),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            (val) => setState(() => _selectedRoomId = val),
                        validator:
                            (val) => val == null ? 'Vui lòng chọn phòng' : null,
                      ),
                      const SizedBox(height: 20),

                      // Time Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildTimeField(
                              _startTimeController,
                              'Giờ bắt đầu',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTimeField(
                              _endTimeController,
                              'Giờ kết thúc',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Action Buttons
              Container(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: primaryBlue.withValues(alpha: 0.5),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Hủy',
                          style: TextStyle(
                            color: primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: _isLoading ? null : _handleSubmit,
                        child:
                            _isLoading
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.save, size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Lưu',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
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
    );
  }

  Widget _buildModernDropdown<T>({
    required String label,
    required IconData icon,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
    String? Function(T?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: primaryBlue,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: surfaceBlue),
            boxShadow: [
              BoxShadow(
                color: primaryBlue.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<T>(
            value: value,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: lightBlue),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            items: items,
            onChanged: onChanged,
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField(TextEditingController controller, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: primaryBlue,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: surfaceBlue),
            boxShadow: [
              BoxShadow(
                color: primaryBlue.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            readOnly: true,
            onTap: () => _selectTime(controller),
            decoration: InputDecoration(
              hintText: 'HH:MM',
              hintStyle: TextStyle(color: Colors.grey[400]),
              suffixIcon: Icon(Icons.access_time, color: lightBlue),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            validator: (val) => val!.isEmpty ? 'Nhập giờ' : null,
          ),
        ),
      ],
    );
  }

  String _convertDayIntToString(int day) {
    switch (day) {
      case 2:
        return "Thứ 2";
      case 3:
        return "Thứ 3";
      case 4:
        return "Thứ 4";
      case 5:
        return "Thứ 5";
      case 6:
        return "Thứ 6";
      case 7:
        return "Thứ 7";
      case 8:
        return "Chủ nhật";
      default:
        return "Không xác định";
    }
  }

  int _convertDayStringToInt(String day) {
    switch (day) {
      case "Thứ 2":
        return 2;
      case "Thứ 3":
        return 3;
      case "Thứ 4":
        return 4;
      case "Thứ 5":
        return 5;
      case "Thứ 6":
        return 6;
      case "Thứ 7":
        return 7;
      case "Chủ nhật":
        return 8;
      default:
        return 0;
    }
  }
}
