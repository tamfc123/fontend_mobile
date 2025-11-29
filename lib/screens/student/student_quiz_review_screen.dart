import 'dart:convert';

import 'package:fl_chart/fl_chart.dart'; // 👈 Nhớ thêm package này vào pubspec.yaml
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mobile/data/models/student_quiz_models.dart';
import 'package:mobile/services/student/student_quiz_service.dart';
import 'package:provider/provider.dart';

class StudentQuizReviewScreen extends StatefulWidget {
  final String classId;
  final String quizId;

  const StudentQuizReviewScreen({
    super.key,
    required this.classId,
    required this.quizId,
  });

  @override
  State<StudentQuizReviewScreen> createState() =>
      _StudentQuizReviewScreenState();
}

class _StudentQuizReviewScreenState extends State<StudentQuizReviewScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentQuizService>().fetchQuizResult(
        widget.classId,
        widget.quizId,
      );
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<StudentQuizService>().clearQuizResult();
      }
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      appBar: AppBar(
        title: const Text(
          'Xem lại bài làm',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black87,
      ),
      body: Consumer<StudentQuizService>(
        builder: (context, service, child) {
          if (service.isLoadingReview) {
            return const Center(child: CircularProgressIndicator());
          }
          if (service.reviewError != null) {
            return Center(child: Text('Lỗi: ${service.reviewError}'));
          }
          if (service.currentReview == null) {
            return const Center(child: Text('Không tải được dữ liệu.'));
          }

          final review = service.currentReview!;
          final hasPassage =
              review.readingPassage != null &&
              review.readingPassage!.isNotEmpty;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            // +1 cho header (điểm số + biểu đồ)
            itemCount: review.questions.length + 1 + (hasPassage ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == 0) return _buildReviewHeader(review);
              if (hasPassage) {
                if (index == 1) {
                  return _buildReadingPassageCard(review.readingPassage!);
                }
                // Nếu index > 1 thì là câu hỏi (index thực của câu hỏi bị lùi 2)
                final question = review.questions[index - 2];
                return _buildQuestionCard(
                  question,
                  index - 1,
                ); // index - 1 vì trừ header+passage, cộng lại 1 cho số thứ tự
              }
              final question = review.questions[index - 1];
              return _buildQuestionCard(question, index);
            },
          );
        },
      ),
    );
  }

  Widget _buildReviewHeader(StudentQuizReviewModel review) {
    final scoreFormatted = NumberFormat("0.#").format(review.score);
    final totalQuestions = review.questions.length;
    final correctCount = review.questions.where((q) => q.isCorrect).length;
    final wrongCount = totalQuestions - correctCount;

    final formattedDate = DateFormat(
      'HH:mm, dd/MM/yyyy',
    ).format(review.submittedAt.toLocal());

    // Lấy dữ liệu từ Model (dùng getter đã viết)
    final aiData = review.aiAssessment;

    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 1. Tiêu đề & Ngày
          Text(
            review.quizTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Đã nộp lúc: $formattedDate',
            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 24),

          // 2. BIỂU ĐỒ TRÒN (Pie Chart)
          SizedBox(
            height: 200,
            child: Stack(
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 70,
                    startDegreeOffset: -90,
                    sections: [
                      PieChartSectionData(
                        color: const Color(0xFF10B981),
                        value: correctCount.toDouble(),
                        title:
                            '${((correctCount / (totalQuestions > 0 ? totalQuestions : 1)) * 100).toInt()}%',
                        radius: 20,
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      PieChartSectionData(
                        color: const Color(0xFFEF4444),
                        value: wrongCount.toDouble(),
                        title: '',
                        radius: 15,
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        scoreFormatted,
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1F2937),
                          height: 1,
                        ),
                      ),
                      const Text(
                        'Điểm',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 3. CHÚ THÍCH (LEGEND) - ✅ ĐÂY LÀ CHỖ SỬ DỤNG _buildLegendItem
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem(
                color: const Color(0xFF10B981),
                label: 'Đúng',
                count: '$correctCount câu',
              ),
              Container(width: 1, height: 40, color: Colors.grey.shade200),
              _buildLegendItem(
                color: const Color(0xFFEF4444),
                label: 'Sai / Bỏ qua',
                count: '$wrongCount câu',
              ),
            ],
          ),

          // 4. AI FEEDBACK (Nằm ngoài Row, ở dưới cùng)
          // ✅ SỬA LẠI: Đặt ở đây mới đúng layout, không bị vỡ
          if (aiData != null) _buildAiFeedbackSection(aiData),
        ],
      ),
    );
  }

  Widget _buildAiFeedbackSection(AiAssessmentResult aiData) {
    if (aiData.feedback.isEmpty && aiData.corrections.isEmpty)
      return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32),
        const Row(
          children: [
            Icon(Icons.psychology, color: Colors.purple),
            SizedBox(width: 8),
            Text(
              "Đánh giá chi tiết từ AI",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Nhận xét chung
        if (aiData.feedback.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              aiData.feedback,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ),

        // Sửa lỗi chi tiết
        if (aiData.corrections.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            "Các lỗi cần khắc phục:",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ...aiData.corrections.map((c) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red.shade100),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.original,
                    style: const TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: Colors.red,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.arrow_right_alt,
                        color: Colors.green,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          c.fixed,
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (c.explanation.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        c.explanation,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required String count,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          count,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  // ... (Phần _buildQuestionCard giữ nguyên code cũ) ...
  Widget _buildQuestionCard(StudentQuestionReviewModel question, int index) {
    // Copy hàm _buildQuestionCard từ code cũ của bạn
    // (Phần này bạn làm đúng rồi, tôi không paste lại cho dài dòng)
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header câu hỏi
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
                    color:
                        question.isCorrect
                            ? const Color(0xFF059669)
                            : const Color(0xFFDC2626),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$index',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
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
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Nội dung câu trả lời
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAudioPlayer(question),

                if (question.questionType == 'MULTIPLE_CHOICE')
                  ...question.options.asMap().entries.map((entry) {
                    return _buildOptionTile(
                      option: entry.value,
                      optionIndex: entry.key,
                      // ✅ Truyền String ID
                      selectedOptionId: question.selectedOptionId,
                    );
                  })
                else
                  _buildWritingReview(question),

                // ✅ HIỂN THỊ GIẢI THÍCH (EXPLANATION)
                if (question.explanation != null &&
                    question.explanation!.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.lightbulb,
                          color: Colors.amber,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Giải thích: ${question.explanation}",
                            style: TextStyle(color: Colors.brown.shade800),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ... (Phần _buildAudioPlayer và _buildWritingReview giữ nguyên) ...

  // ✅ ĐÃ SỬA LỖI TYPE MISMATCH
  Widget _buildOptionTile({
    required StudentOptionReviewModel option,
    required int optionIndex,
    required String? selectedOptionId, // 👈 Nhận String
  }) {
    final optionLabel = String.fromCharCode(65 + optionIndex);
    bool isCorrect = option.isCorrect;

    // So sánh String với String (Chuẩn)
    bool isSelected = option.optionId == selectedOptionId;

    Color borderColor = Colors.grey.shade200;
    Color bgColor = Colors.white;
    if (isCorrect) {
      borderColor = Colors.green;
      bgColor = Colors.green.shade50;
    } else if (isSelected) {
      borderColor = Colors.red;
      bgColor = Colors.red.shade50;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            "$optionLabel.",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(option.optionText)),
          if (isCorrect) const Icon(Icons.check, color: Colors.green),
          if (isSelected && !isCorrect)
            const Icon(Icons.close, color: Colors.red),
        ],
      ),
    );
  }

  Widget _buildAudioPlayer(StudentQuestionReviewModel question) {
    // (Giữ nguyên code cũ của bạn)
    if (question.audioUrl == null || question.audioUrl!.isEmpty)
      return const SizedBox.shrink();
    return IconButton(
      icon: const Icon(Icons.volume_up, color: Colors.purple),
      onPressed: () async {
        await _audioPlayer.setUrl(question.audioUrl!);
        _audioPlayer.play();
      },
    );
  }

  // ✅ NÂNG CẤP: HIỂN THỊ FEEDBACK CHI TIẾT CỦA AI
  Widget _buildWritingReview(StudentQuestionReviewModel question) {
    // Parse JSON từ SkillAnalysis (nếu có) để lấy feedback chi tiết
    // Lưu ý: SkillAnalysisJson nằm ở tầng ReviewModel chung, nhưng với bài Essay 1 câu hỏi,
    // ta có thể giả định nó áp dụng cho câu hỏi này.

    // Tuy nhiên, ở màn hình này, `question` là `StudentQuestionReviewModel`
    // Nó không chứa `skillAnalysisJson`.
    // `skillAnalysisJson` nằm ở `StudentQuizReviewModel` (biến `review` ở hàm build).

    // -> Để đơn giản, ta chỉ hiển thị Text so sánh ở đây.
    // Còn phần Feedback AI, ta đã hiển thị ở Header (như tôi hướng dẫn ở bước trước).

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Bài làm của bạn:",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: Text(
            question.studentAnswerText ?? '(Bạn đã bỏ trống)',
            style: const TextStyle(fontSize: 15, height: 1.5),
          ),
        ),

        // Với bài Essay AI chấm, không có "Đáp án đúng" cố định
        // Nên ta ẩn phần CorrectAnswerText đi nếu nó rỗng hoặc không cần thiết
        if (question.correctAnswerText != null &&
            question.correctAnswerText!.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            "Đáp án tham khảo:",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade100),
            ),
            child: Text(
              question.correctAnswerText!,
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildReadingPassageCard(String passage) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E6), // Màu vàng nhạt
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
            ),
          ),
        ],
      ),
    );
  }
}
