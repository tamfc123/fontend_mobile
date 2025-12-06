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
        const SizedBox(width: 16),

        // Sort by Dropdown
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: viewModel.sortBy,
                isExpanded: true,
                icon: const Icon(Icons.sort, color: Colors.blue),
                items: const [
                  DropdownMenuItem(
                    value: 'time',
                    child: Text('Sắp xếp: Thời gian'),
                  ),
                  DropdownMenuItem(
                    value: 'class',
                    child: Text('Sắp xếp: Lớp học'),
                  ),
                  DropdownMenuItem(
                    value: 'teacher',
                    child: Text('Sắp xếp: Giảng viên'),
                  ),
                  DropdownMenuItem(
                    value: 'room',
                    child: Text('Sắp xếp: Phòng học'),
                  ),
                  DropdownMenuItem(value: 'day', child: Text('Sắp xếp: Ngày')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    context.read<ManageScheduleViewModel>().updateSort(value);
                  }
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Sort Order Toggle Button
        Container(
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: IconButton(
            onPressed: () {
              context.read<ManageScheduleViewModel>().toggleSortOrder();
            },
            icon: Icon(
              viewModel.sortOrder == 'asc'
                  ? Icons.arrow_upward
                  : Icons.arrow_downward,
              color: Colors.blue,
            ),
            tooltip: viewModel.sortOrder == 'asc' ? 'Tăng dần' : 'Giảm dần',
          ),
        ),
      ],
    );
  }
}
