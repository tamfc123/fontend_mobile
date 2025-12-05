import 'package:flutter/material.dart';
import 'package:mobile/data/models/gift_model.dart';

import 'package:mobile/screens/admin/manage_gift/manage_gift_view_model.dart';
import 'package:mobile/screens/admin/manage_gift/widgets/gift_form_dialog.dart';

import 'package:mobile/screens/admin/manage_gift/widgets/manage_gift_content.dart';
import 'package:mobile/shared_widgets/admin/base_admin_screen.dart';
import 'package:mobile/shared_widgets/admin/pagination_controls.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class ManageGiftScreen extends StatefulWidget {
  const ManageGiftScreen({super.key});

  @override
  State<ManageGiftScreen> createState() => _ManageGiftScreenState();
}

class _ManageGiftScreenState extends State<ManageGiftScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    // 3. Lắng nghe thay đổi text
    _searchController.addListener(_onSearchChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ManageGiftViewModel>().fetchGifts();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel(); // Hủy timer
    _searchController.removeListener(_onSearchChanged); // Hủy listener
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<ManageGiftViewModel>().applySearch(_searchController.text);
    });
  }

  void _showForm(BuildContext context, {GiftModel? gift}) async {
    final result = await showDialog<GiftModel>(
      context: context,
      builder: (_) => GiftFormDialog(gift: gift),
    );

    if (result != null && context.mounted) {
      final viewModel = context.read<ManageGiftViewModel>();
      if (gift == null) {
        await viewModel.createGift(result);
      } else {
        await viewModel.updateGift(result.id, result);
      }
    }
  }

  void _confirmDelete(BuildContext context, GiftModel gift) {
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
                  await context.read<ManageGiftViewModel>().deleteGift(gift.id);
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

  void _confirmRestore(BuildContext context, GiftModel gift) {
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
                  await context.read<ManageGiftViewModel>().restoreGift(
                    gift.id,
                  );
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
    return Consumer<ManageGiftViewModel>(
      builder: (context, viewModel, child) {
        return BaseAdminScreen(
          title: 'Quản lý Kho Quà',
          subtitle:
              viewModel.showDeleted
                  ? 'THÙNG RÁC'
                  : 'Danh sách quà tặng hiện có',
          headerIcon:
              viewModel.showDeleted
                  ? Icons.delete_outline
                  : Icons.card_giftcard,
          addLabel: 'Nhập Quà Mới',
          onAddPressed: () {
            if (viewModel.showDeleted) {
              viewModel.toggleShowDeleted();
            }
            _showForm(context);
          },
          onBackPressed: null,
          searchController: _searchController,
          searchHint: 'Tìm theo tên quà...',
          isLoading: viewModel.isLoading,
          totalCount: viewModel.totalCount,
          countLabel: 'món quà',
          body: LayoutBuilder(
            builder: (context, constraints) {
              final double tableWidth =
                  constraints.maxWidth < 1000 ? 1000 : constraints.maxWidth;
              return ManageGiftContent(
                viewModel: viewModel,
                searchController: _searchController,
                maxWidth: tableWidth,
                onShowForm: (gift) => _showForm(context, gift: gift),
                onConfirmDelete: (gift) => _confirmDelete(context, gift),
                onConfirmRestore: (gift) => _confirmRestore(context, gift),
              );
            },
          ),
          paginationControls: PaginationControls(
            currentPage: viewModel.currentPage,
            totalPages: viewModel.totalPages,
            totalCount: viewModel.totalCount,
            isLoading: viewModel.isLoading,
            onPageChanged: (page) {
              viewModel.goToPage(page);
            },
          ),
        );
      },
    );
  }
}
