import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart'; // ✅ 1. THÊM IMPORT NÀY
import 'package:mobile/data/models/student_quiz_take_model.dart';
// ✅ 2. THÊM IMPORT CHO MODEL NỘP BÀI
import 'package:mobile/data/models/student_submission_model.dart';
import 'package:mobile/services/student/student_quiz_service.dart';
import 'package:provider/provider.dart';

class StudentQuizTakingScreen extends StatefulWidget {
  final int classId;
  final int quizId;
  final String quizTitle;

  const StudentQuizTakingScreen({
    super.key,
    required this.classId,
    required this.quizId,
    required this.quizTitle,
  });

  @override
  State<StudentQuizTakingScreen> createState() =>
      _StudentQuizTakingScreenState();
}

class _StudentQuizTakingScreenState extends State<StudentQuizTakingScreen> {
  // ✅ 3. THAY ĐỔI STATE ĐỂ HỖ TRỢ CẢ 2 LOẠI CÂU TRẢ LỜI
  // State cho Trắc nghiệm (Multiple Choice)
  final Map<int, int> _selectedOptionAnswers = {};
  // State cho Điền từ (Fill in the blank)
  final Map<int, TextEditingController> _textAnswers = {};

  // State cho bộ đếm thời gian
  Timer? _timer;
  int _remainingSeconds = 0;

  // State
  bool _isSubmitting = false;

