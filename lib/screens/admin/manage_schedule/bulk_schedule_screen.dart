import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/domain/repositories/admin/admin_schedule_repository.dart';
import 'package:mobile/screens/admin/manage_schedule/bulk_schedule_view_model.dart';
import 'package:mobile/utils/toast_helper.dart';
import 'package:provider/provider.dart';

// Model nội bộ cho UI
class UISlot {
  int dayOfWeek;
  TimeOfDay startTime;
  TimeOfDay endTime;
  String? roomId;

  UISlot({
    this.dayOfWeek = 2,
    this.startTime = const TimeOfDay(hour: 7, minute: 0),
    this.endTime = const TimeOfDay(hour: 9, minute: 0),
    this.roomId,
  });
}

class BulkScheduleScreen extends StatefulWidget {
  const BulkScheduleScreen({super.key});

  @override
  State<BulkScheduleScreen> createState() => _BulkScheduleScreenState();
}

class _BulkScheduleScreenState extends State<BulkScheduleScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BulkScheduleViewModel>().loadInitialData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const _BulkScheduleContent();
  }
}

class _BulkScheduleContent extends StatefulWidget {
  const _BulkScheduleContent();

  @override
  State<_BulkScheduleContent> createState() => _BulkScheduleContentState();
}

class _BulkScheduleContentState extends State<_BulkScheduleContent> {
  static const Color primaryBlue = Colors.blue;
  static const Color backgroundBlue = Color(0xFFF3F8FF);
  static const Color surfaceBlue = Color(0xFFE3F2FD);

  String? _selectedClassId;
  String? _teacherIdOfClass;
  String? _teacherNameOfClass;
  DateTimeRange? _dateRange;

