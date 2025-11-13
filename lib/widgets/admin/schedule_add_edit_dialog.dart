import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/data/models/class_schedule_model.dart';
import 'package:mobile/services/admin/class_service.dart';
import 'package:mobile/services/admin/room_service.dart';
import 'package:mobile/services/admin/schedule_service.dart';
import 'package:mobile/utils/toast_helper.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

class ScheduleFormDialog extends StatefulWidget {
  final ClassScheduleModel? schedule;
  const ScheduleFormDialog({super.key, this.schedule});

  @override
  State<ScheduleFormDialog> createState() => _ScheduleFormDialogState();
}

class _ScheduleFormDialogState extends State<ScheduleFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;
  late TextEditingController _roomController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;

  int? _selectedClassId;
  int? _selectedDay;
  int? selectedRoomId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    final s = widget.schedule;
    _startTimeController = TextEditingController(text: s?.startTime ?? '');
    _endTimeController = TextEditingController(text: s?.endTime ?? '');
    _roomController = TextEditingController(text: s?.room ?? '');
    _selectedDay = s != null ? _convertDayStringToInt(s.dayOfWeek) : null;
    _selectedClassId = s?.classId;
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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<ClassService>().fetchClasses();
      final roomService = context.read<RoomService>();
      await roomService.fetchRooms();

      if (widget.schedule != null && widget.schedule!.room != null) {
        final room = roomService.rooms.firstWhereOrNull(
          (r) => r.name == widget.schedule!.room,
        );

        if (room != null) {
          setState(() {
            selectedRoomId = room.id;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _startTimeController.dispose();
    _endTimeController.dispose();
    _roomController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();

    super.dispose();
  }

  Future<void> _selectTime(TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final formattedTime =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      controller.text = formattedTime;
    }
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      controller.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedClassId == null ||
        _selectedDay == null ||
        selectedRoomId == null) {
      ToastHelper.showError('Vui lòng chọn đủ lớp, thứ và phòng học');
      return;
    }
    setState(() => _isLoading = true);

    try {
      // Lấy lớp đã chọn
      final classes = context.read<ClassService>().classes;
      final selectedClass = classes.firstWhere((c) => c.id == _selectedClassId);

      // Lấy phòng đã chọn
      final rooms = context.read<RoomService>().rooms;
      final selectedRoom = rooms.firstWhere((r) => r.id == selectedRoomId);

      // Tạo object schedule
      final schedule = ClassScheduleModel(
        id: widget.schedule?.id ?? 0,
        classId: _selectedClassId!,
        className: selectedClass.name,
        dayOfWeek: _convertDayIntToString(_selectedDay!),
        startTime: _startTimeController.text,
        endTime: _endTimeController.text,
        room: selectedRoom.name, // dùng tên phòng từ dropdown
        teacherId: selectedClass.teacherId ?? "",
        teacherName: selectedClass.teacherName ?? "",
        startDate: DateTime.parse(_startDateController.text).toUtc(),
        endDate: DateTime.parse(_endDateController.text).toUtc(),
      );

      // Gọi service tạo hoặc cập nhật
      final service = context.read<ScheduleService>();
      if (widget.schedule == null) {
        await service.createSchedule(schedule);
      } else {
        await service.updateSchedule(widget.schedule!.id, schedule);
      }

      Navigator.of(context).pop(); // đóng dialog khi thành công
    } catch (e) {
      ToastHelper.showError('Lỗi: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final classes = context.watch<ClassService>().classes;
    final isEditing = widget.schedule != null;
    final rooms = context.watch<RoomService>().rooms;
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.blue.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isEditing
                          ? Icons.edit_calendar
                          : Icons.add_circle_outline,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEditing
                              ? 'Chỉnh sửa lịch học'
                              : 'Thêm lịch học mới',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isEditing
                              ? 'Cập nhật thông tin lịch học'
                              : 'Tạo lịch học cho lớp',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Form Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Class Selection
                      _buildSectionTitle('Thông tin lớp học'),
                      const SizedBox(height: 8),
                      _buildDropdown<int>(
                        label: "Chọn lớp học",
                        value: _selectedClassId,
                        icon: Icons.class_,
                        items:
                            classes
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

                      // Schedule Information
                      _buildSectionTitle('Thời gian học'),
                      const SizedBox(height: 8),
                      _buildDropdown<int>(
                        label: "Chọn thứ trong tuần",
                        value: _selectedDay,
                        icon: Icons.calendar_today,
                        items: List.generate(7, (i) {
                          final day = i + 2;
                          return DropdownMenuItem(
                            value: day,
                            child: Text(_convertDayIntToString(day)),
                          );
                        }),
                        onChanged: (val) => setState(() => _selectedDay = val),
                      ),
                      const SizedBox(height: 20),
                      _buildSectionTitle('Khoảng thời gian áp dụng'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDateField(
                              _startDateController,
                              'Ngày bắt đầu',
                              Icons.calendar_month,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDateField(
                              _endDateController,
                              'Ngày kết thúc',
                              Icons.event,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildSectionTitle('Thời gian học'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTimeField(
                              _startTimeController,
                              'Giờ bắt đầu',
                              Icons.access_time,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTimeField(
                              _endTimeController,
                              'Giờ kết thúc',
                              Icons.access_time_filled,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Room Information
                      _buildSectionTitle('Địa điểm'),
                      const SizedBox(height: 8),
                      _buildDropdown<int?>(
                        label: "Chọn phòng học",
                        value: selectedRoomId,
                        icon: Icons.room,
                        items:
                            rooms.isNotEmpty
                                ? rooms
                                    .map(
                                      (r) => DropdownMenuItem<int?>(
                                        value: r.id,
                                        child: Text(r.name),
                                      ),
                                    )
                                    .toList()
                                : [
                                  const DropdownMenuItem<int?>(
                                    value: null,
                                    child: Text('Đang tải phòng...'),
                                  ),
                                ],
                        onChanged: (val) {
                          if (rooms.isNotEmpty)
                            setState(() => selectedRoomId = val);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Action Buttons
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: Color(0xFF9E9E9E)),
                      ),
                      child: const Text(
                        'Hủy',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF424242),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child:
                          _isLoading
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : Text(
                                isEditing ? 'Cập nhật' : 'Thêm mới',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
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

  Widget _buildDateField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: () => _selectDate(controller),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue),
        suffixIcon: const Icon(
          Icons.keyboard_arrow_down,
          color: Color(0xFF616161),
        ),
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        labelStyle: const TextStyle(color: Color(0xFF616161)),
      ),
      validator: (val) {
        if (val == null || val.trim().isEmpty) {
          return 'Vui lòng chọn $label';
        }
        return null;
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 73, 169, 224),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 73, 169, 224),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
    bool required,
  ) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue),
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
        ),
        labelStyle: const TextStyle(color: Color(0xFF616161)),
      ),
      validator: (val) {
        if (required && (val == null || val.trim().isEmpty)) {
          return 'Không được để trống';
        }
        return null;
      },
    );
  }

  Widget _buildTimeField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: () => _selectTime(controller),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue),
        suffixIcon: const Icon(
          Icons.keyboard_arrow_down,
          color: Color(0xFF616161),
        ),
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        labelStyle: const TextStyle(color: Color(0xFF616161)),
      ),
      validator: (val) {
        if (val == null || val.trim().isEmpty) {
          return 'Vui lòng chọn $label';
        }
        return null;
      },
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      isExpanded: true,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue),
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        labelStyle: const TextStyle(color: Color(0xFF616161)),
      ),
      validator: (val) => val == null ? 'Vui lòng chọn $label' : null,
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
