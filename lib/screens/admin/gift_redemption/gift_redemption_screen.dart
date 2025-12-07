import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/screens/admin/gift_redemption/gift_redemption_view_model.dart';
import 'package:mobile/screens/admin/gift_redemption/widgets/gift_redemption_content.dart';
import 'package:mobile/shared_widgets/admin/base_admin_screen.dart';
import 'package:mobile/shared_widgets/admin/pagination_controls.dart';
import 'dart:async';

class GiftRedemptionScreen extends StatefulWidget {
  const GiftRedemptionScreen({super.key});

  @override
  State<GiftRedemptionScreen> createState() => _GiftRedemptionScreenState();
}

class _GiftRedemptionScreenState extends State<GiftRedemptionScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);

    // Fetch initial students
    Future.microtask(() {
      context.read<GiftRedemptionViewModel>().fetchStudents();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<GiftRedemptionViewModel>().searchStudents(
        _searchController.text,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GiftRedemptionViewModel>(
      builder: (context, viewModel, child) {
        return BaseAdminScreen(
          title: 'Trao Quà cho Học viên',
          subtitle: 'Xác nhận trao quà cho học viên đã đổi',
          headerIcon: Icons.card_giftcard_rounded,
          addLabel: '',
          onAddPressed: null, // Hide add button
          onBackPressed: null,
          searchController: _searchController,
          searchHint: 'Tìm học viên theo tên hoặc email...',
          isLoading: viewModel.isLoadingStudents,
          totalCount: viewModel.students.length,
          countLabel: 'học viên',
          body: LayoutBuilder(
            builder: (context, constraints) {
              return GiftRedemptionContent(
                viewModel: viewModel,
                maxWidth: constraints.maxWidth,
              );
            },
          ),
          paginationControls: PaginationControls(
            currentPage: viewModel.currentPage,
            totalPages: viewModel.totalPages,
            totalCount: viewModel.totalCount,
            isLoading: viewModel.isLoadingStudents,
            onPageChanged: (page) {
              viewModel.goToPage(page);
            },
          ),
        );
      },
    );
  }
}
