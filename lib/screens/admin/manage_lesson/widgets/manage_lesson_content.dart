import 'package:flutter/material.dart';
import 'package:mobile/data/models/lesson_model.dart';
import 'package:mobile/screens/admin/manage_lesson/manage_lesson_view_model.dart';
import 'package:mobile/shared_widgets/admin/action_icon_button.dart';
import 'package:mobile/shared_widgets/admin/base_admin_table.dart';
import 'package:mobile/shared_widgets/admin/common_empty_state.dart';
import 'package:mobile/shared_widgets/admin/common_table_cell.dart';

class ManageLessonContent extends StatelessWidget {
  final ManageLessonViewModel viewModel;
  final Function(LessonModel) onEdit;
  final Function(LessonModel) onDelete;
  final Function(LessonModel) onManageVocabulary;

  const ManageLessonContent({
    super.key,
    required this.viewModel,
    required this.onEdit,
    required this.onDelete,
    required this.onManageVocabulary,
    this.maxWidth = double.infinity,
  });

  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final lessons = viewModel.lessons;
    final isLoading = viewModel.isLoading;

    if (isLoading && lessons.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    } else if (lessons.isEmpty) {
      return _buildEmptyState(viewModel.searchQuery);
    } else {
      return _buildResponsiveTable(context, lessons, maxWidth);
    }
  }

  Widget _buildEmptyState(String? searchQuery) {
    bool isSearching = searchQuery != null && searchQuery.isNotEmpty;
    return CommonEmptyState(
      icon: Icons.menu_book_outlined,
      title: isSearching ? 'Không tìm thấy bài học' : 'Chưa có bài học nào',
      subtitle:
          isSearching
              ? 'Thử tìm kiếm bằng từ khóa khác'
              : 'Nhấn "Thêm Bài học" để bắt đầu',
    );
  }

  Widget _buildResponsiveTable(
    BuildContext context,
    List<LessonModel> lessons,
    double maxWidth,
  ) {
    final colWidths = {
      0: maxWidth * 0.07,
      1: maxWidth * 0.28,
      2: maxWidth * 0.30,
      3: maxWidth * 0.35,
    };
    final colHeaders = ['STT', 'Tiêu đề', 'Nội dung', 'Hành động'];

    final int startingIndex = (viewModel.currentPage - 1) * 5;

    final dataRows =
        lessons.asMap().entries.map((entry) {
          final index = entry.key + startingIndex + 1;
          final lesson = entry.value;
          final hasContent = lesson.hasContent;
          return TableRow(
            children: [
              CommonTableCell('$index', align: TextAlign.center, bold: true),
              CommonTableCell(
                lesson.title,
                bold: true,
                color: const Color(0xFF1E3A8A),
              ),
              CommonTableCell(
                hasContent ? 'Đã có nội dung' : 'Chưa có nội dung',
                color:
                    hasContent ? Colors.green.shade700 : Colors.grey.shade600,
                italic: true,
                align: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ActionIconButton(
                      icon: Icons.font_download_rounded,
                      color: Colors.purple.shade600,
                      tooltip: 'Quản lý Từ vựng',
                      onPressed: () => onManageVocabulary(lesson),
                    ),
                    const SizedBox(width: 12),
                    ActionIconButton(
                      icon: Icons.edit_document,
                      color: Colors.orange.shade600,
                      tooltip: 'Sửa nội dung',
                      onPressed: () => onEdit(lesson),
                    ),
                    const SizedBox(width: 12),
                    ActionIconButton(
                      icon: Icons.delete,
                      color: Colors.redAccent,
                      tooltip: 'Xóa',
                      onPressed: () => onDelete(lesson),
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
