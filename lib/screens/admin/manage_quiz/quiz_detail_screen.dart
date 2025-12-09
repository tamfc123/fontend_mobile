import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/data/models/course_model.dart';
import 'package:mobile/data/models/quiz_models.dart';
import 'package:mobile/screens/admin/manage_quiz/quiz_detail_view_model.dart';
import 'package:mobile/shared_widgets/admin/action_icon_button.dart';
import 'package:mobile/shared_widgets/admin/comfirm_delete_dialog.dart';
import 'package:provider/provider.dart';

class QuizDetailScreen extends StatefulWidget {
  final CourseModel course;
  final String quizId;

  const QuizDetailScreen({
    super.key,
    required this.course,
    required this.quizId,
  });

  @override
  State<QuizDetailScreen> createState() => _QuizDetailScreenState();
}

class _QuizDetailScreenState extends State<QuizDetailScreen> {
  static const Color primaryBlue = Colors.blue;
  static const Color backgroundBlue = Color(0xFFF3F8FF);
  static const Color surfaceBlue = Color(0xFFE3F2FD);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuizDetailViewModel>().fetchQuizDetails(
        widget.course.id!,
        widget.quizId,
      );
    });
  }

  void _deleteQuestion(BuildContext context, String questionId) {
    showDialog(
      context: context,
      builder:
          (_) => ConfirmDeleteDialog(
            title: 'Xóa câu hỏi',
            content: 'Bạn có chắc muốn xóa câu hỏi này khỏi đề thi?',
            itemName: 'Câu hỏi',
            onConfirm: () async {
              await context.read<QuizDetailViewModel>().deleteQuestion(
                widget.course.id!,
                questionId,
              );
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizDetailViewModel>(
      builder: (context, viewModel, child) {
        final quiz = viewModel.selectedQuiz;
        final isLoading = viewModel.isLoading;

        return Scaffold(
          backgroundColor: backgroundBlue,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: primaryBlue),
              onPressed: () => context.pop(),
            ),
            title: Row(
              children: [
                const Icon(Icons.quiz, color: primaryBlue, size: 24),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Chi tiết Bài tập',
                      style: TextStyle(
                        color: Color(0xFF1E3A8A),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    if (quiz != null)
                      Text(
                        quiz.title,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(color: Colors.grey.shade200, height: 1),
            ),
          ),
          body:
              isLoading
                  ? const Center(
                    child: CircularProgressIndicator(color: primaryBlue),
                  )
                  : quiz == null
                  ? const Center(child: Text('Không tìm thấy dữ liệu bài tập'))
                  : Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1000),
                      child: ListView(
                        padding: const EdgeInsets.all(24),
                        children: [
                          _buildInfoCard(quiz),
                          const SizedBox(height: 24),
                          if (quiz.skillType == 'READING' &&
                              quiz.readingPassage != null &&
                              quiz.readingPassage!.isNotEmpty)
                            _buildReadingPassageCard(quiz.readingPassage!),
                          if (quiz.skillType == 'LISTENING' &&
                              quiz.mediaUrl != null &&
                              quiz.mediaUrl!.isNotEmpty)
                            _buildAudioInfoCard(quiz.mediaUrl!),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              const Icon(Icons.list_alt, color: primaryBlue),
                              const SizedBox(width: 8),
                              Text(
                                'Danh sách câu hỏi (${quiz.questions.length})',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E3A8A),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (quiz.questions.isEmpty)
                            _buildEmptyQuestionsState()
                          else
                            ...quiz.questions.asMap().entries.map((entry) {
                              final index = entry.key;
                              final question = entry.value;
                              return _buildQuestionCard(
                                context,
                                index + 1,
                                question,
                              );
                            }),
                          const SizedBox(height: 50),
                        ],
                      ),
                    ),
                  ),
        );
      },
    );
  }

  Widget _buildInfoCard(QuizDetailModel quiz) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildSkillBadge(quiz.skillType),
              const Spacer(),
              Icon(Icons.timer_outlined, size: 18, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                quiz.timeLimitMinutes > 0
                    ? '${quiz.timeLimitMinutes} phút'
                    : 'Không giới hạn',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            quiz.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          if (quiz.description != null && quiz.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              quiz.description!,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReadingPassageCard(String passage) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE0B2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.menu_book, color: Colors.orange, size: 20),
              SizedBox(width: 8),
              Text(
                'Reading Passage',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            passage,
            style: const TextStyle(
              fontSize: 16,
              height: 1.6,
              color: Color(0xFF4B5563),
              fontFamily: 'Roboto',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(
    BuildContext context,
    int index,
    QuestionDetailModel question,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: surfaceBlue,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Câu $index',
                  style: const TextStyle(
                    color: primaryBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (question.tag != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    question.tag!,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              const Spacer(),
              ActionIconButton(
                icon: Icons.close,
                color: Colors.redAccent,
                tooltip: 'Xóa câu hỏi này',
                onPressed: () => _deleteQuestion(context, question.id),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            question.questionText,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          if (question.audioUrl != null && question.audioUrl!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.volume_up_rounded, color: primaryBlue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Audio: ${question.audioUrl}',
                      style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          ...question.options.map((option) {
            final isCorrect = option.isCorrect;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color:
                    isCorrect
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isCorrect ? Colors.green : Colors.transparent,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isCorrect
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: isCorrect ? Colors.green : Colors.grey.shade400,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      option.optionText,
                      style: TextStyle(
                        color:
                            isCorrect ? Colors.green.shade800 : Colors.black87,
                        fontWeight:
                            isCorrect ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          if (question.explanation != null &&
              question.explanation!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb,
                        size: 16,
                        color: Colors.amber.shade700,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Giải thích:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey.shade800,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    question.explanation!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blueGrey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAudioInfoCard(String url) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.audio_file, color: Colors.purple),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "File Âm Thanh (Audio Source):",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  url,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    decoration: TextDecoration.underline,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyQuestionsState() {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.quiz_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Chưa có câu hỏi nào',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

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
        color = primaryBlue;
        icon = Icons.menu_book;
        label = 'Reading';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
