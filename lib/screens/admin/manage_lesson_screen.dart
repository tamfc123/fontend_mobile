import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/data/models/lesson_model.dart';
import 'package:mobile/data/models/module_model.dart';
import 'package:mobile/services/admin/admin_lesson_service.dart';
import 'package:mobile/widgets/admin/comfirm_delete_dialog.dart';
import 'package:mobile/widgets/admin/lesson_form_dialog.dart';
import 'package:provider/provider.dart';

class ManageLessonScreen extends StatefulWidget {
  final ModuleModel module;
  const ManageLessonScreen({super.key, required this.module});

  @override
  State<ManageLessonScreen> createState() => _ManageLessonScreenState();
}

class _ManageLessonScreenState extends State<ManageLessonScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // MÀU CHỦ ĐẠO (ĐỒNG NHẤT VỚI VOCAB)
  static const Color primaryBlue = Colors.blue;
  static const Color backgroundBlue = Color(0xFFF3F8FF);
  static const Color surfaceBlue = Color(0xFFE3F2FD);

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<AdminLessonService>().fetchLessons(widget.module.id),
    );
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showLessonForm({LessonModel? lesson}) async {
    final result = await showDialog<LessonModifyModel>(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => LessonFormDialog(lesson: lesson, moduleId: widget.module.id),
    );

    if (result != null) {
      final service = context.read<AdminLessonService>();
      if (lesson == null) {
        await service.addLesson(result);
      } else {
        await service.updateLesson(lesson.id, result);
      }
    }
  }

  void _confirmDelete(LessonModel lesson) {
    showDialog(
      context: context,
      builder:
          (_) => ConfirmDeleteDialog(
            title: 'Xác nhận xóa',
            content: 'Bạn có chắc muốn xóa bài học "${lesson.title}"?',
            itemName: lesson.title,
            onConfirm: () async {
              await context.read<AdminLessonService>().deleteLesson(
                lesson.id,
                lesson.moduleId,
              );
            },
          ),
    );
  }

  void _goToVocabulary(LessonModel lesson) {
    final router = GoRouter.of(context);
    final currentLocation = GoRouterState.of(context).uri.toString();
    router.push('$currentLocation/${lesson.id}/vocabularies', extra: lesson);
  }

  @override
  Widget build(BuildContext context) {
    final lessonService = context.watch<AdminLessonService>();
    final lessons = lessonService.lessons;

    final filteredLessons =
        lessons.where((l) {
          return l.title.toLowerCase().contains(_searchQuery) ||
              (l.content?.toLowerCase().contains(_searchQuery) ?? false);
        }).toList();

    return Scaffold(
      backgroundColor: backgroundBlue,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === HEADER + BACK + TÌM KIẾM ===
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
                            // NÚT QUAY LẠI
                            ElevatedButton.icon(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(
                                Icons.arrow_back_ios_new,
                                size: 18,
                              ),
                              label: const Text(
                                'Quay lại',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryBlue,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),

                            // ICON + TIÊU ĐỀ
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: surfaceBlue,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.school,
                                color: primaryBlue,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Quản lý Bài học',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E3A8A),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Chương: ${widget.module.title}',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),

                            // NÚT THÊM
                            ElevatedButton.icon(
                              onPressed: () => _showLessonForm(),
                              icon: const Icon(
                                Icons.add_circle_outline,
                                size: 20,
                              ),
                              label: const Text(
                                'Thêm Bài học',
                                style: TextStyle(
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

                      // THANH TÌM KIẾM
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: surfaceBlue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Tìm kiếm bài học, nội dung...',
                              hintStyle: TextStyle(color: Colors.grey.shade600),
                              prefixIcon: Icon(
                                Icons.search,
                                color: primaryBlue,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // === BẢNG BÀI HỌC ===
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Container(
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
                              lessonService.isLoading
                                  ? const Center(
                                    child: CircularProgressIndicator(
                                      color: primaryBlue,
                                    ),
                                  )
                                  : filteredLessons.isEmpty
                                  ? _buildEmptyState()
                                  : _buildResponsiveTable(
                                    filteredLessons,
                                    constraints.maxWidth,
                                  ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book_outlined, size: 72, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? 'Chưa có bài học nào'
                : 'Không tìm thấy bài học',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'Nhấn "Thêm Bài học" để bắt đầu'
                : 'Thử tìm kiếm bằng từ khóa khác',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveTable(List<LessonModel> lessons, double maxWidth) {
    final colWidths = {
      0: maxWidth * 0.07, // STT
      1: maxWidth * 0.28, // Tiêu đề
      2: maxWidth * 0.30, // Trạng thái nội dung
      3: maxWidth * 0.35, // Hành động
    };

    return SingleChildScrollView(
      child: IntrinsicWidth(
        child: Table(
          columnWidths: colWidths.map(
            (key, value) => MapEntry(key, FixedColumnWidth(value)),
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
                  ['STT', 'Tiêu đề', 'Nội dung', 'Hành động']
                      .map(
                        (title) => Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            title,
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
            ...lessons.asMap().entries.map((entry) {
              final index = entry.key + 1;
              final lesson = entry.value;
              final hasContent = (lesson.content ?? '').isNotEmpty;
              return TableRow(
                children: [
                  _buildCell('$index', align: TextAlign.center, bold: true),
                  _buildCell(
                    lesson.title,
                    bold: true,
                    color: const Color(0xFF1E3A8A),
                  ),
                  _buildCell(
                    hasContent
                        ? 'Đã có nội dung bài giảng'
                        : 'Chưa có nội dung',
                    color:
                        hasContent
                            ? Colors.green.shade700
                            : Colors.grey.shade600,
                    italic: true,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildActionButton(
                          Icons.font_download_rounded,
                          Colors.purple.shade600,
                          'Quản lý Từ vựng',
                          () => _goToVocabulary(lesson),
                        ),
                        const SizedBox(width: 12),
                        _buildActionButton(
                          Icons.edit_document,
                          Colors.orange.shade600,
                          'Sửa nội dung',
                          () => _showLessonForm(lesson: lesson),
                        ),
                        const SizedBox(width: 12),
                        _buildActionButton(
                          Icons.delete,
                          Colors.redAccent,
                          'Xóa',
                          () => _confirmDelete(lesson),
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

  Widget _buildCell(
    dynamic content, {
    TextAlign align = TextAlign.left,
    bool bold = false,
    Color? color,
    bool italic = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child:
          content is Widget
              ? content
              : Text(
                content.toString(),
                style: TextStyle(
                  fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
                  fontStyle: italic ? FontStyle.italic : FontStyle.normal,
                  color: color ?? Colors.black87,
                  fontSize: 14.5,
                ),
                textAlign: align,
              ),
    );
  }

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
