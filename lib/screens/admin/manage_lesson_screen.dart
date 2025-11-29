import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/data/models/lesson_model.dart';
import 'package:mobile/data/models/module_model.dart';
import 'package:mobile/services/admin/admin_lesson_service.dart';
import 'package:mobile/shared_widgets/admin/base_admin_screen.dart';
import 'package:mobile/shared_widgets/admin/base_admin_table.dart';
import 'package:mobile/shared_widgets/admin/pagination_controls.dart';
import 'package:mobile/shared_widgets/admin/common_empty_state.dart';
import 'package:mobile/shared_widgets/admin/action_icon_button.dart';
import 'package:mobile/shared_widgets/admin/common_table_cell.dart';
import 'package:mobile/shared_widgets/admin/comfirm_delete_dialog.dart';
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
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    final lessonService = context.read<AdminLessonService>();
    _searchController.text = lessonService.currentSearchQuery ?? '';
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
    final service = context.read<AdminLessonService>();
    final page = pageNumber ?? service.currentPage;
    final search = _searchController.text;
    service.fetchLessons(
      moduleId: widget.module.id,
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

  // (Hàm _showLessonForm, _confirmDelete, _goToVocabulary giữ nguyên)
  void _showLessonForm({LessonModel? lesson}) async {
    final result = await showDialog<LessonModifyModel>(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => LessonFormDialog(
            // ✅ 3. SỬA LẠI CHỖ NÀY
            // Truyền ID nếu là SỬA, truyền null nếu là THÊM
            lessonId: lesson?.id,
            moduleId: widget.module.id,
          ),
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
    final isLoading = lessonService.isLoading;

    // ✅ 3. XÂY DỰNG BODYCONTENT
    Widget bodyContent;
    if (isLoading && lessons.isEmpty) {
      bodyContent = const Center(child: CircularProgressIndicator());
    } else if (lessons.isEmpty) {
      bodyContent = _buildEmptyState(lessonService.currentSearchQuery);
    } else {
      bodyContent = LayoutBuilder(
        builder:
            (context, constraints) =>
                _buildResponsiveTable(lessons, constraints.maxWidth),
      );
    }

    // ✅ 4. SỬ DỤNG BaseAdminScreen
    return BaseAdminScreen(
      title: 'Quản lý Bài học',
      subtitle: 'Chương: ${widget.module.title}',
      headerIcon: Icons.school,
      addLabel: 'Thêm Bài học',
      onAddPressed: () => _showLessonForm(),
      onBackPressed: () => Navigator.of(context).pop(),
      searchController: _searchController,
      searchHint: 'Tìm kiếm bài học...',
      isLoading: isLoading,
      totalCount: lessonService.totalCount,
      countLabel: 'bài', // 👈 Sửa label
      body: bodyContent,
      paginationControls: PaginationControls(
        currentPage: lessonService.currentPage,
        totalPages: lessonService.totalPages,
        totalCount: lessonService.totalCount,
        isLoading: isLoading,
        onPageChanged: (page) => _triggerFetch(pageNumber: page),
      ),
    );
  }

  // ✅ 5. SỬ DỤNG CommonEmptyState
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

  // ✅ 6. SỬ DỤNG BaseAdminTable
  Widget _buildResponsiveTable(List<LessonModel> lessons, double maxWidth) {
    final colWidths = {
      0: maxWidth * 0.07,
      1: maxWidth * 0.28,
      2: maxWidth * 0.30,
      3: maxWidth * 0.35,
    };
    final colHeaders = ['STT', 'Tiêu đề', 'Nội dung', 'Hành động'];

    final int startingIndex =
        (context.read<AdminLessonService>().currentPage - 1) * 5;

    final dataRows =
        lessons.asMap().entries.map((entry) {
          final index = entry.key + startingIndex + 1;
          final lesson = entry.value;
          final hasContent = lesson.hasContent;
          return TableRow(
            children: [
              // ✅ 7. SỬ DỤNG CommonTableCell
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
                    // ✅ 8. SỬ DỤNG ActionIconButton
                    ActionIconButton(
                      icon: Icons.font_download_rounded,
                      color: Colors.purple.shade600,
                      tooltip: 'Quản lý Từ vựng',
                      onPressed: () => _goToVocabulary(lesson),
                    ),
                    const SizedBox(width: 12),
                    ActionIconButton(
                      icon: Icons.edit_document,
                      color: Colors.orange.shade600,
                      tooltip: 'Sửa nội dung',
                      onPressed: () => _showLessonForm(lesson: lesson),
                    ),
                    const SizedBox(width: 12),
                    ActionIconButton(
                      icon: Icons.delete,
                      color: Colors.redAccent,
                      tooltip: 'Xóa',
                      onPressed: () => _confirmDelete(lesson),
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

  // ❌ 9. XÓA _buildCell VÀ _buildActionButton
}
