import 'package:flutter/material.dart';
import 'package:mobile/data/models/room_model.dart';
import 'package:mobile/screens/admin/manage_room/manage_room_view_model.dart';
import 'package:mobile/shared_widgets/admin/action_icon_button.dart';
import 'package:mobile/shared_widgets/admin/base_admin_table.dart';
import 'package:mobile/shared_widgets/admin/common_empty_state.dart';
import 'package:mobile/shared_widgets/admin/common_table_cell.dart';

class ManageRoomContent extends StatelessWidget {
  final ManageRoomViewModel viewModel;
  final Function(RoomModel) onEdit;
  final Function(RoomModel) onDelete;

  const ManageRoomContent({
    super.key,
    required this.viewModel,
    required this.onEdit,
    required this.onDelete,
    this.maxWidth = double.infinity,
  });

  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final rooms = viewModel.rooms;
    final isLoading = viewModel.isLoading;

    if (isLoading && rooms.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Colors.blue));
    } else if (rooms.isEmpty) {
      return _buildEmptyState(viewModel.searchQuery);
    } else {
      return _buildResponsiveTable(context, rooms, maxWidth);
    }
  }

  Widget _buildEmptyState(String? searchQuery) {
    bool isSearching = searchQuery != null && searchQuery.isNotEmpty;
    return CommonEmptyState(
      icon: Icons.meeting_room_outlined,
      title: isSearching ? 'Không tìm thấy phòng học' : 'Chưa có phòng học nào',
      subtitle:
          isSearching
              ? 'Thử tìm kiếm bằng từ khóa khác'
              : 'Nhấn "Thêm Phòng học" để bắt đầu',
    );
  }

  Widget _buildResponsiveTable(
    BuildContext context,
    List<RoomModel> rooms,
    double maxWidth,
  ) {
    final colWidths = {
      0: maxWidth * 0.40,
      1: maxWidth * 0.20,
      2: maxWidth * 0.20,
      3: maxWidth * 0.20,
    };
    final colHeaders = ['Tên phòng', 'Sức chứa', 'Trạng thái', 'Hành động'];

    final dataRows =
        rooms.map((room) {
          final String statusText;
          final Color statusColor;
          switch (room.status.toLowerCase()) {
            case 'active':
            case 'available':
              statusText = 'Hoạt động';
              statusColor = Colors.green.shade700;
              break;
            case 'inactive':
            case 'maintenance':
            default:
              statusText = 'Ngưng hoạt động';
              statusColor = Colors.orange.shade700;
              break;
          }

          return TableRow(
            children: [
              CommonTableCell(
                room.name,
                bold: true,
                color: const Color(0xFF1E3A8A),
                align: TextAlign.center,
              ),
              CommonTableCell(
                room.capactity.toString(),
                align: TextAlign.center,
              ),
              CommonTableCell(
                statusText,
                color: statusColor,
                align: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ActionIconButton(
                      icon: Icons.edit,
                      color: Colors.orange.shade600,
                      tooltip: 'Chỉnh sửa',
                      onPressed: () => onEdit(room),
                    ),
                    const SizedBox(width: 12),
                    ActionIconButton(
                      icon: Icons.delete,
                      color: Colors.redAccent,
                      tooltip: 'Xóa',
                      onPressed: () => onDelete(room),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList();

    return BaseAdminTable(
      columnWidths: colWidths.map((k, v) => MapEntry(k, FixedColumnWidth(v))),
      columnHeaders: colHeaders,
      dataRows: dataRows,
    );
  }
}
