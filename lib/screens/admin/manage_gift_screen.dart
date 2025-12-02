import 'package:flutter/material.dart';
import 'package:mobile/data/models/gift_model.dart';
import 'package:mobile/services/admin/admin_gift_service.dart';
import 'package:mobile/shared_widgets/admin/action_icon_button.dart';
import 'package:mobile/shared_widgets/admin/base_admin_screen.dart';
import 'package:mobile/shared_widgets/admin/base_admin_table.dart';
import 'package:mobile/shared_widgets/admin/common_empty_state.dart';
import 'package:mobile/shared_widgets/admin/common_table_cell.dart';
import 'package:mobile/widgets/admin/gift_form_dialog.dart';
import 'package:provider/provider.dart';

class ManageGiftScreen extends StatefulWidget {
  const ManageGiftScreen({super.key});

  @override
  State<ManageGiftScreen> createState() => _ManageGiftScreenState();
}

class _ManageGiftScreenState extends State<ManageGiftScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Màu chủ đạo
  static const Color primaryBlue = Colors.blue;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<AdminGiftService>().fetchGifts());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showForm({GiftModel? gift}) async {
    final result = await showDialog<GiftModel>(
      context: context,
      builder: (_) => GiftFormDialog(gift: gift),
    );

    if (result != null && mounted) {
      final service = context.read<AdminGiftService>();
      if (gift == null) {
        await service.createGift(result);
      } else {
        await service.updateGift(result.id, result);
      }
    }
  }

  void _confirmDelete(GiftModel gift) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Xác nhận ẩn quà tặng'),
            content: Text('Bạn có chắc muốn ẩn "${gift.name}" khỏi cửa hàng?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                onPressed: () async {
                  Navigator.pop(dialogContext);
                  await context.read<AdminGiftService>().deleteGift(gift.id);
                },
                child: const Text(
                  'Đồng ý',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _confirmRestore(GiftModel gift) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Khôi phục quà tặng'),
            content: Text('Bạn có chắc muốn mở bán lại "${gift.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () async {
                  Navigator.pop(dialogContext);
                  await context.read<AdminGiftService>().restoreGift(gift.id);
                },
                child: const Text(
                  'Khôi phục',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<AdminGiftService>();
    final gifts = service.gifts;
    final isLoading = service.isLoading;
    final showDeleted = service.showDeleted;

    final filteredGifts =
        _searchController.text.isEmpty
            ? gifts
            : gifts
                .where(
                  (g) => g.name.toLowerCase().contains(
                    _searchController.text.toLowerCase(),
                  ),
                )
                .toList();

    // 1. Xây dựng nội dung bảng/empty state (mainContent)
    Widget mainContent;
    if (isLoading) {
      mainContent = const Center(child: CircularProgressIndicator());
    } else if (filteredGifts.isEmpty) {
      mainContent = _buildEmptyState(showDeleted);
    } else {
      mainContent = LayoutBuilder(
        builder:
            (context, constraints) =>
                _buildTable(filteredGifts, constraints.maxWidth, showDeleted),
      );
    }

    // 2. Bọc nội dung trong Column để thêm thanh Header Thùng rác (Thay thế cho tham số actions bị lỗi)
    Widget bodyContent = Column(
      children: [
        // Thanh công cụ bộ lọc (Switch Thùng rác)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: showDeleted ? Colors.red.shade50 : Colors.blue.shade50,
          child: Row(
            children: [
              Icon(
                showDeleted ? Icons.delete_sweep : Icons.inventory_2,
                color: showDeleted ? Colors.red : primaryBlue,
              ),
              const SizedBox(width: 12),
              Text(
                showDeleted ? 'Đang xem Thùng Rác' : 'Kho Quà Hiện Tại',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: showDeleted ? Colors.red : primaryBlue,
                ),
              ),
              const Spacer(),
              const Text('Xem Thùng rác', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 8),
              Switch(
                value: showDeleted,
                activeColor: Colors.red,
                onChanged: (value) => service.toggleShowDeleted(),
              ),
            ],
          ),
        ),

        // Nội dung chính chiếm phần còn lại
        Expanded(child: mainContent),
      ],
    );

    return BaseAdminScreen(
      title: 'Quản lý Kho Quà',
      subtitle: showDeleted ? 'THÙNG RÁC' : 'Danh sách quà tặng hiện có',
      headerIcon: showDeleted ? Icons.delete_outline : Icons.card_giftcard,

      // ✅ [FIX LỖI 1] Luôn truyền String và Function, xử lý logic bên trong
      addLabel: 'Nhập Quà Mới',
      onAddPressed: () {
        if (showDeleted) {
          service
              .toggleShowDeleted(); // Chuyển về list hiện tại nếu đang ở thùng rác
        }
        _showForm();
      },

      onBackPressed: null,
      searchController: _searchController,
      searchHint: 'Tìm theo tên quà...',

      isLoading: isLoading,
      totalCount: filteredGifts.length,
      countLabel: 'món quà',

      // ✅ [FIX LỖI 2] Bỏ tham số 'actions' gây lỗi
      // Nút lọc thùng rác đã được chuyển vào biến 'bodyContent' ở trên
      body: bodyContent,

      // ✅ [FIX LỖI 3] Truyền widget rỗng thay vì null
      paginationControls: const SizedBox.shrink(),
    );
  }

  Widget _buildEmptyState(bool showDeleted) {
    if (showDeleted) {
      return CommonEmptyState(
        title: 'Thùng rác trống',
        subtitle: 'Các món quà bị ẩn sẽ xuất hiện ở đây.',
        icon: Icons.delete_outline,
      );
    }
    return CommonEmptyState(
      title: 'Kho quà trống',
      subtitle: 'Hãy nhập thêm quà tặng để học viên đổi.',
      icon: Icons.card_giftcard,
    );
  }

  Widget _buildTable(List<GiftModel> gifts, double maxWidth, bool showDeleted) {
    final colWidths = {
      0: maxWidth * 0.05, // STT
      1: maxWidth * 0.10, // Ảnh
      2: maxWidth * 0.30, // Tên (Tăng từ 0.25)
      3: maxWidth * 0.15, // Giá
      4: maxWidth * 0.15, // Tồn kho
      5: maxWidth * 0.25, // Hành động (Tăng từ 0.20)
    };
    final colHeaders = [
      'STT',
      'Ảnh',
      'Tên Quà',
      'Giá Coin',
      'Tồn Kho',
      showDeleted ? 'Khôi phục' : 'Hành động',
    ];

    final dataRows =
        gifts.asMap().entries.map((entry) {
          final index = entry.key + 1;
          final gift = entry.value;

          return TableRow(
            children: [
              CommonTableCell('$index', align: TextAlign.center, bold: true),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[200],
                      image:
                          gift.imageUrl != null
                              ? DecorationImage(
                                image: NetworkImage(gift.imageUrl!),
                                fit: BoxFit.cover,
                              )
                              : null,
                    ),
                    child:
                        gift.imageUrl == null
                            ? const Icon(
                              Icons.image,
                              size: 20,
                              color: Colors.grey,
                            )
                            : null,
                  ),
                ),
              ),

              CommonTableCell(gift.name, bold: true, color: Colors.blue[900]),

              CommonTableCell(
                '${gift.coinPrice} xu',
                align: TextAlign.center,
                color: Colors.orange[800],
                bold: true,
              ),

              CommonTableCell(
                '${gift.stockQuantity}',
                align: TextAlign.center,
                color: gift.stockQuantity == 0 ? Colors.red : Colors.black87,
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!showDeleted) ...[
                      ActionIconButton(
                        icon: Icons.edit,
                        color: Colors.orange,
                        tooltip: 'Sửa',
                        onPressed: () => _showForm(gift: gift),
                      ),
                      const SizedBox(width: 8),
                      ActionIconButton(
                        icon: Icons.delete,
                        color: Colors.red,
                        tooltip: 'Ẩn',
                        onPressed: () => _confirmDelete(gift),
                      ),
                    ] else
                      ElevatedButton.icon(
                        onPressed: () => _confirmRestore(gift),
                        icon: const Icon(
                          Icons.restore,
                          size: 16,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Khôi phục',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
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
