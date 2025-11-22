import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/data/models/course_model.dart';
import 'package:mobile/data/models/quiz_models.dart';
import 'package:mobile/services/admin/admin_quiz_service.dart';
import 'package:mobile/shared_widgets/admin/action_icon_button.dart';
import 'package:mobile/shared_widgets/admin/base_admin_screen.dart';
import 'package:mobile/shared_widgets/admin/base_admin_table.dart';
import 'package:mobile/shared_widgets/admin/common_empty_state.dart';
import 'package:mobile/shared_widgets/admin/common_table_cell.dart';
import 'package:mobile/shared_widgets/admin/pagination_controls.dart';
import 'package:mobile/shared_widgets/comfirm_delete_dialog.dart';
import 'package:mobile/widgets/admin/admin_quiz_form_dialog.dart';
import 'package:provider/provider.dart';

class AdminQuizListScreen extends StatefulWidget {
  final CourseModel course;

  const AdminQuizListScreen({super.key, required this.course});

  @override
  State<AdminQuizListScreen> createState() => _AdminQuizListScreenState();
}

class _AdminQuizListScreenState extends State<AdminQuizListScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  // MÀU CHỦ ĐẠO
  static const Color primaryBlue = Colors.blue;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final quizService = context.read<AdminQuizService>();
      // Reset search query trong service nếu cần
      _searchController.text = '';
      // Gọi API lấy danh sách (Refresh về trang 1)
      quizService.fetchQuizzes(widget.course.id!, refresh: true);
    });

    // ✅ Lắng nghe sự kiện gõ phím giống ManageCourseScreen
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // ✅ Logic Search với Debounce (500ms)
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        // Gọi Service để tìm kiếm Server-side
        context.read<AdminQuizService>().applySearch(
          widget.course.id!,
          _searchController.text,
        );
      }
    });
  }

  // 1. Mở Dialog Tạo/Sửa Quiz
  void _showQuizForm() async {
    await showDialog(
      context: context,
      builder: (_) => AdminQuizFormDialog(courseId: widget.course.id!),
    );
  }

  // 2. Xác nhận xóa
  void _confirmDelete(QuizListModel quiz) {
    showDialog(
      context: context,
      builder:
          (_) => ConfirmDeleteDialog(
            title: 'Xác nhận xóa',
            content: 'Bạn có chắc muốn xóa bài tập "${quiz.title}"?',
            itemName: quiz.title,
            onConfirm: () async {
              await context.read<AdminQuizService>().deleteQuiz(
                widget.course.id!,
                quiz.id,
              );
            },
          ),
    );
  }

  // 3. Chuyển sang màn hình chi tiết
  void _goToDetail(String quizId) {
    final location = GoRouterState.of(context).uri.toString();
    context.go('$location/$quizId', extra: {'course': widget.course});
  }

  @override
  Widget build(BuildContext context) {
    final quizService = context.watch<AdminQuizService>();
    final quizzes = quizService.quizzes;
    final isLoading = quizService.isLoading;

    // --- XÂY DỰNG BODY ---
    Widget bodyContent;
    if (isLoading && quizzes.isEmpty) {
      bodyContent = const Center(
        child: CircularProgressIndicator(color: primaryBlue),
      );
    } else if (quizzes.isEmpty) {
      bodyContent = _buildEmptyState(
        quizService.searchQuery,
      ); // Dùng SearchQuery từ Service để check
    } else {
      bodyContent = LayoutBuilder(
        builder:
            (context, constraints) =>
                _buildResponsiveTable(quizzes, constraints.maxWidth),
      );
    }

    // --- SỬ DỤNG BaseAdminScreen ---
    return BaseAdminScreen(
      title: 'Quản lý Bài tập',
      subtitle: 'Khóa học: ${widget.course.name}',
      headerIcon: Icons.quiz_rounded,

      addLabel: 'Thêm Bài tập',
      onAddPressed: _showQuizForm,

      // Có nút Back vì màn hình này được push từ ManageCourseScreen
      onBackPressed: () => context.pop(),

      searchController: _searchController,
      searchHint: 'Tìm theo tên bài tập...',

      isLoading: isLoading,
      totalCount: quizService.totalCount,
      countLabel: 'Bài tập',

      body: bodyContent,

      // ✅ Pagination Controls kết nối với Service
      paginationControls: PaginationControls(
        currentPage: quizService.currentPage,
        totalPages: quizService.totalPages,
        totalCount: quizService.totalCount,
        isLoading: isLoading,
        onPageChanged: (page) {
          context.read<AdminQuizService>().goToPage(widget.course.id!, page);
        },
      ),
    );
  }

  // Widget Empty State
  Widget _buildEmptyState(String? searchQuery) {
    // Kiểm tra xem có đang search không (dựa vào controller hoặc service state)
    bool isSearching = _searchController.text.isNotEmpty;

    return CommonEmptyState(
      icon: isSearching ? Icons.search_off : Icons.quiz_outlined,
      title: isSearching ? 'Không tìm thấy kết quả' : 'Chưa có bài tập nào',
      subtitle:
          isSearching
              ? 'Thử tìm kiếm bằng từ khóa khác'
              : 'Nhấn "Thêm Bài tập" để tạo bài tập cho khóa học này',
    );
  }

  // Widget Bảng Dữ Liệu
  Widget _buildResponsiveTable(List<QuizListModel> quizzes, double maxWidth) {
    final colWidths = {
      0: maxWidth * 0.08, // Icon Kỹ năng
      1: maxWidth * 0.35, // Tiêu đề
      2: maxWidth * 0.15, // Số câu
      3: maxWidth * 0.15, // Thời gian
      4: maxWidth * 0.27, // Hành động
    };

    final colHeaders = [
      'Kỹ năng',
      'Tiêu đề',
      'Số câu hỏi',
      'Thời gian',
      'Hành động',
    ];

    final dataRows =
        quizzes.map((quiz) {
          return TableRow(
            children: [
              // Cột 1: Icon Kỹ năng
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(child: _buildSkillBadge(quiz.skillType)),
              ),

              // Cột 2: Tiêu đề
              CommonTableCell(
                quiz.title,
                bold: true,
                align: TextAlign.left,
                color: const Color(0xFF1F2937),
              ),

              // Cột 3: Số câu
              CommonTableCell(
                '${quiz.questionCount} câu',
                align: TextAlign.center,
              ),

              // Cột 4: Thời gian
              CommonTableCell(
                quiz.timeLimitMinutes > 0
                    ? '${quiz.timeLimitMinutes} phút'
                    : 'Không GH',
                align: TextAlign.center,
                color:
                    quiz.timeLimitMinutes > 0 ? Colors.black87 : Colors.green,
              ),

              // Cột 5: Hành động
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Nút Xem chi tiết
                    ActionIconButton(
                      icon: Icons.visibility_outlined,
                      color: Colors.blueAccent,
                      tooltip: 'Xem chi tiết',
                      onPressed: () => _goToDetail(quiz.id),
                    ),
                    const SizedBox(width: 12),

                    // Nút Xóa
                    ActionIconButton(
                      icon: Icons.delete_outline,
                      color: Colors.redAccent,
                      tooltip: 'Xóa bài tập',
                      onPressed: () => _confirmDelete(quiz),
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

  // Widget hiển thị Badge kỹ năng đẹp mắt
  Widget _buildSkillBadge(String skillType) {
    Color color;
    IconData icon;
    String label;

    switch (skillType.toUpperCase()) {
      case 'LISTENING':
        color = Colors.purple;
        icon = Icons.headphones;
        label = 'Listening';
        break;
      case 'WRITING':
        color = Colors.orange;
        icon = Icons.edit_note;
        label = 'Writing';
        break;
      case 'READING':
      default:
        color = Colors.blue;
        icon = Icons.menu_book;
        label = 'Reading';
        break;
    }

    return Tooltip(
      message: label,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}
