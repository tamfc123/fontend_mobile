import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Cho Clipboard
import 'package:intl/intl.dart'; // 👈 THÊM: Để format ngày
import 'package:mobile/data/models/media_file_model.dart'; // 👈 THÊM: Model media
import 'package:mobile/services/teacher/teacher_media_service.dart';
import 'package:mobile/shared_widgets/comfirm_delete_dialog.dart';
import 'package:mobile/utils/toast_helper.dart';
import 'package:provider/provider.dart';

class TeacherMediaScreen extends StatefulWidget {
  const TeacherMediaScreen({super.key});

  @override
  State<TeacherMediaScreen> createState() => _TeacherMediaScreenState();
}

class _TeacherMediaScreenState extends State<TeacherMediaScreen> {
  late TextEditingController _searchController;
  Timer? _debounce;

  // MÀU CHỦ ĐẠO (Copy từ template của bạn)
  static const Color primaryBlue = Colors.blue;
  static const Color backgroundBlue = Color(0xFFF3F8FF);
  static const Color surfaceBlue = Color(0xFFE3F2FD);

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    // Lắng nghe để lọc danh sách (filter local)
    _searchController.addListener(_onSearchChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeacherMediaService>().fetchMyMedia();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // Hàm debounce để lọc local (không gọi API)
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          // Chỉ cần build lại, logic lọc nằm trong hàm build()
        });
      }
    });
  }

  // Hàm xử lý Upload (từ code cũ của bạn)
  Future<void> _pickAndUploadFile(BuildContext context) async {
    final service = context.read<TeacherMediaService>();
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'm4a'],
        withData: true,
      );
      if (result != null && result.files.first.bytes != null) {
        await service.uploadAudioFile(result.files.first);
      } else {
        ToastHelper.showError("Đã hủy chọn file hoặc file không hợp lệ.");
      }
    } catch (e) {
      ToastHelper.showError('Lỗi khi chọn file: $e');
    }
  }

  // Hàm copy (từ code cũ)
  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ToastHelper.showSuccess('Đã sao chép link!');
  }

  void _confirmDelete(MediaFileModel file) {
    showDialog(
      context: context,
      builder:
          (_) => ConfirmDeleteDialog(
            title: 'Xác nhận xóa',
            content: 'Bạn có chắc muốn xóa file "${file.fileName}"?',
            onConfirm: () async {
              await context.read<TeacherMediaService>().deleteMediaFile(
                file.id,
              );
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<TeacherMediaService>();

    // ✅ LỌC LOCAL (Client-side filtering)
    final allFiles = service.mediaFiles;
    final searchQuery = _searchController.text.toLowerCase();
    final filteredFiles =
        allFiles.where((file) {
          return file.fileName.toLowerCase().contains(searchQuery) ||
              file.url.toLowerCase().contains(searchQuery);
        }).toList();

    final isLoading = service.isLoading;

    return Scaffold(
      backgroundColor: backgroundBlue,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1600),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === HEADER (GIỐNG TEMPLATE) ===
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // HEADER ROW
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                        child: Row(
                          children: [
                            // ICON + TIÊU ĐỀ
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: surfaceBlue,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.library_music_rounded, // 👈 ICON MỚI
                                color: primaryBlue,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Thư viện Media', // 👈 TIÊU ĐỀ MỚI
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E3A8A),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Quản lý file âm thanh cho bài tập', // 👈 MÔ TẢ MỚI
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // NÚT UPLOAD (NÚT HÀNH ĐỘNG CHÍNH)
                            ElevatedButton.icon(
                              onPressed:
                                  isLoading
                                      ? null
                                      : () => _pickAndUploadFile(context),
                              icon:
                                  isLoading
                                      ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                      : const Icon(
                                        Icons.upload_file_rounded,
                                        size: 20,
                                      ),
                              label: Text(
                                isLoading ? 'Đang xử lý...' : 'Tải lên Audio',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryBlue,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 22,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // TÌM KIẾM + STATS
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                        child: Column(
                          children: [
                            // TÌM KIẾM
                            Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: surfaceBlue,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: 'Tìm kiếm theo tên file...',
                                  hintStyle: TextStyle(
                                    color: Colors.grey.shade600,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.search,
                                    color: primaryBlue,
                                  ),
                                  suffixIcon:
                                      _searchController.text.isNotEmpty
                                          ? IconButton(
                                            icon: Icon(
                                              Icons.clear,
                                              color: Colors.grey.shade600,
                                            ),
                                            onPressed: () {
                                              _searchController.clear();
                                              // _onSearchChanged() sẽ được gọi
                                            },
                                          )
                                          : null,
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // STATS
                            if (!isLoading && filteredFiles.isNotEmpty)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Tìm thấy ${filteredFiles.length} file media",
                                  style: const TextStyle(
                                    color: primaryBlue,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // === BẢNG NỘI DUNG (GIỐNG TEMPLATE) ===
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child:
                          isLoading && filteredFiles.isEmpty
                              ? const Center(
                                child: CircularProgressIndicator(
                                  color: primaryBlue,
                                ),
                              )
                              : filteredFiles.isEmpty
                              ? _buildEmptyState() // 👈 Widget rỗng
                              : LayoutBuilder(
                                builder: (context, constraints) {
                                  return SingleChildScrollView(
                                    child: _buildResponsiveTable(
                                      context,
                                      filteredFiles,
                                      constraints.maxWidth,
                                    ),
                                  );
                                },
                              ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Widget hiển thị khi không có file nào
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.audio_file_outlined,
            size: 72,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'Thư viện media trống',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Hãy tải lên file audio đầu tiên của bạn',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// Widget bảng (Copy từ template và sửa lại cột)
  Widget _buildResponsiveTable(
    BuildContext context,
    List<MediaFileModel> files,
    double maxWidth,
  ) {
    // ✅ CỘT MỚI
    final colWidths = {
      0: maxWidth * 0.35, // Tên file
      1: maxWidth * 0.40, // URL
      2: maxWidth * 0.25, // Thao tác
    };

    return SingleChildScrollView(
      child: IntrinsicWidth(
        child: Table(
          columnWidths: colWidths.map(
            (k, v) => MapEntry(k, FixedColumnWidth(v)),
          ),
          border: TableBorder(
            bottom: BorderSide(color: surfaceBlue),
            horizontalInside: BorderSide(
              color: Colors.grey.shade200,
              width: 0.5,
            ),
          ),
          children: [
            // Header
            TableRow(
              decoration: BoxDecoration(color: surfaceBlue),
              children:
                  ['Tên file', 'URL (Link)', 'Thao tác'] // ✅ CỘT MỚI
                      .map(
                        (t) => Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            t,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: primaryBlue,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                      .toList(),
            ),
            // Rows
            ...files.map((file) {
              return TableRow(
                children: [
                  // Tên file
                  _buildCell(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          file.fileName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E3A8A),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ngày tạo: ${DateFormat('dd/MM/yyyy').format(file.createdAt.toLocal())}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                    align: TextAlign.left,
                  ),
                  // URL
                  _buildCell(
                    Text(
                      file.url,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.blue,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    align: TextAlign.left,
                  ),
                  // Thao tác
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildActionButton(
                          Icons.copy_all_rounded,
                          primaryBlue,
                          'Sao chép link',
                          () => _copyToClipboard(context, file.url),
                        ),
                        const SizedBox(width: 12),
                        _buildActionButton(
                          Icons.delete,
                          Colors.redAccent,
                          'Xóa file',
                          () => _confirmDelete(file),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  /// Helper (Copy từ template)
  Widget _buildCell(
    dynamic content, {
    TextAlign align = TextAlign.left,
    bool bold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child:
          content is Widget
              ? content
              : Text(
                content.toString(),
                style: TextStyle(
                  fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
                  color: color ?? Colors.black87,
                  fontSize: 14,
                ),
                textAlign: align,
                overflow: TextOverflow.ellipsis,
              ),
    );
  }

  /// Helper (Copy từ template)
  Widget _buildActionButton(
    IconData icon,
    Color color,
    String tooltip,
    VoidCallback onPressed,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 22),
        tooltip: tooltip,
        onPressed: onPressed,
        padding: const EdgeInsets.all(10),
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      ),
    );
  }
}
