import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mobile/data/models/gift_model.dart';
import 'package:mobile/screens/admin/manage_gift/manage_gift_view_model.dart';
import 'package:mobile/shared_widgets/admin/action_icon_button.dart';
import 'package:mobile/shared_widgets/admin/base_admin_table.dart';
import 'package:mobile/shared_widgets/admin/common_empty_state.dart';
import 'package:mobile/shared_widgets/admin/common_table_cell.dart';

class ManageGiftContent extends StatefulWidget {
  final ManageGiftViewModel viewModel;
  final TextEditingController searchController;
  final Function(GiftModel?) onShowForm;
  final Function(GiftModel) onConfirmDelete;
  final Function(GiftModel) onConfirmRestore;

  const ManageGiftContent({
    super.key,
    required this.viewModel,
    required this.searchController,
    required this.onShowForm,
    required this.onConfirmDelete,
    required this.onConfirmRestore,
    this.maxWidth = double.infinity,
  });

  final double maxWidth;

  @override
  State<ManageGiftContent> createState() => _ManageGiftContentState();
}

class _ManageGiftContentState extends State<ManageGiftContent> {
  static const Color primaryBlue = Colors.blue;

  @override
  Widget build(BuildContext context) {
    final gifts = widget.viewModel.filteredGifts;
    final isLoading = widget.viewModel.isLoading;
    final showDeleted = widget.viewModel.showDeleted;

    Widget mainContent;
    if (isLoading) {
      mainContent = const Center(child: CircularProgressIndicator());
    } else if (gifts.isEmpty) {
      mainContent = _buildEmptyState(showDeleted);
    } else {
      mainContent = _buildTable(context, gifts, widget.maxWidth, showDeleted);
    }

    return Column(
      children: [
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
                showDeleted ? 'Thùng rác' : 'Kho quà',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: showDeleted ? Colors.red : primaryBlue,
                ),
              ),
              const Spacer(),
              const Text('Thùng rác', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 8),
              Switch(
                value: showDeleted,
                activeColor: Colors.red,
                onChanged: (value) => widget.viewModel.toggleShowDeleted(),
              ),
            ],
          ),
        ),
        Expanded(child: mainContent),
      ],
    );
  }

  Widget _buildEmptyState(bool showDeleted) {
    if (showDeleted) {
      return const CommonEmptyState(
        title: 'Thùng rác trống',
        subtitle: 'Các món quà bị ẩn sẽ xuất hiện ở đây.',
        icon: Icons.delete_outline,
      );
    }
    return const CommonEmptyState(
      title: 'Kho quà trống',
      subtitle: 'Hãy nhập thêm quà tặng để học viên đổi.',
      icon: Icons.card_giftcard,
    );
  }

  Widget _buildTable(
    BuildContext context,
    List<GiftModel> gifts,
    double maxWidth,
    bool showDeleted,
  ) {
    final colWidths = {
      0: maxWidth * 0.07,
      1: maxWidth * 0.12,
      2: maxWidth * 0.30,
      3: maxWidth * 0.15,
      4: maxWidth * 0.15,
      5: maxWidth * 0.25,
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
                                image: CachedNetworkImageProvider(gift.imageUrl!),
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
              CommonTableCell(
                gift.name,
                bold: true,
                color: Colors.blue[900],
                align: TextAlign.center,
              ),
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
                        onPressed: () => widget.onShowForm(gift),
                      ),
                      const SizedBox(width: 8),
                      ActionIconButton(
                        icon: Icons.delete,
                        color: Colors.red,
                        tooltip: 'Ẩn',
                        onPressed: () => widget.onConfirmDelete(gift),
                      ),
                    ] else
                      ElevatedButton.icon(
                        onPressed: () => widget.onConfirmRestore(gift),
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
