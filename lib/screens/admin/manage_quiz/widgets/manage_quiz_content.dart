import 'package:flutter/material.dart';
import 'package:mobile/data/models/quiz_models.dart';
import 'package:mobile/screens/admin/manage_quiz/manage_quiz_view_model.dart';
import 'package:mobile/shared_widgets/admin/action_icon_button.dart';
import 'package:mobile/shared_widgets/admin/base_admin_table.dart';
import 'package:mobile/shared_widgets/admin/common_empty_state.dart';
import 'package:mobile/shared_widgets/admin/common_table_cell.dart';

class ManageQuizContent extends StatelessWidget {
  final ManageQuizViewModel viewModel;
  final String courseId;
  final VoidCallback onShowForm;
  final Function(QuizListModel) onConfirmDelete;
  final Function(QuizListModel) onConfirmRestore;
  final Function(String) onGoToDetail;

  const ManageQuizContent({
    super.key,
    required this.viewModel,
    required this.courseId,
    required this.onShowForm,
    required this.onConfirmDelete,
    required this.onConfirmRestore,
    required this.onGoToDetail,
    this.maxWidth = double.infinity,
  });

  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final quizzes = viewModel.quizzes;
    final isLoading = viewModel.isLoading;
    final showDeleted = viewModel.showDeleted;

    Widget mainContent;
    if (isLoading && quizzes.isEmpty) {
      mainContent = const Center(child: CircularProgressIndicator());
    } else if (quizzes.isEmpty) {
      mainContent = _buildEmptyState(viewModel.searchQuery, showDeleted);
    } else {
      mainContent = _buildResponsiveTable(
        context,
        quizzes,
        maxWidth,
        showDeleted,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: showDeleted ? Colors.red.shade50 : Colors.blue.shade50,
          child: Row(
            children: [
              Icon(
                showDeleted ? Icons.delete_sweep : Icons.check_circle,
                color: showDeleted ? Colors.red : Colors.blue,
              ),
              const SizedBox(width: 12),
              Text(
                showDeleted ? 'Thùng rác' : 'Danh sách',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: showDeleted ? Colors.red : Colors.blue,
                ),
              ),
              const Spacer(),
              const Text('Thùng rác', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 8),
              Switch(
                value: showDeleted,
                activeColor: Colors.red,
                onChanged: (value) {
                  viewModel.toggleShowDeleted(courseId);
                },
              ),
            ],
          ),
        ),
        Flexible(fit: FlexFit.loose, child: mainContent),
      ],
    );
  }

  Widget _buildEmptyState(String? searchQuery, bool showDeleted) {
    bool isSearching = searchQuery != null && searchQuery.isNotEmpty;

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

  Widget _buildResponsiveTable(
    BuildContext context,
    List<QuizListModel> quizzes,
    double maxWidth,
    bool showDeleted,
  ) {
    final colWidths = {
      0: maxWidth * 0.07,
      1: maxWidth * 0.12,
      2: maxWidth * 0.28,
      3: maxWidth * 0.10,
      4: maxWidth * 0.13,
      5: maxWidth * 0.30,
    };

    final colHeaders = [
      'STT',
      'Kỹ năng',
      'Tiêu đề',
      'Số câu',
      'Thời gian',
      showDeleted ? 'Khôi phục' : 'Hành động',
    ];

    final int startingIndex = (viewModel.currentPage - 1) * 10;

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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (showDeleted) ...[
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
                        onPressed: () => onConfirmRestore(quiz),
                      ),
                    ] else ...[
                      ActionIconButton(
                        icon: Icons.visibility_rounded,
                        color: Colors.blueAccent,
                        tooltip: 'Xem chi tiết',
                        onPressed: () => onGoToDetail(quiz.id),
                      ),
                      const SizedBox(width: 12),
                      ActionIconButton(
                        icon: Icons.delete_rounded,
                        color: Colors.redAccent,
                        tooltip: 'Xóa',
                        onPressed: () => onConfirmDelete(quiz),
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
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.2)),
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
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