  // ✅ Thêm audio player cho bài Nghe
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _fetchDataAndStartTimer();
  }

  void _fetchDataAndStartTimer() async {
    // 1. Tải chi tiết quiz
    await context.read<StudentQuizService>().fetchQuizForTaking(
      widget.classId,
      widget.quizId,
    );

    // 2. Sau khi tải xong
    if (mounted) {
      final quiz = context.read<StudentQuizService>().currentQuiz;
      if (quiz != null) {
        // ✅ 4. KHỞI TẠO CÁC TEXT CONTROLLER CHO BÀI VIẾT
        for (var question in quiz.questions) {
          if (question.questionType == 'FILL_IN_THE_BLANK' ||
              question.questionType == 'DICTATION') {
            _textAnswers[question.id] = TextEditingController();
          }
        }

        // 3. Khởi tạo thời gian và bắt đầu timer
        setState(() {
          _remainingSeconds = quiz.timeLimitMinutes * 60;
        });
        _startTimer();
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        _handleSubmit(autoSubmit: true);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose(); // ✅ Dọn dẹp audio player

    // ✅ Dọn dẹp tất cả các TextEditingController
    for (var controller in _textAnswers.values) {
      controller.dispose();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Kiểm tra mounted trước khi read
        context.read<StudentQuizService>().clearQuizDetail();
      }
    });
    super.dispose();
  }

  String _formatDuration(int seconds) {
    // ... (Giữ nguyên code)
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  // ✅ 5. CẬP NHẬT HOÀN TOÀN HÀM NỘP BÀI
  Future<void> _handleSubmit({bool autoSubmit = false}) async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });
    _timer?.cancel();

    // 1. Xác nhận (nếu không phải tự động)
    bool confirmed = autoSubmit ? true : await _showConfirmationDialog();

    if (confirmed) {
      try {
        final service = context.read<StudentQuizService>();
        final quiz = service.currentQuiz;
        if (quiz == null) throw Exception("Không tìm thấy bài quiz.");

        // 2. TẠO LIST CÂU TRẢ LỜI (THEO MODEL MỚI)
        List<StudentAnswerInputModel> answersToSend = [];

        for (var question in quiz.questions) {
          // Lấy câu trả lời dựa trên loại câu hỏi
          if (question.questionType == 'MULTIPLE_CHOICE') {
            final int? selectedId = _selectedOptionAnswers[question.id];
            answersToSend.add(
              StudentAnswerInputModel(
                questionId: question.id,
                selectedOptionId: selectedId, // Gửi ID đã chọn (hoặc null)
                answerText: null,
              ),
            );
          } else if (question.questionType == 'FILL_IN_THE_BLANK' ||
              question.questionType == 'DICTATION') {
            final String? text = _textAnswers[question.id]?.text;
            answersToSend.add(
              StudentAnswerInputModel(
                questionId: question.id,
                selectedOptionId: null,
                answerText: text, // Gửi text đã gõ (hoặc null)
              ),
            );
          }
        }

        // 3. GỌI API VỚI LIST MỚI
        final result = await service.submitQuiz(
          widget.classId,
          widget.quizId,
          answersToSend, // 👈 Gửi đi List<StudentAnswerInputModel>
        );

        // Nộp bài thành công
        await _showResultDialog(result);
        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        // Nộp bài thất bại
        await _showErrorDialog(e.toString());
      }
    }

    if (!confirmed && !autoSubmit) {
      _startTimer();
    }

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      appBar: AppBar(
        // ... (Code AppBar giữ nguyên) ...
        title: Text(widget.quizTitle),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Chip(
              avatar: Icon(
                Icons.timer_outlined,
                color: _remainingSeconds < 60 ? Colors.red : Colors.blue,
              ),
              label: Text(
                _formatDuration(_remainingSeconds),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _remainingSeconds < 60 ? Colors.red : Colors.blue,
                ),
              ),
              backgroundColor:
                  _remainingSeconds < 60 ? Colors.red[50] : Colors.blue[50],
            ),
          ),
        ],
      ),
      body: Consumer<StudentQuizService>(
        builder: (context, service, child) {
          if (service.isLoadingDetail) {
            return const Center(child: CircularProgressIndicator());
          }
          if (service.detailError != null) {
            return Center(child: Text('Lỗi: ${service.detailError}'));
          }
          if (service.currentQuiz == null) {
            return const Center(
              child: Text('Không tải được chi tiết bài tập.'),
            );
          }

          final quiz = service.currentQuiz!;

          // ✅ 6. CẬP NHẬT UI CHÍNH
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  // +1 cho Info, +1 cho ReadingPassage (nếu có)
                  itemCount:
                      quiz.questions.length +
                      (quiz.readingPassage != null ? 2 : 1),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _buildQuizInfoSection(quiz);
                    }

                    // ✅ HIỂN THỊ ĐOẠN VĂN (NẾU CÓ)
                    if (quiz.readingPassage != null) {
                      if (index == 1) {
                        return _buildReadingPassage(quiz.readingPassage!);
                      }
                      // Nếu có đoạn văn, index câu hỏi bị lùi 2
                      final question = quiz.questions[index - 2];
                      return _buildQuestionCard(
                        question,
                        index - 1,
                      ); // Số thứ tự
                    }

                    // Nếu không có đoạn văn, index câu hỏi lùi 1
                    final question = quiz.questions[index - 1];
                    return _buildQuestionCard(question, index); // Số thứ tự
                  },
                ),
              ),
              _buildSubmitButton(),
            ],
          );
        },
      ),
    );
  }

  // --- Các Widget con để xây dựng UI ---

  // (Widget này giữ nguyên)
  Widget _buildQuizInfoSection(StudentQuizTakeModel quiz) {
    // ... (Code cũ của bạn giữ nguyên)
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
        ],
      ),
    );
  }

  // ✅ 7. THÊM WIDGET MỚI CHO BÀI ĐỌC
  Widget _buildReadingPassage(String passage) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.blue.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.menu_book_rounded, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                'Reading Passage (Đoạn văn)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Text(
            passage,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF374151),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ 8. THÊM WIDGET MỚI CHO NÚT AUDIO
  Widget _buildAudioPlayer(StudentQuestionModel question) {
    // Không hiển thị gì nếu không có audio
    if (question.audioUrl == null || question.audioUrl!.isEmpty) {
      return const SizedBox.shrink();
    }

    // (Đây là 1 trình phát audio đơn giản, bạn có thể nâng cấp sau)
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
                // Xử lý lỗi
              }
            },
          ),
          const Text(
            "Phát file nghe",
            style: TextStyle(color: Colors.purple, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // ✅ 9. CẬP NHẬT HÀM XÂY DỰNG CÂU HỎI
  Widget _buildQuestionCard(StudentQuestionModel question, int questionNumber) {
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
            // ... (code decoration header) ...
            child: Row(
              // ... (code Row header với số câu hỏi) ...
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ... (code cái vòng tròn xanh) ...
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    question.questionText, // Nội dung câu hỏi
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

          // Nội dung (Trắc nghiệm hoặc Điền từ)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ HIỂN THỊ NÚT AUDIO (NẾU LÀ BÀI NGHE)
                _buildAudioPlayer(question),

                // ✅ HIỂN THỊ LOẠI CÂU HỎI ĐÚNG
                if (question.questionType == 'MULTIPLE_CHOICE')
                  ...question.options.asMap().entries.map((entry) {
                    final optIndex = entry.key;
                    final option = entry.value;
                    return _buildOptionTile(question, option, optIndex);
                  })
                else if (question.questionType == 'FILL_IN_THE_BLANK' ||
                    question.questionType == 'DICTATION')
                  _buildTextFieldInput(question)
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

  // ✅ 10. THÊM WIDGET MỚI CHO BÀI VIẾT (ĐIỀN TỪ)
  Widget _buildTextFieldInput(StudentQuestionModel question) {
    // Lấy controller đã được khởi tạo từ state
    final controller = _textAnswers[question.id];

    if (controller == null) {
      return const Text("Lỗi: Không tìm thấy controller cho câu hỏi này.");
    }

    return TextField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Nhập câu trả lời của bạn',
        hintText: '...',
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Color(0xFFFAFBFC),
      ),
      // (Bạn có thể thêm onSubmitted...)
    );
  }

  // ✅ 11. CẬP NHẬT HÀM NÀY ĐỂ DÙNG STATE MỚI
  Widget _buildOptionTile(
    StudentQuestionModel question,
    StudentOptionModel option,
    int optionIndex,
  ) {
    // 👈 SỬA: Dùng state _selectedOptionAnswers
    final bool isSelected = _selectedOptionAnswers[question.id] == option.id;
    final optionLabel = String.fromCharCode(65 + optionIndex); // A, B, C, D

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          // 👈 SỬA: Cập nhật state _selectedOptionAnswers
          setState(() {
            _selectedOptionAnswers[question.id] = option.id;
          });
        },
        child: Container(
          // ... (Toàn bộ code UI của OptionTile giữ nguyên) ...
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color:
                isSelected ? const Color(0xFFEFF6FF) : const Color(0xFFFAFBFC),
            border: Border.all(
              color:
                  isSelected
                      ? const Color(0xFF2563EB)
                      : const Color(0xFFE5E7EB),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              // ... (Code icon A, B, C, D) ...
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  option.optionText,
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF1F2937),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    height: 1.5,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF2563EB),
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // (Widget nút Submit giữ nguyên)
  Widget _buildSubmitButton() {
    // ... (Code cũ của bạn giữ nguyên)
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed:
                _isSubmitting ? null : () => _handleSubmit(autoSubmit: false),
            icon:
                _isSubmitting
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                    : const Icon(Icons.check_circle_outline),
            label: Text(
              _isSubmitting ? 'Đang nộp bài...' : 'Hoàn thành và Nộp bài',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // --- Dialogs (Giữ nguyên) ---

  Future<bool> _showConfirmationDialog() async {
    // ... (Code cũ của bạn giữ nguyên)
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Xác nhận nộp bài'),
                content: const Text('Bạn có chắc chắn muốn nộp bài không?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Hủy'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Nộp bài'),
                  ),
                ],
              ),
        ) ??
        false;
  }

  Future<void> _showResultDialog(Map<String, dynamic> result) async {
    // ... (Code cũ của bạn giữ nguyên)
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Nộp bài thành công!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kết quả của bạn:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'Số câu đúng: ${result['correctCount']} / ${result['totalQuestions']}',
                ),
                Text('Điểm số: ${result['score']} / 10'),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  Future<void> _showErrorDialog(String error) async {
    // ... (Code cũ của bạn giữ nguyên)
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Nộp bài thất bại'),
            content: Text('Đã xảy ra lỗi: $error'),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Thử lại'),
              ),
            ],
          ),
    );
  }
}
