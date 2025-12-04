import 'package:flutter/material.dart';
import 'package:mobile/screens/admin/manage_schedule/manage_schedule_view_model.dart';
import 'package:provider/provider.dart';

class ScheduleFilterBar extends StatelessWidget {
  const ScheduleFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ManageScheduleViewModel>();

    return Row(
      children: [
        // Filter by Teacher Name
        Expanded(
          flex: 2,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Tìm theo tên giảng viên...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onChanged: (value) {
              context.read<ManageScheduleViewModel>().updateSearchTeacher(
                value,
              );
            },
          ),
        ),
        const SizedBox(width: 16),

        // Filter by Day of Week
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: viewModel.filterDayOfWeek,
                hint: const Text('Tất cả các ngày'),
                isExpanded: true,
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Tất cả các ngày'),
                  ),
                  ...List.generate(7, (index) {
                    final day = index + 2;
                    return DropdownMenuItem(
                      value: day,
                      child: Text('Thứ ${day == 8 ? 'CN' : day}'),
                    );
                  }),
                ],
                onChanged: (value) {
                  context.read<ManageScheduleViewModel>().updateFilterDay(
                    value,
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
