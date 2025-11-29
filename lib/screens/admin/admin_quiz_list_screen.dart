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
// Đã xóa import ConfirmDeleteDialog để dùng AlertDialog tiêu chuẩn
import 'package:mobile/utils/toast_helper.dart';
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
    final quizService = context.read<AdminQuizService>();
    // Lấy search query cũ nếu có (để giữ trạng thái khi back về)
    _searchController.text = quizService.searchQuery ?? '';

    // ✅ Kiểm tra trạng thái xem rác để fetch đúng dữ liệu
    if (quizService.showDeleted) {
      Future.microtask(() => quizService.toggleShowDeleted(widget.course.id!));
    } else {
      Future.microtask(() => _triggerFetch(pageNumber: 1));
    }

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
        // Khi search thay đổi -> Về trang 1
        _triggerFetch(pageNumber: 1);
      }
    });
  }

  // ✅ Logic Fetch tập trung
  void _triggerFetch({int? pageNumber}) {
    final service = context.read<AdminQuizService>();
    final page = pageNumber ?? service.currentPage;
    final search = _searchController.text;

    if (search != service.searchQuery) {
      service.applySearch(widget.course.id!, search);
    } else {
      service.goToPage(widget.course.id!, page);
    }
  }

  // 1. Mở Dialog Tạo/Sửa Quiz
  void _showQuizForm() async {
    await showDialog(
      context: context,
      builder: (_) => AdminQuizFormDialog(courseId: widget.course.id!),
    );
  }

  // ✅ [ĐÃ SỬA] Sử dụng AlertDialog tiêu chuẩn & xử lý context an toàn
  void _confirmDelete(QuizListModel quiz) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Chuyển vào thùng rác?'),
          content: Text('Bạn có chắc muốn xóa bài tập "${quiz.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              onPressed: () async {
                // 1. Đóng dialog trước
                Navigator.of(dialogContext).pop();

                // 2. Gọi API xóa (ẩn)
                await context.read<AdminQuizService>().deleteQuiz(
                  widget.course.id!,
                  quiz.id,
                );
              },
              child: const Text(
                'Đồng ý',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // ✅ [MỚI] Hàm xác nhận khôi phục
  void _confirmRestore(QuizListModel quiz) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Khôi phục bài tập'),
          content: Text(
            'Bạn muốn khôi phục "${quiz.title}" trở lại danh sách khóa học?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () async {
                // 1. Đóng dialog trước
                Navigator.of(dialogContext).pop();

                // 2. Gọi API khôi phục
                await context.read<AdminQuizService>().restoreQuiz(
                  widget.course.id!,
                  quiz.id,
                );
              },
              child: const Text(
                'Khôi phục',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // 3. Chuyển sang màn hình chi tiết
  void _goToDetail(String quizId) {
    final location = GoRouterState.of(context).uri.toString();
    context.push('$location/$quizId', extra: {'course': widget.course});
  }

  @override
  Widget build(BuildContext context) {
    final quizService = context.watch<AdminQuizService>();
    final quizzes = quizService.quizzes;
    final isLoading = quizService.isLoading;
    final showDeleted = quizService.showDeleted; // ✅ Lấy trạng thái thùng rác

    // --- XÂY DỰNG BODY ---
    Widget mainContent;
    if (isLoading && quizzes.isEmpty) {
      mainContent = const Center(child: CircularProgressIndicator());
    } else if (quizzes.isEmpty) {
      mainContent = _buildEmptyState(quizService.searchQuery, showDeleted);
    } else {
      mainContent = LayoutBuilder(
        builder:
            (context, constraints) => _buildResponsiveTable(
              quizzes,
              constraints.maxWidth,
              showDeleted,
            ),
      );
    }

    // ✅ Bọc trong Column để thêm cái Switch Thùng rác
    Widget bodyContent = Column(
      children: [
        // Thanh công cụ bộ lọc (Switch Thùng rác)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: showDeleted ? Colors.red.shade50 : Colors.blue.shade50,
          child: Row(
            children: [
              Icon(
                showDeleted ? Icons.delete_sweep : Icons.check_circle,
                color: showDeleted ? Colors.red : primaryBlue,
              ),
              const SizedBox(width: 12),
              Text(
                showDeleted ? 'Đang xem Thùng Rác' : 'Danh sách Hiển thị',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: showDeleted ? Colors.red : primaryBlue,
                ),
              ),
              const Spacer(),
              const Text('Xem Thùng rác', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 8),
              Switch(
                value: showDeleted,
                activeColor: Colors.red,
                onChanged: (value) {
                  // Gọi Service để toggle và reload list
                  context.read<AdminQuizService>().toggleShowDeleted(
                    widget.course.id!,
                  );
                },
              ),
            ],
          ),
        ),

        // Nội dung bảng
        Expanded(child: mainContent),
      ],
    );

    // --- SỬ DỤNG BaseAdminScreen ---
    return BaseAdminScreen(
      title: 'Quản lý Bài tập',
      subtitle:
          showDeleted
              ? 'THÙNG RÁC - ${widget.course.name}'
              : 'Khóa học: ${widget.course.name}',
      headerIcon: showDeleted ? Icons.delete_outline : Icons.quiz_rounded,

      addLabel: 'Thêm Bài tập',
      onAddPressed: () {
        // Nếu đang ở thùng rác, tự động chuyển về trang chính để thêm
        if (showDeleted) {
          context.read<AdminQuizService>().toggleShowDeleted(widget.course.id!);
        }
        _showQuizForm();
      },

      onBackPressed: () => context.pop(),

      searchController: _searchController,
      searchHint: 'Tìm kiếm bài tập...',

      isLoading: isLoading,
      totalCount: quizService.totalCount,
      countLabel: 'bài tập',

      body: bodyContent,

      paginationControls: PaginationControls(
        currentPage: quizService.currentPage,
        totalPages: quizService.totalPages,
        totalCount: quizService.totalCount,
        isLoading: isLoading,
        onPageChanged: (page) => _triggerFetch(pageNumber: page),
      ),
    );
  }

  Widget _buildEmptyState(String? searchQuery, bool showDeleted) {
    bool isSearching = searchQuery != null && searchQuery.isNotEmpty;

    // Custom cho thùng rác
    if (showDeleted) {
      return CommonEmptyState(
        icon: Icons.delete_sweep_outlined,
        title:
            isSearching ? 'Không tìm thấy trong thùng rác' : 'Thùng rác trống',
        subtitle:
            isSearching
                ? 'Thử từ khóa khác'
                : 'Các bài tập bị xóa sẽ xuất hiện ở đây',
      );
    }

    return CommonEmptyState(
      icon: isSearching ? Icons.search_off : Icons.quiz_outlined,
      title: isSearching ? 'Không tìm thấy bài tập' : 'Chưa có bài tập nào',
      subtitle:
          isSearching
              ? 'Thử tìm kiếm bằng từ khóa khác'
              : 'Nhấn "Thêm Bài tập" để bắt đầu',
    );
  }

  // ✅ BẢNG DỮ LIỆU CHUẨN (Có logic Khôi phục)
  Widget _buildResponsiveTable(
    List<QuizListModel> quizzes,
    double maxWidth,
    bool showDeleted,
  ) {
    final colWidths = {
      0: maxWidth * 0.07, // STT
      1: maxWidth * 0.12, // Kỹ năng (Badge)
      2: maxWidth * 0.28, // Tiêu đề
      3: maxWidth * 0.10, // Số câu
      4: maxWidth * 0.13, // Thời gian
      5: maxWidth * 0.30, // Hành động
    };

    final colHeaders = [
      'STT',
      'Kỹ năng',
      'Tiêu đề',
      'Số câu',
      'Thời gian',
      showDeleted ? 'Khôi phục' : 'Hành động', // Đổi tên cột
    ];

    final int startingIndex =
        (context.read<AdminQuizService>().currentPage - 1) *
        10; // pageSize mặc định là 10

    final dataRows =
        quizzes.asMap().entries.map((entry) {
          final index = entry.key + startingIndex + 1;
          final quiz = entry.value;

          return TableRow(
            children: [
              CommonTableCell('$index', align: TextAlign.center, bold: true),

              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 4,
                ),
                child: Center(child: _buildSkillBadge(quiz.skillType)),
              ),

              CommonTableCell(
                quiz.title,
                bold: true,
                align: TextAlign.left,
                color: const Color(0xFF1E3A8A),
              ),

              CommonTableCell('${quiz.questionCount}', align: TextAlign.center),

              CommonTableCell(
                quiz.timeLimitMinutes > 0 ? '${quiz.timeLimitMinutes}p' : '--',
                align: TextAlign.center,
                color:
                    quiz.timeLimitMinutes > 0 ? Colors.black87 : Colors.green,
              ),

              // ✅ Cột Hành động thay đổi theo showDeleted
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (showDeleted) ...[
                      // 🟢 NÚT KHÔI PHỤC
                      ElevatedButton.icon(
                        icon: const Icon(
                          Icons.restore,
                          size: 18,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Khôi phục',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        onPressed: () => _confirmRestore(quiz),
                      ),
                    ] else ...[
                      // 🔵 NÚT CHI TIẾT & XÓA
                      ActionIconButton(
                        icon: Icons.visibility_rounded,
                        color: Colors.blueAccent,
                        tooltip: 'Xem chi tiết',
                        onPressed: () => _goToDetail(quiz.id),
                      ),
                      const SizedBox(width: 12),
                      ActionIconButton(
                        icon: Icons.delete_rounded,
                        color: Colors.redAccent,
                        tooltip: 'Xóa',
                        onPressed: () => _confirmDelete(quiz),
                      ),
                    ],
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

  Widget _buildSkillBadge(String skillType) {
    Color color;
    IconData icon;
    String label;

    switch (skillType.toUpperCase()) {
      case 'LISTENING':
        color = Colors.purple;
        icon = Icons.headphones_rounded;
        label = 'Listening';
        break;
      case 'WRITING':
        color = Colors.orange;
        icon = Icons.edit_note_rounded;
        label = 'Writing (Fill)';
        break;
      case 'ESSAY':
        color = Colors.pinkAccent;
        icon = Icons.history_edu_rounded;
        label = 'Essay (AI)';
        break;
      case 'GRAMMAR':
        color = Colors.teal;
        icon = Icons.spellcheck_rounded;
        label = 'Grammar';
        break;
      case 'READING':
      default:
        color = const Color(0xFF1E3A8A);
        icon = Icons.menu_book_rounded;
        label = 'Reading';
        break;
    }

    return Tooltip(
      message: label,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
