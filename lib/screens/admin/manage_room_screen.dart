import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile/data/models/room_model.dart';
import 'package:mobile/services/admin/admin_room_service.dart';
import 'package:mobile/shared_widgets/admin/base_admin_screen.dart';
import 'package:mobile/shared_widgets/admin/base_admin_table.dart';
import 'package:mobile/shared_widgets/admin/pagination_controls.dart';
import 'package:mobile/shared_widgets/admin/common_empty_state.dart';
import 'package:mobile/shared_widgets/admin/action_icon_button.dart';
import 'package:mobile/shared_widgets/admin/common_table_cell.dart';
import 'package:mobile/shared_widgets/comfirm_delete_dialog.dart';
import 'package:mobile/widgets/admin/room_form_dialog.dart';
import 'package:provider/provider.dart';

class ManageRoomScreen extends StatefulWidget {
  const ManageRoomScreen({super.key});

  @override
  State<ManageRoomScreen> createState() => _ManageRoomScreenState();
}

class _ManageRoomScreenState extends State<ManageRoomScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  // MÀU CHỦ ĐẠO
  static const Color primaryBlue = Colors.blue;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final roomService = context.read<AdminRoomService>();

      _searchController.text = roomService.searchQuery ?? '';

      // Tải dữ liệu lần đầu
      Future.wait([roomService.fetchRooms()]);
    });

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.read<AdminRoomService>().applySearch(_searchController.text);
      }
    });
  }

  void _showAddOrEditDialog({RoomModel? room}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => RoomFormDialog(room: room),
    );
    if (result == true && mounted) {
      await context.read<AdminRoomService>().fetchRooms();
    }
  }

  void _confirmDelete(RoomModel room) {
    showDialog(
      context: context,
      builder:
          (_) => ConfirmDeleteDialog(
            title: 'Xác nhận xóa',
            content: 'Bạn có chắc muốn xóa phòng "${room.name}"?',
            itemName: room.name,
            onConfirm: () async {
              // (Service của bạn chưa trả về bool, nhưng logic vẫn đúng)
              context.read<AdminRoomService>().deleteRoom(room.id);
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roomService = context.watch<AdminRoomService>();
    final rooms = roomService.rooms;
    final isLoading = roomService.isLoading;

    // ✅ 3. XÂY DỰNG BODYCONTENT
    Widget bodyContent;
    if (isLoading && rooms.isEmpty) {
      bodyContent = const Center(
        child: CircularProgressIndicator(color: primaryBlue),
      );
    } else if (rooms.isEmpty) {
      bodyContent = _buildEmptyState(roomService.searchQuery);
    } else {
      bodyContent = LayoutBuilder(
        builder:
            (context, constraints) =>
                _buildResponsiveTable(rooms, constraints.maxWidth),
      );
    }

    // ✅ 4. SỬ DỤNG BaseAdminScreen
    return BaseAdminScreen(
      title: 'Quản lý Phòng học',
      subtitle: 'Tất cả phòng học trong hệ thống',
      headerIcon: Icons.meeting_room,
      addLabel: 'Thêm Phòng học',
      onAddPressed: () => _showAddOrEditDialog(),
      onBackPressed: null, // 👈 Không có nút Back

      searchController: _searchController,
      searchHint: 'Tìm kiếm theo tên phòng...',
      isLoading: isLoading,
      totalCount: roomService.totalCount,
      countLabel: 'Phòng', // 👈 Sửa label

      body: bodyContent,

      paginationControls: PaginationControls(
        currentPage: roomService.currentPage,
        totalPages: roomService.totalPages,
        totalCount: roomService.totalCount,
        isLoading: isLoading,
        onPageChanged: (page) {
          // 👈 Service này dùng hàm goToPage
          context.read<AdminRoomService>().goToPage(page);
        },
      ),
    );
  }

  // ✅ 5. SỬ DỤNG CommonEmptyState
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

  // ✅ 6. SỬ DỤNG BaseAdminTable
  Widget _buildResponsiveTable(List<RoomModel> rooms, double maxWidth) {
    final colWidths = {
      0: maxWidth * 0.40,
      1: maxWidth * 0.20,
      2: maxWidth * 0.20,
      3: maxWidth * 0.20,
    };
    final colHeaders = ['Tên phòng', 'Sức chứa', 'Trạng thái', 'Hành động'];

    // Tạo các dòng dữ liệu
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
              // ✅ 7. SỬ DỤNG CommonTableCell
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
                    // ✅ 8. SỬ DỤNG ActionIconButton
                    ActionIconButton(
                      icon: Icons.edit,
                      color: Colors.orange.shade600,
                      tooltip: 'Chỉnh sửa',
                      onPressed: () => _showAddOrEditDialog(room: room),
                    ),
                    const SizedBox(width: 12),
                    ActionIconButton(
                      icon: Icons.delete,
                      color: Colors.redAccent,
                      tooltip: 'Xóa',
                      onPressed: () => _confirmDelete(room),
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

  // ❌ 9. XÓA _buildCell, _buildActionButton, VÀ _buildPaginationControls
}
