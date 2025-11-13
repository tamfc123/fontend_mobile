import 'package:flutter/material.dart';
import 'package:mobile/services/teacher/teacher_quiz_service.dart';
import 'package:provider/provider.dart';
import 'package:mobile/data/models/quiz_detail_model.dart';

class TeacherQuizDetailScreen extends StatefulWidget {
  final int classId;
  final int quizId;
  final String quizTitle;

  const TeacherQuizDetailScreen({
    super.key,
    required this.classId,
    required this.quizId,
    required this.quizTitle,
  });

  @override
  State<TeacherQuizDetailScreen> createState() =>
      _TeacherQuizDetailScreenState();
}

class _TeacherQuizDetailScreenState extends State<TeacherQuizDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuizService>().fetchQuizDetails(
        widget.classId,
        widget.quizId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizService>(
      builder: (context, quizService, child) {
        final quiz = quizService.selectedQuiz;
        final isLoading = quizService.isLoadingDetail;

        return Scaffold(
          backgroundColor: const Color(0xFFFAFBFC),
          body:
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : quiz == null
                  ? Center(
                    child: Text(
                      quizService.detailError ?? 'Không thể tải chi tiết.',
                      style: const TextStyle(fontSize: 16),
                    ),
                  )
                  : Column(
                    children: [
                      _buildHeader(),
                      Expanded(child: _buildQuestionsBody(quiz)),
                    ],
                  ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, size: 24),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Chi tiết bài tập',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.quizTitle,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E5A96),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionsBody(QuizDetailModel quiz) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        children: [
          // Info Section
          _buildQuizInfoSection(quiz),
          const SizedBox(height: 32),
          // Questions Section
          ..._generateQuestionItems(quiz),
        ],
      ),
    );
  }

  Widget _buildQuizInfoSection(QuizDetailModel quiz) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            quiz.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          if (quiz.description != null && quiz.description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              quiz.description!,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                height: 1.6,
              ),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  icon: Icons.timer_outlined,
                  label: 'Thời gian',
                  value: '${quiz.timeLimitMinutes} phút',
                  color: const Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoCard(
                  icon: Icons.quiz_outlined,
                  label: 'Số câu hỏi',
                  value: '${quiz.questions.length}',
                  color: const Color(0xFF059669),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        border: Border.all(color: color.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _generateQuestionItems(QuizDetailModel quiz) {
    return List.generate(quiz.questions.length, (index) {
      final question = quiz.questions[index];
      return Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: _buildQuestionCard(question, index + 1),
      );
    });
  }

  Widget _buildQuestionCard(QuestionDetailModel question, int questionNumber) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFFF9FAFB),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$questionNumber',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    question.questionText,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Options Section
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...question.options.asMap().entries.map((entry) {
                  final optIndex = entry.key;
                  final option = entry.value;
                  return _buildOptionTile(option, optIndex);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(OptionDetailModel option, int optionIndex) {
    final isCorrect = option.isCorrect;
    final optionLabel = String.fromCharCode(65 + optionIndex); // A, B, C, D

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isCorrect ? const Color(0xFFF0FDF4) : const Color(0xFFFAFBFC),
          border: Border.all(
            color:
                isCorrect ? const Color(0xFF86EFAC) : const Color(0xFFE5E7EB),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color:
                    isCorrect
                        ? const Color(0xFF059669)
                        : const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(50),
              ),
              alignment: Alignment.center,
              child: Text(
                optionLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                option.optionText,
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF1F2937),
                  fontWeight: isCorrect ? FontWeight.w600 : FontWeight.w500,
                  height: 1.5,
                ),
              ),
            ),
            if (isCorrect)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF059669),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Đáp án',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
