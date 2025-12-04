import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/data/models/class_model.dart';
import 'package:mobile/data/models/class_schedule_model.dart';
import 'package:mobile/data/models/room_model.dart';
import 'package:mobile/domain/repositories/admin/admin_class_repository.dart';
import 'package:mobile/domain/repositories/admin/admin_room_repository.dart';
import 'package:mobile/screens/admin/manage_schedule/manage_schedule_view_model.dart';
import 'package:mobile/utils/toast_helper.dart';
import 'package:provider/provider.dart';

class ScheduleFormDialog extends StatefulWidget {
  final ClassScheduleModel?
  schedule; // Nếu null -> Lỗi (vì ta chỉ dùng Dialog để Sửa)
  const ScheduleFormDialog({super.key, this.schedule});

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

  List<ClassModel> _classes = [];
  List<RoomModel> _rooms = [];

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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadData();
    });
  }

  Future<void> _loadData() async {
    try {
      final classRepo = context.read<AdminClassRepository>();
      final roomRepo = context.read<AdminRoomRepository>();

      final results = await Future.wait([
        classRepo.getAllActiveClasses(),
        roomRepo.getAllActiveRooms(),
      ]);

      if (mounted) {
        setState(() {
          _classes = results[0] as List<ClassModel>;
          _rooms = results[1] as List<RoomModel>;
        });
      }
    } catch (e) {
      ToastHelper.showError('Lỗi tải dữ liệu: $e');
    }
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
      final selectedClass = _classes.firstWhere(
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
    // Chỉ hiển thị Edit mode
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue.shade600,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.edit, color: Colors.white),
                  SizedBox(width: 16),
                  Text(
                    'Chỉnh sửa lịch học',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Form
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Chọn Lớp
                      DropdownButtonFormField<String>(
                        value: _selectedClassId,
                        decoration: const InputDecoration(
                          labelText: "Lớp học",
                          border: OutlineInputBorder(),
                          filled: true,
                        ),
                        items:
                            _classes
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
                      const SizedBox(height: 16),

                      // Chọn Thứ
                      DropdownButtonFormField<int>(
                        value: _selectedDay,
                        decoration: const InputDecoration(
                          labelText: "Thứ",
                          border: OutlineInputBorder(),
                          filled: true,
                        ),
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
                      const SizedBox(height: 16),

                      // Chọn Phòng
                      DropdownButtonFormField<String>(
                        value: _selectedRoomId,
                        decoration: const InputDecoration(
                          labelText: "Phòng học",
                          border: OutlineInputBorder(),
                          filled: true,
                        ),
                        items:
                            _rooms
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
                      const SizedBox(height: 16),

                      // Giờ
                      Row(
                        children: [
                          Expanded(
                            child: _buildTimeField(
                              _startTimeController,
                              'Bắt đầu',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTimeField(
                              _endTimeController,
                              'Kết thúc',
                            ),
                          ),
                        ],
                      ),

                      // Nút Save/Cancel
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              child: const Text('Hủy'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              child:
                                  _isLoading
                                      ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                      : const Text('Lưu thay đổi'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: () => _selectTime(controller),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.access_time),
      ),
      validator: (val) => val!.isEmpty ? 'Nhập giờ' : null,
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
