import 'package:flutter/material.dart';
import 'package:mobile/data/models/class_model.dart';

import 'package:mobile/screens/admin/manage_class/manage_class_view_model.dart';
import 'package:mobile/screens/admin/manage_class/widgets/class_form_dialog.dart';
import 'package:mobile/screens/admin/manage_class/widgets/manage_class_content.dart';
import 'package:mobile/shared_widgets/admin/base_admin_screen.dart';
import 'package:mobile/shared_widgets/admin/comfirm_delete_dialog.dart';
import 'package:mobile/shared_widgets/admin/pagination_controls.dart';
import 'package:provider/provider.dart';

class ManageClassScreen extends StatefulWidget {
  const ManageClassScreen({super.key});

  @override
  State<ManageClassScreen> createState() => _ManageClassScreenState();
}

class _ManageClassScreenState extends State<ManageClassScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ManageClassViewModel>().init();
    });
  }

  void _onSearchChanged() {
    // Implement search logic if needed, or just let BaseAdminScreen handle it via controller
    // If ViewModel needs to know about search text changes immediately:
    // context.read<ManageClassViewModel>().onSearchChanged(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ManageClassViewModel>(
      builder: (context, viewModel, child) {
        return BaseAdminScreen(
          title: 'Quản lý Lớp học',
          subtitle: 'Tất cả lớp học trong hệ thống',
          headerIcon: Icons.groups_rounded,
          addLabel: 'Thêm Lớp học',
          onAddPressed: () => _showAddOrEditDialog(context, viewModel),
          onBackPressed: null,
          searchController: _searchController,
          searchHint: 'Tìm kiếm theo tên lớp...',
          isLoading: viewModel.isLoading,
          totalCount: viewModel.totalCount,
          countLabel: 'Lớp',
          body: _buildBodyContent(context, viewModel),
          paginationControls: PaginationControls(
            currentPage: viewModel.currentPage,
            totalPages: viewModel.totalPages,
            totalCount: viewModel.totalCount,
            isLoading: viewModel.isLoading,
            onPageChanged: (page) => viewModel.goToPage(page),
          ),
        );
      },
    );
  }

  Widget _buildBodyContent(
    BuildContext context,
    ManageClassViewModel viewModel,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double tableWidth =
            constraints.maxWidth < 1000 ? 1000 : constraints.maxWidth;
        return ManageClassContent(
          viewModel: viewModel,
          searchController: _searchController,
          maxWidth: tableWidth,
          onEdit: (clazz) {
            _showAddOrEditDialog(context, viewModel, clazz: clazz);
          },
          onDelete: (clazz) {
            _confirmDelete(context, viewModel, clazz);
          },
        );
      },
    );
  }
}

void _showAddOrEditDialog(
  BuildContext context,
  ManageClassViewModel viewModel, {
  ClassModel? clazz,
}) {
  showDialog(
    context: context,
    builder:
        (_) => ClassFormDialog(
          classModel: clazz,
          courses: viewModel.courses,
          teachers: viewModel.teachers,
          onSave: (name, courseId, teacherId) async {
            if (clazz == null) {
              return await viewModel.addClass(name, courseId, teacherId);
            } else {
              return await viewModel.updateClass(
                clazz.id,
                name,
                courseId,
                teacherId,
              );
            }
          },
        ),
  );
}

void _confirmDelete(
  BuildContext context,
  ManageClassViewModel viewModel,
  ClassModel clazz,
) {
  showDialog(
    context: context,
    builder:
        (_) => ConfirmDeleteDialog(
          title: 'Xác nhận xóa',
          content: 'Bạn có chắc muốn xóa lớp học "${clazz.name}"?',
          itemName: clazz.name,
          onConfirm: () async {
            await viewModel.deleteClass(clazz.id);
          },
        ),
  );
}
