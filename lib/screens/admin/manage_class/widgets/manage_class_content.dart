import 'package:flutter/material.dart';
import 'package:mobile/data/models/class_model.dart';
import 'package:mobile/screens/admin/manage_class/manage_class_view_model.dart';
import 'package:mobile/shared_widgets/admin/action_icon_button.dart';
import 'package:mobile/shared_widgets/admin/base_admin_table.dart';
import 'package:mobile/shared_widgets/admin/common_empty_state.dart';
import 'package:mobile/shared_widgets/admin/common_table_cell.dart';

class ManageClassContent extends StatefulWidget {
  final ManageClassViewModel viewModel;
  final TextEditingController searchController;
  final Function(ClassModel) onEdit;
  final Function(ClassModel) onDelete;

  const ManageClassContent({
    super.key,
    required this.viewModel,
    required this.searchController,
    required this.onEdit,
    required this.onDelete,
    this.maxWidth = double.infinity,
  });

  final double maxWidth;

  @override
  State<ManageClassContent> createState() => _ManageClassContentState();
}

class _ManageClassContentState extends State<ManageClassContent> {
  @override
  void initState() {
    super.initState();
    widget.searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    widget.searchController.removeListener(_onSearchChanged);
    super.dispose();
  }

  void _onSearchChanged() {
    widget.viewModel.onSearchChanged(widget.searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.viewModel.isLoading && widget.viewModel.classes.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Colors.blue));
    } else if (widget.viewModel.classes.isEmpty) {
      return _buildEmptyState(widget.viewModel.searchQuery);
    } else {
      return _buildResponsiveTable(
        context,
        widget.viewModel.classes,
        widget.maxWidth,
      );
    }
  }

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

  Widget _buildResponsiveTable(
    BuildContext context,
    List<ClassModel> classes,
    double maxWidth,
  ) {
    final colWidths = {
      0: maxWidth * 0.30,
      1: maxWidth * 0.30,
      2: maxWidth * 0.25,
      3: maxWidth * 0.15,
    };
    final colHeaders = ['Tên lớp', 'Khóa học', 'Giảng viên', 'Hành động'];

    final dataRows =
        classes.map((clazz) {
          return TableRow(
            children: [
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
                    ActionIconButton(
                      icon: Icons.edit,
                      color: Colors.orange.shade600,
                      tooltip: 'Chỉnh sửa',
                      onPressed: () => widget.onEdit(clazz),
                    ),
                    const SizedBox(width: 12),
                    ActionIconButton(
                      icon: Icons.delete,
                      color: Colors.redAccent,
                      tooltip: 'Xóa',
                      onPressed: () => widget.onDelete(clazz),
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
