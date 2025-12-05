import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile/data/models/room_model.dart';

import 'package:mobile/screens/admin/manage_room/manage_room_view_model.dart';
import 'package:mobile/screens/admin/manage_room/widgets/manage_room_content.dart';
import 'package:mobile/screens/admin/manage_room/widgets/room_form_dialog.dart';
import 'package:mobile/shared_widgets/admin/base_admin_screen.dart';
import 'package:mobile/shared_widgets/admin/pagination_controls.dart';
import 'package:mobile/shared_widgets/admin/comfirm_delete_dialog.dart';
import 'package:provider/provider.dart';

class ManageRoomScreen extends StatefulWidget {
  const ManageRoomScreen({super.key});

  @override
  State<ManageRoomScreen> createState() => _ManageRoomScreenState();
}

class _ManageRoomScreenState extends State<ManageRoomScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ManageRoomViewModel>().fetchRooms();
    });
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
        context.read<ManageRoomViewModel>().applySearch(_searchController.text);
      }
    });
  }

  void _showAddOrEditDialog(BuildContext context, {RoomModel? room}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => RoomFormDialog(room: room),
    );
    if (result == true && mounted) {
      await context.read<ManageRoomViewModel>().fetchRooms();
    }
  }

  void _confirmDelete(BuildContext context, RoomModel room) {
    showDialog(
      context: context,
      builder:
          (_) => ConfirmDeleteDialog(
            title: 'Xác nhận xóa',
            content: 'Bạn có chắc muốn xóa phòng "${room.name}"?',
            itemName: room.name,
            onConfirm: () async {
              await context.read<ManageRoomViewModel>().deleteRoom(room.id);
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ManageRoomViewModel>(
      builder: (context, viewModel, child) {
        final isLoading = viewModel.isLoading;

        return BaseAdminScreen(
          title: 'Quản lý Phòng học',
          subtitle: 'Danh sách phòng học',
          headerIcon: Icons.meeting_room,
          addLabel: 'Thêm Phòng',
          onAddPressed: () => _showAddOrEditDialog(context),
          onBackPressed: null,
          searchController: _searchController,
          searchHint: 'Tìm kiếm phòng...',
          isLoading: isLoading,
          totalCount: viewModel.totalCount,
          countLabel: 'phòng',
          body: LayoutBuilder(
            builder: (context, constraints) {
              final double tableWidth =
                  constraints.maxWidth < 1000 ? 1000 : constraints.maxWidth;
              return ManageRoomContent(
                viewModel: viewModel,
                maxWidth: tableWidth,
                onEdit: (room) => _showAddOrEditDialog(context, room: room),
                onDelete: (room) => _confirmDelete(context, room),
              );
            },
          ),
          paginationControls: PaginationControls(
            currentPage: viewModel.currentPage,
            totalPages: viewModel.totalPages,
            totalCount: viewModel.totalCount,
            isLoading: isLoading,
            onPageChanged: (page) {
              viewModel.goToPage(page);
            },
          ),
        );
      },
    );
  }
}
