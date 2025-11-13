import 'package:flutter/material.dart';
import 'package:mobile/services/admin/schedule_service.dart';
import 'package:provider/provider.dart';

class ScheduleFilterBar extends StatefulWidget {
  const ScheduleFilterBar({super.key});

  @override
  State<ScheduleFilterBar> createState() => _ScheduleFilterBarState();
}

class _ScheduleFilterBarState extends State<ScheduleFilterBar> {
  final _teacherController = TextEditingController();
  int? _selectedDayOfWeek;
  bool _expanded = false;

  final List<Map<String, dynamic>> _days = [
    {'label': 'Tất cả', 'value': null},
    {'label': 'Thứ 2', 'value': 2},
    {'label': 'Thứ 3', 'value': 3},
    {'label': 'Thứ 4', 'value': 4},
    {'label': 'Thứ 5', 'value': 5},
    {'label': 'Thứ 6', 'value': 6},
    {'label': 'Thứ 7', 'value': 7},
    {'label': 'Chủ nhật', 'value': 8},
  ];

  @override
  void dispose() {
    _teacherController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    setState(() {
      _teacherController.clear();
      _selectedDayOfWeek = null;
    });

    final service = context.read<ScheduleService>();
    service.updateSearchTeacher('');
    service.updateFilterDay(null);
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: const Text(
        "Bộ lọc",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      initiallyExpanded: _expanded,
      onExpansionChanged: (value) => setState(() => _expanded = value),
      childrenPadding: const EdgeInsets.all(12),
      children: [
        // Input tìm giảng viên
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha(30),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _teacherController,
            decoration: const InputDecoration(
              hintText: "Tìm theo giảng viên",
              prefixIcon: Icon(Icons.person, color: Colors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged:
                (val) =>
                    context.read<ScheduleService>().updateSearchTeacher(val),
          ),
        ),
        const SizedBox(height: 12),

        // Filter theo ngày
        Wrap(
          spacing: 8,
          children:
              _days.map((day) {
                final value = day['value'] as int?;
                final label = day['label'] as String;
                final isSelected = _selectedDayOfWeek == value;

                return FilterChip(
                  label: Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: Colors.blue,
                  backgroundColor: Colors.white,
                  checkmarkColor: Colors.white,
                  shape: StadiumBorder(
                    side: BorderSide(
                      color: isSelected ? Colors.blue : Colors.grey,
                    ),
                  ),
                  onSelected: (_) {
                    setState(() => _selectedDayOfWeek = value);
                    context.read<ScheduleService>().updateFilterDay(value);
                  },
                );
              }).toList(),
        ),
        const SizedBox(height: 8),

        // Nút xóa lọc
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            icon: const Icon(Icons.clear, color: Colors.red),
            label: const Text("Xóa lọc", style: TextStyle(color: Colors.red)),
            onPressed: _clearFilters,
          ),
        ),
      ],
    );
  }
}
