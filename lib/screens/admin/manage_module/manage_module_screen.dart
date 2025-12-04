import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/data/models/course_model.dart';
import 'package:mobile/data/models/module_model.dart';

import 'package:mobile/screens/admin/manage_module/manage_module_view_model.dart';
import 'package:mobile/screens/admin/manage_module/widgets/manage_module_content.dart';
import 'package:mobile/screens/admin/manage_module/widgets/module_form_dialog.dart';
import 'package:mobile/shared_widgets/admin/base_admin_screen.dart';
import 'package:mobile/shared_widgets/admin/pagination_controls.dart';
import 'package:mobile/shared_widgets/admin/comfirm_delete_dialog.dart';
import 'package:provider/provider.dart';

class ManageModuleScreen extends StatefulWidget {
  final CourseModel course;
  const ManageModuleScreen({super.key, required this.course});

  @override
  State<ManageModuleScreen> createState() => _ManageModuleScreenState();
}

class _ManageModuleScreenState extends State<ManageModuleScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ManageModuleViewModel>().fetchModules(
        courseId: widget.course.id!,
      );
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
        context.read<ManageModuleViewModel>().applySearch(
          widget.course.id!,
          _searchController.text,
        );
      }
    });
  }

  void _showModuleForm(BuildContext context, {ModuleModel? module}) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (_) => ModuleFormDialog(module: module, courseId: widget.course.id!),
    );

    if (result == true && mounted) {
      await context.read<ManageModuleViewModel>().fetchModules(
        courseId: widget.course.id!,
      );
    }
  }

  void _confirmDelete(BuildContext context, ModuleModel module) {
    showDialog(
      context: context,
      builder:
          (_) => ConfirmDeleteDialog(
            title: 'Xác nhận xóa',
            content: 'Bạn có chắc muốn xóa chương "${module.title}"?',
            itemName: module.title,
            onConfirm: () async {
              await context.read<ManageModuleViewModel>().deleteModule(
                module.id,
                module.courseId,
              );
            },
          ),
    );
  }

  void _goToLessons(ModuleModel module) {
    final router = GoRouter.of(context);
    final currentLocation = GoRouterState.of(context).uri.toString();
    router.push('$currentLocation/${module.id}/lessons', extra: module);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ManageModuleViewModel>(
      builder: (context, viewModel, child) {
        final isLoading = viewModel.isLoading;

        return BaseAdminScreen(
          title: 'Quản lý Chương học',
          subtitle: 'Khóa học: ${widget.course.name}',
          headerIcon: Icons.view_module,
          addLabel: 'Thêm Chương',
          onAddPressed: () => _showModuleForm(context),
          onBackPressed: () => Navigator.of(context).pop(),
          searchController: _searchController,
          searchHint: 'Tìm kiếm chương...',
          isLoading: isLoading,
          totalCount: viewModel.totalCount,
          countLabel: 'chương',
          body: LayoutBuilder(
            builder: (context, constraints) {
              final double tableWidth =
                  constraints.maxWidth < 1000 ? 1000 : constraints.maxWidth;
              return ManageModuleContent(
                viewModel: viewModel,
                maxWidth: tableWidth,
                onEdit: (module) => _showModuleForm(context, module: module),
                onDelete: (module) => _confirmDelete(context, module),
                onManageLessons: (module) => _goToLessons(module),
              );
            },
          ),
          paginationControls: PaginationControls(
            currentPage: viewModel.currentPage,
            totalPages: viewModel.totalPages,
            totalCount: viewModel.totalCount,
            isLoading: isLoading,
            onPageChanged:
                (page) => viewModel.goToPage(widget.course.id!, page),
          ),
        );
      },
    );
  }
}
