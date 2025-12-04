import 'package:flutter/material.dart';

class ScheduleFilterDropdown extends StatelessWidget {
  final String selectedDay;
  final ValueChanged<String> onChanged;

  const ScheduleFilterDropdown({
    super.key,
    required this.selectedDay,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final dayOptions = {
      'Tất cả': null,
      'Thứ 2': 2,
      'Thứ 3': 3,
      'Thứ 4': 4,
      'Thứ 5': 5,
      'Thứ 6': 6,
      'Thứ 7': 7,
      'Chủ nhật': 8,
    };

    return Row(
      children: [
        const Text(
          'Lọc theo thứ: ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 12),
        DropdownButton<String>(
          value: selectedDay,
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
          items:
              dayOptions.keys
                  .map((day) => DropdownMenuItem(value: day, child: Text(day)))
                  .toList(),
        ),
      ],
    );
  }
}
