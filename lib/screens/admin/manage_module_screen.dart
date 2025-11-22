import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/data/models/course_model.dart';
import 'package:mobile/data/models/module_model.dart';
import 'package:mobile/services/admin/admin_module_service.dart';
import 'package:mobile/shared_widgets/admin/action_icon_button.dart';
import 'package:mobile/shared_widgets/admin/base_admin_screen.dart';
import 'package:mobile/shared_widgets/admin/base_admin_table.dart';
import 'package:mobile/shared_widgets/admin/common_empty_state.dart';
import 'package:mobile/shared_widgets/admin/common_table_cell.dart';
import 'package:mobile/shared_widgets/admin/pagination_controls.dart';
import 'package:mobile/shared_widgets/comfirm_delete_dialog.dart';
import 'package:mobile/widgets/admin/module_form_dialog.dart';
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
    final moduleService = context.read<AdminModuleService>();
    _searchController.text = moduleService.currentSearchQuery ?? '';

    Future.microtask(() => _triggerFetch(pageNumber: 1));
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        _triggerFetch(pageNumber: 1);
      }
    });
  }

  void _triggerFetch({int? pageNumber}) {
    final service = context.read<AdminModuleService>();
    final page = pageNumber ?? service.currentPage;
    final search = _searchController.text;

    service.fetchModules(
      courseId: widget.course.id!,
      pageNumber: page,
      searchQuery: search,
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _showModuleForm({ModuleModel? module}) async {
    final result = await showDialog<ModuleModel>(
      context: context,
      builder:
          (_) => ModuleFormDialog(module: module, courseId: widget.course.id!),
    );

    if (result != null) {
      final service = context.read<AdminModuleService>();
      if (module == null) {
        final createDto = ModuleCreateModel(
          courseId: result.courseId,
          title: result.title,
          description: result.description,
        );
        await service.addModule(createDto);
      } else {
        await service.updateModule(result.id, result);
      }
    }
  }

  void _confirmDelete(ModuleModel module) {
    showDialog(
      context: context,
      builder:
          (_) => ConfirmDeleteDialog(
            title: 'Xác nhận xóa',
            content: 'Bạn có chắc muốn xóa chương "${module.title}"?',
            itemName: module.title,
            onConfirm: () async {
              await context.read<AdminModuleService>().deleteModule(
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
    final moduleService = context.watch<AdminModuleService>();
    final modules = moduleService.modules;
    final isLoading = moduleService.isLoading;

    Widget bodyContent;
    if (isLoading && modules.isEmpty) {
      bodyContent = const Center(child: CircularProgressIndicator());
    } else if (modules.isEmpty) {
      // ✅ 3. SỬ DỤNG CommonEmptyState
      bodyContent = _buildEmptyState(moduleService.currentSearchQuery);
    } else {
      bodyContent = LayoutBuilder(
        builder:
            (context, constraints) =>
                _buildResponsiveTable(modules, constraints.maxWidth),
      );
    }

    return BaseAdminScreen(
      // ... (Tất cả props của BaseAdminScreen giữ nguyên)
      title: 'Quản lý Chương',
      subtitle: 'Khóa học: ${widget.course.name}',
      headerIcon: Icons.folder_open,
      addLabel: 'Thêm Chương',
      onAddPressed: () => _showModuleForm(),
      onBackPressed: () => Navigator.of(context).pop(),
      searchController: _searchController,
      searchHint: 'Tìm kiếm chương, mô tả...',
      isLoading: isLoading,
      totalCount: moduleService.totalCount,
      countLabel: 'chương',
      body: bodyContent,
      paginationControls: PaginationControls(
        currentPage: moduleService.currentPage,
        totalPages: moduleService.totalPages,
        totalCount: moduleService.totalCount,
        isLoading: isLoading,
        onPageChanged: (page) => _triggerFetch(pageNumber: page),
      ),
    );
  }

  Widget _buildEmptyState(String? searchQuery) {
    bool isSearching = searchQuery != null && searchQuery.isNotEmpty;
    return CommonEmptyState(
      icon: Icons.folder_outlined,
      title: isSearching ? 'Không tìm thấy chương' : 'Chưa có chương nào',
      subtitle:
          isSearching
              ? 'Thử tìm kiếm bằng từ khóa khác'
              : 'Nhấn "Thêm Chương" để bắt đầu',
    );
  }

  // ✅ SỬA HÀM TẠO BẢNG (để tính STT)
  Widget _buildResponsiveTable(List<ModuleModel> modules, double maxWidth) {
    final colWidths = {
      0: maxWidth * 0.07,
      1: maxWidth * 0.28,
      2: maxWidth * 0.30,
      3: maxWidth * 0.35,
    };
    final colHeaders = ['STT', 'Tên Chương', 'Mô tả', 'Hành động'];

    final int startingIndex =
        (context.read<AdminModuleService>().currentPage - 1) * 5;

    // Chỉ tạo các dòng dữ liệu
    final dataRows =
        modules.asMap().entries.map((entry) {
          final index = entry.key + startingIndex + 1;
          final module = entry.value;
          return TableRow(
            children: [
              // ✅ 6. SỬ DỤNG CommonTableCell
              CommonTableCell('$index', align: TextAlign.center, bold: true),
              CommonTableCell(
                module.title,
                bold: true,
                color: const Color(0xFF1E3A8A),
              ),
              CommonTableCell(
                module.description ?? 'Không có mô tả',
                color: Colors.grey.shade700,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ✅ 7. SỬ DỤNG ActionIconButton
                    ActionIconButton(
                      icon: Icons.list_alt,
                      color: Colors.green.shade600,
                      tooltip: 'Quản lý Bài học',
                      onPressed: () => _goToLessons(module),
                    ),
                    const SizedBox(width: 12),
                    ActionIconButton(
                      icon: Icons.edit,
                      color: Colors.orange.shade600,
                      tooltip: 'Sửa',
                      onPressed: () => _showModuleForm(module: module),
                    ),
                    const SizedBox(width: 12),
                    ActionIconButton(
                      icon: Icons.delete,
                      color: Colors.redAccent,
                      tooltip: 'Xóa',
                      onPressed: () => _confirmDelete(module),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList();

    // Truyền vào BaseAdminTable
    return BaseAdminTable(
      columnWidths: colWidths.map((k, v) => MapEntry(k, FixedColumnWidth(v))),
      columnHeaders: colHeaders,
      dataRows: dataRows,
    );
  }
}
