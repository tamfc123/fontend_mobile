import 'package:flutter/material.dart';
import 'package:mobile/data/models/room_model.dart';
import 'package:mobile/services/admin/room_service.dart';
import 'package:mobile/widgets/admin/comfirm_delete_dialog.dart';
import 'package:mobile/widgets/admin/room_add_edit_dialog.dart';
import 'package:provider/provider.dart';

class ManageRoomScreen extends StatefulWidget {
  const ManageRoomScreen({super.key});

  @override
  State<ManageRoomScreen> createState() => _ManageRoomScreenState();
}

class _ManageRoomScreenState extends State<ManageRoomScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // MÀU CHỦ ĐẠO (ĐỒNG NHẤT)
  static const Color primaryBlue = Colors.blue;
  static const Color backgroundBlue = Color(0xFFF3F8FF);
  static const Color surfaceBlue = Color(0xFFE3F2FD);

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<RoomService>().fetchRooms());
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddOrEditDialog({RoomModel? room}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => RoomFormDialog(room: room),
    );
    if (result == true && mounted) {
      await context.read<RoomService>().fetchRooms();
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
              await context.read<RoomService>().deleteRoom(room.id);
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roomService = context.watch<RoomService>();
    final rooms = roomService.rooms;

    final filteredRooms =
        rooms.where((r) {
          return r.name.toLowerCase().contains(_searchQuery);
        }).toList();

    return Scaffold(
      backgroundColor: backgroundBlue,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === HEADER + TÌM KIẾM (KHÔNG CÓ BACK) ===
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // HEADER ROW
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                        child: Row(
                          children: [
                            // ICON + TIÊU ĐỀ
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: surfaceBlue,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.meeting_room,
                                color: primaryBlue,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),

                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Quản lý Phòng học',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E3A8A),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Tất cả phòng học trong hệ thống',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // NÚT THÊM
                            ElevatedButton.icon(
                              onPressed: () => _showAddOrEditDialog(),
                              icon: const Icon(Icons.add, size: 20),
                              label: const Text(
                                'Thêm Phòng học',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryBlue,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 22,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // THANH TÌM KIẾM + STATS
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                        child: Column(
                          children: [
                            Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: surfaceBlue,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: 'Tìm kiếm theo tên phòng...',
                                  hintStyle: TextStyle(
                                    color: Colors.grey.shade600,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: primaryBlue,
                                  ),
                                  suffixIcon:
                                      _searchQuery.isNotEmpty
                                          ? IconButton(
                                            icon: Icon(
                                              Icons.clear,
                                              color: Colors.grey.shade600,
                                            ),
                                            onPressed: () {
                                              _searchController.clear();
                                            },
                                          )
                                          : null,
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (filteredRooms.isNotEmpty)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Tìm thấy ${filteredRooms.length} phòng học',
                                  style: TextStyle(
                                    color: primaryBlue,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // === BẢNG PHÒNG HỌC ===
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child:
                              roomService.isLoading
                                  ? const Center(
                                    child: CircularProgressIndicator(
                                      color: primaryBlue,
                                    ),
                                  )
                                  : filteredRooms.isEmpty
                                  ? _buildEmptyState()
                                  : _buildResponsiveTable(
                                    filteredRooms,
                                    constraints.maxWidth,
                                  ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.meeting_room_outlined,
            size: 72,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? 'Chưa có phòng học nào'
                : 'Không tìm thấy phòng học',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'Nhấn "Thêm Phòng học" để bắt đầu'
                : 'Thử tìm kiếm bằng từ khóa khác',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveTable(List<RoomModel> rooms, double maxWidth) {
    final colWidths = {
      0: maxWidth * 0.40, // Tên phòng
      1: maxWidth * 0.20, // Sức chứa
      2: maxWidth * 0.20, // Trạng thái
      3: maxWidth * 0.20, // Hành động
    };

    return SingleChildScrollView(
      child: IntrinsicWidth(
        child: Table(
          columnWidths: colWidths.map(
            (key, value) => MapEntry(key, FixedColumnWidth(value)),
          ),
          border: TableBorder(
            bottom: BorderSide(color: surfaceBlue),
            horizontalInside: BorderSide(
              color: Colors.grey.shade200,
              width: 0.5,
            ),
          ),
          children: [
            // Header
            TableRow(
              decoration: BoxDecoration(color: surfaceBlue),
              children:
                  ['Tên phòng', 'Sức chứa', 'Trạng thái', 'Hành động']
                      .map(
                        (title) => Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: primaryBlue,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                      .toList(),
            ),
            // Rows
            ...rooms.map((room) {
              return TableRow(
                children: [
                  _buildCell(
                    room.name,
                    bold: true,
                    color: const Color(0xFF1E3A8A),
                    align: TextAlign.center,
                  ),
                  _buildCell(room.capacity.toString(), align: TextAlign.center),
                  _buildCell(
                    room.status,
                    color:
                        room.status.toLowerCase() == 'available'
                            ? Colors.orange.shade700
                            : Colors.green.shade700,
                    align: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildActionButton(
                          Icons.edit,
                          Colors.orange.shade600,
                          'Chỉnh sửa',
                          () => _showAddOrEditDialog(room: room),
                        ),
                        const SizedBox(width: 12),
                        _buildActionButton(
                          Icons.delete,
                          Colors.redAccent,
                          'Xóa',
                          () => _confirmDelete(room),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCell(
    String content, {
    TextAlign align = TextAlign.left,
    bool bold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Text(
        content,
        style: TextStyle(
          fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
          color: color ?? Colors.black87,
          fontSize: 14.5,
        ),
        textAlign: align,
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    Color color,
    String tooltip,
    VoidCallback onPressed,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 22),
        tooltip: tooltip,
        onPressed: onPressed,
        padding: const EdgeInsets.all(10),
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      ),
    );
  }
}