  final List<UISlot> _slots = [UISlot()];

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDateRange: _dateRange,
      initialEntryMode: DatePickerEntryMode.calendar,
      builder: (context, child) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 400.0,
              maxHeight: 600.0,
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: primaryBlue,
                  onPrimary: Colors.white,
                  onSurface: Colors.black,
                ),
                dialogTheme: const DialogTheme(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                ),
              ),
              child: child!,
            ),
          ),
        );
      },
    );
    if (picked != null) setState(() => _dateRange = picked);
  }

  Future<void> _handleSubmit(BulkScheduleViewModel viewModel) async {
    if (_selectedClassId == null || _dateRange == null) {
      ToastHelper.showError('Vui lòng chọn Lớp và Khoảng thời gian');
      return;
    }

    for (var slot in _slots) {
      if (slot.roomId == null) {
        ToastHelper.showError('Vui lòng chọn phòng học cho tất cả các lịch');
        return;
      }
      final startDouble = slot.startTime.hour + slot.startTime.minute / 60.0;
      final endDouble = slot.endTime.hour + slot.endTime.minute / 60.0;
      if (startDouble >= endDouble) {
        ToastHelper.showError(
          'Thứ ${slot.dayOfWeek}: Giờ kết thúc phải sau giờ bắt đầu',
        );
        return;
      }
    }

    final requestSlots =
        _slots
            .map(
              (s) => WeeklySlotRequest(
                dayOfWeek: s.dayOfWeek,
                startTime:
                    '${s.startTime.hour.toString().padLeft(2, '0')}:${s.startTime.minute.toString().padLeft(2, '0')}',
                endTime:
                    '${s.endTime.hour.toString().padLeft(2, '0')}:${s.endTime.minute.toString().padLeft(2, '0')}',
                roomId: s.roomId!,
              ),
            )
            .toList();

    final success = await viewModel.createBulkSchedule(
      classId: _selectedClassId!,
      teacherId: _teacherIdOfClass!,
      rangeStartDate: _dateRange!.start,
      rangeEndDate: _dateRange!.end,
      slots: requestSlots,
    );

    if (success && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<BulkScheduleViewModel>();
    final classes = viewModel.classes;
    final rooms = viewModel.rooms;

    return Scaffold(
      backgroundColor: backgroundBlue,
      appBar: AppBar(
        title: const Text('Tạo Lịch Học Hàng Loạt'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E3A8A),
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
          viewModel.isLoading && classes.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // HEADER
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: surfaceBlue,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.info_outline,
                                      color: primaryBlue,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  const Text(
                                    'Thông tin chung',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E3A8A),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // FORM INPUTS
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildDropdown<String>(
                                          label: 'Lớp Học',
                                          value: _selectedClassId,
                                          items:
                                              classes
                                                  .map(
                                                    (c) => DropdownMenuItem(
                                                      value: c.id,
                                                      child: Text(c.name),
                                                    ),
                                                  )
                                                  .toList(),
                                          onChanged: (val) {
                                            setState(() {
                                              _selectedClassId = val;
                                              final selectedClass = classes
                                                  .firstWhere(
                                                    (c) => c.id == val,
                                                  );
                                              _teacherIdOfClass =
                                                  selectedClass.teacherId;
                                              _teacherNameOfClass =
                                                  selectedClass.teacherName;
                                            });
                                          },
                                        ),
                                        if (_teacherNameOfClass != null) ...[
                                          const SizedBox(height: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  Icons.person,
                                                  size: 16,
                                                  color: Colors.grey,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'GV: $_teacherNameOfClass',
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.blueGrey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 24),
                                  Expanded(
                                    child: InkWell(
                                      onTap: _pickDateRange,
                                      child: InputDecorator(
                                        decoration: InputDecoration(
                                          labelText: 'Thời gian áp dụng',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          prefixIcon: const Icon(
                                            Icons.date_range_outlined,
                                            color: primaryBlue,
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                        ),
                                        child: Text(
                                          _dateRange == null
                                              ? 'Chọn ngày bắt đầu - kết thúc'
                                              : '${DateFormat('dd/MM/yyyy').format(_dateRange!.start)}  -  ${DateFormat('dd/MM/yyyy').format(_dateRange!.end)}',
                                          style: TextStyle(
                                            color:
                                                _dateRange == null
                                                    ? Colors.grey
                                                    : Colors.black87,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 32),
                                child: Divider(),
                              ),

                              // HEADER SLOTS
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: surfaceBlue,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.calendar_view_week_outlined,
                                          color: primaryBlue,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      const Text(
                                        'Cấu hình Lịch trong tuần',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1E3A8A),
                                        ),
                                      ),
                                    ],
                                  ),
                                  ElevatedButton.icon(
                                    onPressed:
                                        () => setState(
                                          () => _slots.add(UISlot()),
                                        ),
                                    icon: const Icon(Icons.add, size: 18),
                                    label: const Text('Thêm dòng'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: surfaceBlue,
                                      foregroundColor: primaryBlue,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // SLOT LIST
                              if (_slots.isEmpty)
                                const Center(
                                  child: Text(
                                    'Chưa có lịch nào. Nhấn "Thêm dòng" để bắt đầu.',
                                  ),
                                )
                              else
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _slots.length,
                                  separatorBuilder:
                                      (_, __) => const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    return _buildSlotRow(index, rooms);
                                  },
                                ),

                              const SizedBox(height: 40),

                              // BUTTON ACTIONS
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton(
                                    onPressed: () => Navigator.pop(context),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 32,
                                        vertical: 20,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      side: BorderSide(
                                        color: Colors.red.shade200,
                                      ),
                                      foregroundColor: Colors.red.shade400,
                                    ),
                                    child: const Text('Hủy bỏ'),
                                  ),
                                  const SizedBox(width: 16),
                                  ElevatedButton(
                                    onPressed:
                                        viewModel.isLoading
                                            ? null
                                            : () => _handleSubmit(viewModel),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryBlue,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 40,
                                        vertical: 20,
                                      ),
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child:
                                        viewModel.isLoading
                                            ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                            : const Text(
                                              'Lưu lịch học',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1,
                                              ),
                                            ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }

  Widget _buildSlotRow(int index, List<dynamic> rooms) {
    final slot = _slots[index];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 18, right: 16),
            child: Text(
              '#${index + 1}',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            width: 120,
            child: _buildDropdown<int>(
              label: 'Thứ',
              value: slot.dayOfWeek,
              items: List.generate(
                7,
                (i) => DropdownMenuItem(
                  value: i + 2,
                  child: Text('Thứ ${i + 2 == 8 ? 'CN' : i + 2}'),
                ),
              ),
              onChanged: (val) => setState(() => slot.dayOfWeek = val!),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: _buildDropdown<String>(
              label: 'Phòng học',
              value: slot.roomId,
              items:
                  rooms
                      .map(
                        (r) => DropdownMenuItem<String>(
                          value: r.id,
                          child: Text(r.name),
                        ),
                      )
                      .toList(),
              onChanged: (val) => setState(() => slot.roomId = val),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Expanded(
                  child: _TimeInput(
                    label: 'Bắt đầu',
                    time: slot.startTime,
                    onChanged: (t) => setState(() => slot.startTime = t),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: Colors.grey,
                  ),
                ),
                Expanded(
                  child: _TimeInput(
                    label: 'Kết thúc',
                    time: slot.endTime,
                    onChanged: (t) => setState(() => slot.endTime = t),
                  ),
                ),
              ],
            ),
          ),
          if (_slots.length > 1) ...[
            const SizedBox(width: 16),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.redAccent),
                tooltip: 'Xóa dòng này',
                onPressed: () => setState(() => _slots.removeAt(index)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      items: items,
      onChanged: onChanged,
      hint: const Text('Chọn...'),
    );
  }
}

class _TimeInput extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final Function(TimeOfDay) onChanged;

  const _TimeInput({
    required this.label,
    required this.time,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time,
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
        ),
        child: Text(time.format(context), style: const TextStyle(fontSize: 14)),
      ),
    );
  }
}
