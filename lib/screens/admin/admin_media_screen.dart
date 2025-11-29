import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mobile/data/models/media_file_model.dart';
import 'package:mobile/services/admin/admin_media_service.dart';
import 'package:mobile/shared_widgets/admin/action_icon_button.dart';
import 'package:mobile/shared_widgets/admin/base_admin_screen.dart';
import 'package:mobile/shared_widgets/admin/base_admin_table.dart';
import 'package:mobile/shared_widgets/admin/common_empty_state.dart';
import 'package:mobile/shared_widgets/admin/common_table_cell.dart';
import 'package:mobile/shared_widgets/admin/pagination_controls.dart';
import 'package:mobile/shared_widgets/admin/comfirm_delete_dialog.dart';
import 'package:mobile/utils/toast_helper.dart';
import 'package:provider/provider.dart';

class AdminMediaScreen extends StatefulWidget {
  const AdminMediaScreen({super.key});

  @override
  State<AdminMediaScreen> createState() => _AdminMediaScreenState();
}

class _AdminMediaScreenState extends State<AdminMediaScreen> {
  static const Color primaryBlue = Colors.blue;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch trang 1 khi vào màn hình
      context.read<AdminMediaService>().fetchMedia(refresh: true);
    });
  }

  // ✅ 1. Upload File
  Future<void> _pickAndUploadFile() async {
    final service = context.read<AdminMediaService>();
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'm4a'],
        withData: true, // Quan trọng cho Web
      );

      if (result != null) {
        // Nếu là Web: result.files.first.bytes != null
        // Nếu là Mobile: result.files.first.path != null
        await service.uploadAudio(result.files.first);
      }
    } catch (e) {
      ToastHelper.showError('Lỗi chọn file: $e');
    }
  }

  // ✅ 2. Copy Link
  void _copyToClipboard(String url) {
    Clipboard.setData(ClipboardData(text: url));
    ToastHelper.showSuccess('Đã sao chép link!');
  }

  // ✅ 3. Xóa File
  void _confirmDelete(MediaFileModel file) {
    showDialog(
      context: context,
      builder:
          (_) => ConfirmDeleteDialog(
            title: 'Xóa file media',
            content:
                'Bạn có chắc muốn xóa file "${file.fileName}"?\n(Cảnh báo: Nếu file đang dùng trong bài thi, bạn sẽ không thể xóa)',
            itemName: file.fileName,
            onConfirm: () async {
              await context.read<AdminMediaService>().deleteMedia(file.id);
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaService = context.watch<AdminMediaService>();
    final files = mediaService.files;
    final isLoading = mediaService.isLoading;

    // --- XÂY DỰNG BODY ---
    Widget bodyContent;
    if (isLoading && files.isEmpty) {
      bodyContent = const Center(
        child: CircularProgressIndicator(color: primaryBlue),
      );
    } else if (files.isEmpty) {
      bodyContent = const CommonEmptyState(
        icon: Icons.library_music_outlined,
        title: 'Thư viện trống',
        subtitle: 'Nhấn "Tải lên Audio" để thêm file mới',
      );
    } else {
      bodyContent = LayoutBuilder(
        builder:
            (context, constraints) =>
                _buildResponsiveTable(files, constraints.maxWidth),
      );
    }

    // --- SỬ DỤNG BaseAdminScreen ---
    return BaseAdminScreen(
      title: 'Thư viện Media',
      subtitle: 'Quản lý file âm thanh cho bài tập Listening',
      headerIcon: Icons.library_music_rounded,

      addLabel: 'Tải lên Audio',
      onAddPressed: _pickAndUploadFile, // Gọi hàm upload
      // Không có nút Back (vì nằm ở Menu chính)
      onBackPressed: null,

      // Media Service hiện tại chưa hỗ trợ search server-side (để đơn giản hóa)
      // Ta có thể ẩn thanh search hoặc thêm logic search client-side sau
      searchController: TextEditingController(),
      searchHint: 'Tìm kiếm file...',

      isLoading: isLoading,
      totalCount: mediaService.totalCount,
      countLabel: 'file',

      body: bodyContent,

      // Pagination
      paginationControls: PaginationControls(
        currentPage: mediaService.currentPage,
        totalPages: mediaService.totalPages,
        totalCount: mediaService.totalCount,
        isLoading: isLoading,
        onPageChanged: (page) {
          context.read<AdminMediaService>().goToPage(page);
        },
      ),
    );
  }

  // --- BẢNG DỮ LIỆU ---
  Widget _buildResponsiveTable(List<MediaFileModel> files, double maxWidth) {
    final colWidths = {
      0: maxWidth * 0.05, // STT
      1: maxWidth * 0.30, // Tên file
      2: maxWidth * 0.35, // URL (Dài nhất)
      3: maxWidth * 0.15, // Ngày tạo
      4: maxWidth * 0.15, // Hành động
    };

    final colHeaders = ['#', 'Tên file', 'Link (URL)', 'Ngày tạo', 'Hành động'];

    // Tính STT
    final int startingIndex =
        (context.read<AdminMediaService>().currentPage - 1) * 20;

    final dataRows =
        files.asMap().entries.map((entry) {
          final index = entry.key + startingIndex + 1;
          final file = entry.value;

          return TableRow(
            children: [
              // 1. STT
              CommonTableCell('$index', align: TextAlign.center, bold: true),

              // 2. Tên file
              CommonTableCell(
                file.fileName,
                bold: true,
                color: const Color(0xFF1E3A8A),
                align: TextAlign.left,
              ),

              // 3. URL (Cho phép copy nhanh)
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
                      onTap: () => _copyToClipboard(file.url),
                      child: const Icon(
                        Icons.copy,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              // 4. Ngày tạo
              CommonTableCell(
                DateFormat('dd/MM/yyyy HH:mm').format(file.createdAt.toLocal()),
                align: TextAlign.center,
                color: Colors.grey.shade700,
              ),

              // 5. Hành động
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Nút Copy (Dự phòng)
                    ActionIconButton(
                      icon: Icons.copy_all_rounded,
                      color: Colors.green,
                      tooltip: 'Sao chép Link',
                      onPressed: () => _copyToClipboard(file.url),
                    ),
                    const SizedBox(width: 8),

                    // Nút Xóa
                    ActionIconButton(
                      icon: Icons.delete_outline,
                      color: Colors.redAccent,
                      tooltip: 'Xóa file',
                      onPressed: () => _confirmDelete(file),
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
