import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/data/models/media_file_model.dart';
import 'package:mobile/screens/admin/manage_media/manage_media_view_model.dart';
import 'package:mobile/shared_widgets/admin/action_icon_button.dart';
import 'package:mobile/shared_widgets/admin/base_admin_table.dart';
import 'package:mobile/shared_widgets/admin/common_empty_state.dart';
import 'package:mobile/shared_widgets/admin/common_table_cell.dart';

class ManageMediaContent extends StatelessWidget {
  final ManageMediaViewModel viewModel;
  final Function(String) onCopyToClipboard;
  final Function(MediaFileModel) onConfirmDelete;

  const ManageMediaContent({
    super.key,
    required this.viewModel,
    required this.onCopyToClipboard,
    required this.onConfirmDelete,
    this.maxWidth = double.infinity,
  });

  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final files = viewModel.files;
    final isLoading = viewModel.isLoading;

    if (isLoading && files.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Colors.blue));
    } else if (files.isEmpty) {
      return const CommonEmptyState(
        icon: Icons.library_music_outlined,
        title: 'Thư viện trống',
        subtitle: 'Nhấn "Tải lên Audio" để thêm file mới',
      );
    } else {
      return _buildResponsiveTable(context, files, maxWidth);
    }
  }

  Widget _buildResponsiveTable(
    BuildContext context,
    List<MediaFileModel> files,
    double maxWidth,
  ) {
    final colWidths = {
      0: maxWidth * 0.05,
      1: maxWidth * 0.30,
      2: maxWidth * 0.35,
      3: maxWidth * 0.15,
      4: maxWidth * 0.15,
    };

    final colHeaders = ['#', 'Tên file', 'Link (URL)', 'Ngày tạo', 'Hành động'];

    final int startingIndex = (viewModel.currentPage - 1) * 20;

    final dataRows =
        files.asMap().entries.map((entry) {
          final index = entry.key + startingIndex + 1;
          final file = entry.value;

          return TableRow(
            children: [
              CommonTableCell('$index', align: TextAlign.center, bold: true),
              CommonTableCell(
                file.fileName,
                bold: true,
                color: const Color(0xFF1E3A8A),
                align: TextAlign.left,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        file.url,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.blue,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => onCopyToClipboard(file.url),
                      child: const Icon(
                        Icons.copy,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              CommonTableCell(
                DateFormat('dd/MM/yyyy HH:mm').format(file.createdAt.toLocal()),
                align: TextAlign.center,
                color: Colors.grey.shade700,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ActionIconButton(
                      icon: Icons.copy_all_rounded,
                      color: Colors.green,
                      tooltip: 'Sao chép Link',
                      onPressed: () => onCopyToClipboard(file.url),
                    ),
                    const SizedBox(width: 8),
                    ActionIconButton(
                      icon: Icons.delete_outline,
                      color: Colors.redAccent,
                      tooltip: 'Xóa file',
                      onPressed: () => onConfirmDelete(file),
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
