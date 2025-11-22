import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mobile/data/models/student_quiz_review_model.dart';
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
  // ✅ 2. THÊM AUDIO PLAYER
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    // Gọi service ngay khi màn hình được build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentQuizService>().fetchQuizResult(
        widget.classId,
        widget.quizId,
      );
    });
  }

  @override
  void dispose() {
    // ✅ 3. DỌN DẸP AUDIO PLAYER
    _audioPlayer.dispose();

    // Dọn dẹp state khi rời màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Đảm bảo context vẫn còn tồn tại
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
        title: const Text('Xem lại bài làm'),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      // Dùng Consumer để build body
      body: Consumer<StudentQuizService>(
        builder: (context, service, child) {
          // 1. Trạng thái Loading
          if (service.isLoadingReview) {
            return const Center(child: CircularProgressIndicator());
          }
          // 2. Trạng thái Lỗi
          if (service.reviewError != null) {
            debugPrint('Lỗi: ${service.reviewError}');
            return Center(child: Text('Lỗi: ${service.reviewError}'));
          }
          // 3. Trạng thái chưa có dữ liệu
          if (service.currentReview == null) {
            return const Center(child: Text('Không tải được lịch sử bài làm.'));
          }

          final review = service.currentReview!;

          // 4. Khi có dữ liệu -> Hiển thị ListView
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: review.questions.length + 1, // +1 cho header kết quả
            itemBuilder: (context, index) {
              if (index == 0) {
                // Hiển thị Header Kết quả
                return _buildReviewHeader(review);
              }
              // Hiển thị các câu hỏi
              final question = review.questions[index - 1];
              return _buildQuestionCard(question, index);
            },
          );
        },
      ),
    );
  }

  Widget _buildReviewHeader(StudentQuizReviewModel review) {
    // ... (Toàn bộ code cũ của bạn giữ nguyên)
    final scoreFormatted = NumberFormat("0.#").format(review.score);
    final totalQuestions = review.questions.length;
    final correctCount =
        review.questions
            .where((q) => q.isCorrect)
            .length; // 👈 Sửa nhỏ: Đếm trực tiếp
    final formattedDate = DateFormat(
      'HH:mm, dd/MM/yyyy',
    ).format(review.submittedAt.toLocal());

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            review.quizTitle,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Đã nộp lúc: $formattedDate',
            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFE5E7EB)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'ĐIỂM SỐ',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$scoreFormatted / 10',
                      style: const TextStyle(
                        fontSize: 28,
                        color: Color(0xFF2563EB),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'CÂU ĐÚNG',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$correctCount / $totalQuestions',
                      style: const TextStyle(
                        fontSize: 28,
                        color: Color(0xFF059669),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(
    StudentQuestionReviewModel question,
    int questionNumber,
  ) {
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
          // Header câu hỏi (Giữ nguyên)
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

          // Phần nội dung câu trả lời
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAudioPlayer(question),

                if (question.questionType == 'MULTIPLE_CHOICE')
                  ...question.options.asMap().entries.map((entry) {
                    final optIndex = entry.key;
                    final option = entry.value;
                    return _buildOptionTile(
                      option: option,
                      optionIndex: optIndex,
                      // ✅ FIX LỖI: selectedOptionId có thể là String (Guid) hoặc int,
                      // nhưng Model nên parse thành String để an toàn.
                      // Ở đây ta truyền vào widget dưới dạng String?
                      selectedOptionId: question.selectedOptionId?.toString(),
                    );
                  })
                else if (question.questionType == 'FILL_IN_THE_BLANK' ||
                    question.questionType == 'DICTATION')
                  _buildWritingReview(question)
                else
                  Text(
                    "Lỗi: Loại câu hỏi '${question.questionType}' không được hỗ trợ.",
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ 6. THÊM WIDGET MỚI CHO AUDIO
  Widget _buildAudioPlayer(StudentQuestionReviewModel question) {
    // Không hiển thị gì nếu không có audio
    if (question.audioUrl == null || question.audioUrl!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(
              Icons.play_circle_fill_rounded,
              color: Colors.purple,
              size: 40,
            ),
            onPressed: () async {
              try {
                await _audioPlayer.setUrl(question.audioUrl!);
                _audioPlayer.play();
              } catch (e) {
                /* Xử lý lỗi */
              }
            },
          ),
          const Text(
            "Phát lại file nghe",
            style: TextStyle(color: Colors.purple, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // ✅ 7. THÊM WIDGET MỚI CHO BÀI VIẾT
  Widget _buildWritingReview(StudentQuestionReviewModel question) {
    final bool isCorrect = question.isCorrect;
    final Color color = isCorrect ? Colors.green.shade700 : Colors.red.shade700;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Câu trả lời của bạn
          Text(
            'Câu trả lời của bạn:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  question.studentAnswerText ?? '(Bạn đã bỏ trống)',
                  style: TextStyle(
                    fontSize: 16,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          // Nếu sai, hiển thị đáp án đúng
          if (!isCorrect) ...[
            const Divider(height: 24),
            const Text(
              'Đáp án đúng:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              question.correctAnswerText ?? '(Không có đáp án)',
              style: TextStyle(
                fontSize: 16,
                color: Colors.green.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required StudentOptionReviewModel option,
    required int optionIndex,
    required String? selectedOptionId, // 👈 ĐỔI TỪ int? SANG String?
  }) {
    final optionLabel = String.fromCharCode(65 + optionIndex);

    // --- Logic xác định trạng thái ---
    bool isCorrect = option.isCorrect;
    // 👈 So sánh String ID thay vì int
    bool isSelected = option.optionId.toString() == selectedOptionId;

    Color borderColor;
    Color backgroundColor;
    Widget? trailingIcon;
    Color labelColor;

    if (isCorrect) {
      // Đáp án ĐÚNG
      borderColor = const Color(0xFF10B981);
      backgroundColor = const Color(0xFFF0FDF4);
      labelColor = const Color(0xFF059669);
      trailingIcon = const Icon(Icons.check_circle, color: Color(0xFF10B981));
    } else if (isSelected) {
      // Đáp án SV chọn (SAI)
      borderColor = const Color(0xFFEF4444);
      backgroundColor = const Color(0xFFFEF2F2);
      labelColor = const Color(0xFFDC2626);
      trailingIcon = const Icon(Icons.cancel, color: Color(0xFFEF4444));
    } else {
      // Đáp án khác
      borderColor = const Color(0xFFE5E7EB);
      backgroundColor = const Color(0xFFFAFBFC);
      labelColor = const Color(0xFFD1D5DB);
      trailingIcon = null;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor, width: 2),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: labelColor,
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
                  fontWeight:
                      (isCorrect || isSelected)
                          ? FontWeight.w600
                          : FontWeight.w500,
                  height: 1.5,
                ),
              ),
            ),
            if (trailingIcon != null) ...[
              const SizedBox(width: 8),
              trailingIcon,
            ],
          ],
        ),
      ),
    );
  }
}
