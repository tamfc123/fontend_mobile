import 'dart:async';
import 'package:mobile/shared_widgets/admin/comfirm_delete_dialog.dart';
import 'package:flutter/material.dart';
import 'package:mobile/data/models/class_model.dart';
import 'package:mobile/services/admin/admin_class_service.dart';
import 'package:mobile/services/admin/admin_course_service.dart';
import 'package:mobile/services/admin/admin_user_service.dart';
import 'package:mobile/shared_widgets/admin/base_admin_screen.dart';
import 'package:mobile/shared_widgets/admin/base_admin_table.dart';
import 'package:mobile/shared_widgets/admin/pagination_controls.dart';
import 'package:mobile/shared_widgets/admin/common_empty_state.dart';
import 'package:mobile/shared_widgets/admin/action_icon_button.dart';
import 'package:mobile/shared_widgets/admin/common_table_cell.dart';
import 'package:mobile/widgets/admin/class_form_dialog.dart';
import 'package:provider/provider.dart';

class ManageClassScreen extends StatefulWidget {
  const ManageClassScreen({super.key});

  @override
  State<ManageClassScreen> createState() => _ManageClassScreenState();
}

class _ManageClassScreenState extends State<ManageClassScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  // MÀU CHỦ ĐẠO
  static const Color primaryBlue = Colors.blue;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final classService = context.read<AdminClassService>();
      final userService = context.read<AdminUserService>();
      final courseService = context.read<AdminCourseService>();

      _searchController.text = classService.searchQuery ?? '';

      // Tải dữ liệu lần đầu
      // (logic fetch 3 service này là đặc thù của màn hình, nên giữ lại)
      Future.wait([
        classService.fetchClasses(),
        userService.fetchTeachers(),
        courseService.fetchCourses(),
      ]);
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
        context.read<AdminClassService>().applySearch(_searchController.text);
      }
    });
  }

  // (Các hàm _showAddOrEditDialog, _confirmDelete giữ nguyên)
  void _showAddOrEditDialog({ClassModel? clazz}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => ClassFormDialog(classModel: clazz),
    );
    if (result == true && mounted) {
      await context.read<AdminClassService>().fetchClasses();
    }
  }

  void _confirmDelete(ClassModel clazz) {
    showDialog(
      context: context,
      builder:
          (_) => ConfirmDeleteDialog(
            title: 'Xác nhận xóa',
            content: 'Bạn có chắc muốn xóa lớp học "${clazz.name}"?',
            itemName: clazz.name,
            onConfirm: () async {
              await context.read<AdminClassService>().deleteClass(clazz.id);
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final classService = context.watch<AdminClassService>();
    final classes = classService.classes;
    final isLoading = classService.isLoading;

    // ✅ 3. XÂY DỰNG BODYCONTENT
    Widget bodyContent;
    if (isLoading && classes.isEmpty) {
      bodyContent = const Center(
        child: CircularProgressIndicator(color: primaryBlue),
      );
    } else if (classes.isEmpty) {
      bodyContent = _buildEmptyState(classService.searchQuery);
    } else {
      bodyContent = LayoutBuilder(
        builder:
            (context, constraints) =>
                _buildResponsiveTable(classes, constraints.maxWidth),
      );
    }

    // ✅ 4. SỬ DỤNG BaseAdminScreen
    return BaseAdminScreen(
      title: 'Quản lý Lớp học',
      subtitle: 'Tất cả lớp học trong hệ thống',
      headerIcon: Icons.class_,
      addLabel: 'Thêm Lớp học',
      onAddPressed: () => _showAddOrEditDialog(),
      onBackPressed: null, // 👈 Không có nút Back

      searchController: _searchController,
      searchHint: 'Tìm kiếm theo tên lớp...',
      isLoading: isLoading,
      totalCount: classService.totalCount,
      countLabel: 'Lớp', // 👈 Sửa label

      body: bodyContent,

      paginationControls: PaginationControls(
        currentPage: classService.currentPage,
        totalPages: classService.totalPages,
        totalCount: classService.totalCount,
        isLoading: isLoading,
        onPageChanged: (page) {
          // 👈 Service này dùng hàm goToPage
          context.read<AdminClassService>().goToPage(page);
        },
      ),
    );
  }

  // ✅ 5. SỬ DỤNG CommonEmptyState
  Widget _buildEmptyState(String? searchQuery) {
    bool isSearching = searchQuery != null && searchQuery.isNotEmpty;
    return CommonEmptyState(
      icon: Icons.class_outlined,
      title: isSearching ? 'Không tìm thấy lớp học' : 'Chưa có lớp học nào',
      subtitle:
          isSearching
              ? 'Thử tìm kiếm bằng từ khóa khác'
              : 'Nhấn "Thêm Lớp học" để bắt đầu',
    );
  }

  // ✅ 6. SỬ DỤNG BaseAdminTable
  Widget _buildResponsiveTable(List<ClassModel> classes, double maxWidth) {
    final colWidths = {
      0: maxWidth * 0.30,
      1: maxWidth * 0.30,
      2: maxWidth * 0.25,
      3: maxWidth * 0.15,
    };
    final colHeaders = ['Tên lớp', 'Khóa học', 'Giảng viên', 'Hành động'];

    // Tạo các dòng dữ liệu
    final dataRows =
        classes.map((clazz) {
          return TableRow(
            children: [
              // ✅ 7. SỬ DỤNG CommonTableCell
              CommonTableCell(
                clazz.name,
                bold: true,
                color: const Color(0xFF1E3A8A),
                align: TextAlign.center,
              ),
              CommonTableCell(
                clazz.courseName,
                color: Colors.grey.shade700,
                align: TextAlign.center,
              ),
              CommonTableCell(
                clazz.teacherName ?? 'Chưa có',
                color: Colors.green.shade700,
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
                      onPressed: () => _showAddOrEditDialog(clazz: clazz),
                    ),
                    const SizedBox(width: 12),
                    ActionIconButton(
                      icon: Icons.delete,
                      color: Colors.redAccent,
                      tooltip: 'Xóa',
                      onPressed: () => _confirmDelete(clazz),
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
