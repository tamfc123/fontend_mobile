import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/data/models/quiz_list_model.dart';
import 'package:mobile/services/teacher/teacher_quiz_service.dart';
import 'package:mobile/widgets/teacher/teacher_quiz_form_dialog.dart';
import 'package:provider/provider.dart';

class TeacherQuizScreen extends StatefulWidget {
  final int classId;
  final String className;

  const TeacherQuizScreen({
    super.key,
    required this.classId,
    required this.className,
  });

  @override
  State<TeacherQuizScreen> createState() => _TeacherQuizScreenState();
}

class _TeacherQuizScreenState extends State<TeacherQuizScreen> {
  // MÀU CHỦ ĐẠO (ĐỒNG NHẤT)
  static const Color primaryBlue = Colors.blue;
  static const Color backgroundBlue = Color(0xFFF3F8FF);
  static const Color surfaceBlue = Color(0xFFE3F2FD);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuizService>().fetchQuizzes(widget.classId);
    });
  }

  void _showCreateQuizDialog() {
    showDialog(
      context: context,
      builder: (_) {
        return ChangeNotifierProvider.value(
          value: context.read<QuizService>(),
          child: TeacherQuizFormDialog(classId: widget.classId),
        );
      },
    );
  }

  void _confirmDelete(QuizListModel quiz) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Xác nhận xóa'),
            content: Text('Bạn có chắc muốn xóa bài tập "${quiz.title}"?'),
            actions: [
              TextButton(
                child: const Text('Hủy'),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
              TextButton(
                child: const Text('Xóa', style: TextStyle(color: Colors.red)),
                onPressed: () {
                  context.read<QuizService>().deleteQuiz(
                    widget.classId,
                    quiz.id,
                  );
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quizService = context.watch<QuizService>();
    final quizzes = quizService.quizzes;
    final isLoading = quizService.isLoadingList;

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
                // === HEADER + STATS ===
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
                                Icons.quiz,
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
                                    'Quản lý bài tập',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E3A8A),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Danh sách bài tập của lớp ${widget.className}',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // NÚT THÊM
                            ElevatedButton.icon(
                              onPressed: _showCreateQuizDialog,
                              icon: const Icon(
                                Icons.add_circle_outline,
                                size: 20,
                              ),
                              label: const Text(
                                'Tạo bài tập mới',
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

                      // STATS
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            // STATS
                            if (!isLoading && quizzes.isNotEmpty)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Tìm thấy ${quizzes.length} bài tập',
                                  style: TextStyle(
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

                // === BẢNG BÀI TẬP ===
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
                              isLoading
                                  ? const Center(
                                    child: CircularProgressIndicator(
                                      color: primaryBlue,
                                    ),
                                  )
                                  : quizzes.isEmpty
                                  ? _buildEmptyState()
                                  : SingleChildScrollView(
                                    child: _buildResponsiveTable(
                                      quizzes,
                                      constraints.maxWidth,
                                    ),
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
          Icon(
            Icons.assignment_outlined,
            size: 72,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'Chưa có bài tập nào',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy tạo bài tập đầu tiên cho lớp này',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveTable(List<QuizListModel> quizzes, double maxWidth) {
    final colWidths = {
      0: maxWidth * 0.4, // Tiêu đề
      1: maxWidth * 0.15, // Câu hỏi
      2: maxWidth * 0.15, // Thời gian
      3: maxWidth * 0.3, // Hành động
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
                  ['Tiêu đề', 'Câu hỏi', 'Thời gian', 'Hành động']
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
            ...quizzes.map((quiz) {
              return TableRow(
                children: [
                  _buildCell(
                    Row(
                      // 1. Bọc bằng Row
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 2. Thêm Icon
                        _buildSkillIcon(quiz.skillType),
                        const SizedBox(width: 12),
                        // 3. Bọc Column bằng Expanded để không vỡ layout
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                quiz.title,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1F2937),
                                ),
                                maxLines: 2, // Cho phép 2 dòng
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'ID: ${quiz.id}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    align: TextAlign.left,
                  ),
                  _buildCell('${quiz.questionCount}', align: TextAlign.center),
                  _buildCell(
                    '${quiz.timeLimitMinutes} phút',
                    align: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildActionButton(
                          Icons.visibility_outlined,
                          primaryBlue,
                          'Xem chi tiết',
                          () {
                            context.go(
                              '/teacher/teacherClasses/${widget.classId}/quiz/${quiz.id}',
                              extra: quiz.title,
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        _buildActionButton(
                          Icons.delete,
                          Colors.redAccent,
                          'Xóa',
                          () => _confirmDelete(quiz),
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

  Widget _buildCell(dynamic content, {TextAlign align = TextAlign.left}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child:
          content is Widget
              ? content
              : Text(
                content.toString(),
                style: const TextStyle(color: Color(0xFF1F2937), fontSize: 14),
                textAlign: align,
                overflow: TextOverflow.ellipsis,
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

  Widget _buildSkillIcon(String skillType) {
    IconData iconData;
    String tooltip;
    Color color;

    switch (skillType.toUpperCase()) {
      case 'LISTENING':
        iconData = Icons.headphones_rounded;
        tooltip = 'Bài tập Nghe';
        color = Colors.purple.shade600;
        break;
      case 'WRITING':
        iconData = Icons.edit_note_rounded;
        tooltip = 'Bài tập Viết';
        color = Colors.orange.shade700;
        break;
      case 'READING':
      default:
        iconData = Icons.menu_book_rounded;
        tooltip = 'Bài tập Đọc / Ngữ pháp';
        color = primaryBlue; // Dùng màu xanh chủ đạo
        break;
    }

    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(iconData, color: color, size: 20),
      ),
    );
  }
}
