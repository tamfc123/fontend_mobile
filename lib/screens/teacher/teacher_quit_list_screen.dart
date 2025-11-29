import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile/data/models/class_model.dart';
import 'package:mobile/data/models/quiz_models.dart';
import 'package:mobile/services/teacher/teacher_quiz_service.dart';
import 'package:mobile/shared_widgets/admin/action_icon_button.dart';
import 'package:mobile/shared_widgets/admin/base_admin_screen.dart';
import 'package:mobile/shared_widgets/admin/base_admin_table.dart';
import 'package:mobile/shared_widgets/admin/common_empty_state.dart';
import 'package:mobile/shared_widgets/admin/common_table_cell.dart';
import 'package:mobile/shared_widgets/admin/pagination_controls.dart';
import 'package:provider/provider.dart';

class TeacherQuizListScreen extends StatefulWidget {
  final ClassModel classModel;

  const TeacherQuizListScreen({super.key, required this.classModel});

  @override
  State<TeacherQuizListScreen> createState() => _TeacherQuizListScreenState();
}

class _TeacherQuizListScreenState extends State<TeacherQuizListScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  // State phân trang (Client-side pagination)
  int _currentPage = 1;
  final int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _fetchData());
    _searchController.addListener(_onSearchChanged);
  }

  void _fetchData({String? search}) {
    // Reset về trang 1 khi search
    if (search != null) setState(() => _currentPage = 1);

    context.read<TeacherQuizService>().fetchQuizzes(
      widget.classModel.id,
      search: search,
    );
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        _fetchData(search: _searchController.text);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // Hàm hiển thị chi tiết
  void _showQuizDetail(QuizListModel quiz) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(quiz.title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow('Kỹ năng:', quiz.skillType),
                _detailRow('Số câu hỏi:', '${quiz.questionCount}'),
                _detailRow('Thời gian:', '${quiz.timeLimitMinutes} phút'),
                if (quiz.description != null) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Mô tả:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    quiz.description!,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Đóng'),
              ),
            ],
          ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            '$label ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<TeacherQuizService>();
    final allQuizzes = service.quizzes; // List đầy đủ từ API
    final isLoading = service.isLoading;

    // --- LOGIC PHÂN TRANG CLIENT-SIDE ---
    final totalCount = allQuizzes.length;
    final totalPages = (totalCount / _pageSize).ceil();

    // Cắt list để hiển thị cho trang hiện tại
    final startIndex = (_currentPage - 1) * _pageSize;
    final endIndex =
        (startIndex + _pageSize < totalCount)
            ? startIndex + _pageSize
            : totalCount;

    final displayedQuizzes =
        (allQuizzes.isNotEmpty && startIndex < totalCount)
            ? allQuizzes.sublist(startIndex, endIndex)
            : <QuizListModel>[];

    // --- XÂY DỰNG BODY ---
    Widget bodyContent;
    if (isLoading && allQuizzes.isEmpty) {
      bodyContent = const Center(child: CircularProgressIndicator());
    } else if (allQuizzes.isEmpty) {
      bodyContent = CommonEmptyState(
        title: 'Chưa có bài tập nào',
        subtitle: 'Lớp học này chưa có bài tập nào được giao.',
        icon: Icons.quiz_outlined,
      );
    } else {
      bodyContent = LayoutBuilder(
        builder:
            (context, constraints) =>
                _buildResponsiveTable(displayedQuizzes, constraints.maxWidth),
      );
    }

    return BaseAdminScreen(
      title: 'Danh sách Bài tập',
      subtitle: 'Lớp: ${widget.classModel.name}', // Hiển thị tên lớp
      headerIcon: Icons.quiz_rounded,

      addLabel: 'Làm mới',
      onAddPressed: () => _fetchData(search: _searchController.text),

      onBackPressed: () => Navigator.of(context).pop(),

      searchController: _searchController,
      searchHint: 'Tìm kiếm bài tập...',

      isLoading: isLoading,
      totalCount: totalCount,
      countLabel: 'bài tập',

      body: bodyContent,

      paginationControls: PaginationControls(
        currentPage: _currentPage,
        totalPages: totalPages > 0 ? totalPages : 1,
        totalCount: totalCount,
        isLoading: isLoading,
        onPageChanged: (page) {
          setState(() => _currentPage = page);
        },
      ),
    );
  }

  // ✅ BẢNG DỮ LIỆU (Giống Admin nhưng ít cột hơn)
  Widget _buildResponsiveTable(List<QuizListModel> quizzes, double maxWidth) {
    final colWidths = {
      0: maxWidth * 0.08, // STT
      1: maxWidth * 0.15, // Kỹ năng
      2: maxWidth * 0.35, // Tiêu đề
      3: maxWidth * 0.12, // Số câu
      4: maxWidth * 0.15, // Thời gian
      5: maxWidth * 0.15, // Hành động
    };

    final colHeaders = [
      'STT',
      'Kỹ năng',
      'Tiêu đề',
      'Số câu',
      'Thời gian',
      'Chi tiết',
    ];

    final int startingIndex = (_currentPage - 1) * _pageSize;

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

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Center(
                  child: ActionIconButton(
                    icon: Icons.visibility_rounded,
                    color: Colors.blueAccent,
                    tooltip: 'Xem nội dung',
                    onPressed: () => _showQuizDetail(quiz),
                  ),
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
        label = 'Writing';
        break;
      case 'ESSAY':
        color = Colors.pinkAccent;
        icon = Icons.history_edu_rounded;
        label = 'Essay';
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
