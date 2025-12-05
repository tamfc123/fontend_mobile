import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/data/models/class_schedule_model.dart';
import 'package:mobile/screens/admin/manage_schedule/manage_schedule_view_model.dart';
import 'package:mobile/shared_widgets/admin/comfirm_delete_dialog.dart';
import 'package:mobile/screens/admin/manage_schedule/widgets/schedule_form_dialog.dart';
import 'package:provider/provider.dart';

class ScheduleDetailPanel extends StatelessWidget {
  final ClassScheduleModel? schedule;
  final VoidCallback onDeleted;

  const ScheduleDetailPanel({
    super.key,
    required this.schedule,
    required this.onDeleted,
  });

  static const Color primaryBlue = Colors.blue;

  void _openEditDialog(BuildContext context, ClassScheduleModel schedule) {
    // Get viewModel for data
    final viewModel = context.read<ManageScheduleViewModel>();

    showDialog(
      context: context,
      builder:
          (dialogContext) => ChangeNotifierProvider.value(
            value: viewModel,
            child: ScheduleFormDialog(
              schedule: schedule,
              classes: viewModel.classes,
              rooms: viewModel.activeRooms,
            ),
          ),
    ).then((_) {
      // Reload data after edit
      viewModel.loadData();
    });
  }

  void _confirmDelete(BuildContext context, ClassScheduleModel schedule) {
    showDialog(
      context: context,
      builder:
          (_) => ConfirmDeleteDialog(
            title: 'Xác nhận xóa',
            content:
                'Bạn có chắc muốn xóa thời khóa biểu lớp "${schedule.className}"?',
            itemName: schedule.className,
            onConfirm: () async {
              final success = await context
                  .read<ManageScheduleViewModel>()
                  .deleteSchedule(schedule.id);
              if (success) {
                onDeleted();
              }
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (schedule == null) {
      return const Center(
        child: Text(
          'Chọn lịch để xem chi tiết',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lớp: ${schedule!.className}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 20),
          _buildDetailRow(
            Icons.room,
            'Phòng:',
            schedule!.roomName ?? 'Chưa có',
          ),
          _buildDetailRow(
            Icons.person,
            'Giảng viên:',
            schedule!.teacherName ?? 'Chưa có',
          ),
          _buildDetailRow(
            Icons.access_time,
            'Thời gian:',
            '${schedule!.startTime} - ${schedule!.endTime}',
          ),
          _buildDetailRow(
            Icons.date_range,
            'Ngày:',
            DateFormat('dd/MM/yyyy').format(schedule!.startDate),
          ),

          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildActionButton(
                Icons.edit,
                Colors.orange.shade600,
                'Sửa',
                () => _openEditDialog(context, schedule!),
              ),
              const SizedBox(width: 12),
              _buildActionButton(
                Icons.delete,
                Colors.redAccent,
                'Xóa',
                () => _confirmDelete(context, schedule!),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: primaryBlue),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 6),
          Expanded(child: Text(value, overflow: TextOverflow.ellipsis)),
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
      label: Text(label, style: TextStyle(color: color)),
      style: OutlinedButton.styleFrom(side: BorderSide(color: color)),
    );
  }
}
