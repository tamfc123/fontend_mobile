import 'package:flutter/material.dart';
import 'package:mobile/data/models/module_model.dart';
import 'package:mobile/screens/admin/manage_module/manage_module_view_model.dart';
import 'package:mobile/shared_widgets/admin/action_icon_button.dart';
import 'package:mobile/shared_widgets/admin/base_admin_table.dart';
import 'package:mobile/shared_widgets/admin/common_empty_state.dart';
import 'package:mobile/shared_widgets/admin/common_table_cell.dart';

class ManageModuleContent extends StatelessWidget {
  final ManageModuleViewModel viewModel;
  final Function(ModuleModel) onEdit;
  final Function(ModuleModel) onDelete;
  final Function(ModuleModel) onManageLessons;

  const ManageModuleContent({
    super.key,
    required this.viewModel,
    required this.onEdit,
    required this.onDelete,
    required this.onManageLessons,
    this.maxWidth = double.infinity,
  });

  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final modules = viewModel.modules;
    final isLoading = viewModel.isLoading;

    if (isLoading && modules.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    } else if (modules.isEmpty) {
      return _buildEmptyState(viewModel.searchQuery);
    } else {
      return _buildResponsiveTable(context, modules, maxWidth);
    }
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

  Widget _buildResponsiveTable(
    BuildContext context,
    List<ModuleModel> modules,
    double maxWidth,
  ) {
    final colWidths = {
      0: maxWidth * 0.07,
      1: maxWidth * 0.28,
      2: maxWidth * 0.30,
      3: maxWidth * 0.35,
    };
    final colHeaders = ['STT', 'Tên Chương', 'Mô tả', 'Hành động'];

    final int startingIndex = (viewModel.currentPage - 1) * 5;

    final dataRows =
        modules.asMap().entries.map((entry) {
          final index = entry.key + startingIndex + 1;
          final module = entry.value;
          return TableRow(
            children: [
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
                    ActionIconButton(
                      icon: Icons.list_alt,
                      color: Colors.green.shade600,
                      tooltip: 'Quản lý Bài học',
                      onPressed: () => onManageLessons(module),
                    ),
                    const SizedBox(width: 12),
                    ActionIconButton(
                      icon: Icons.edit,
                      color: Colors.orange.shade600,
                      tooltip: 'Sửa',
                      onPressed: () => onEdit(module),
                    ),
                    const SizedBox(width: 12),
                    ActionIconButton(
                      icon: Icons.delete,
                      color: Colors.redAccent,
                      tooltip: 'Xóa',
                      onPressed: () => onDelete(module),
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
