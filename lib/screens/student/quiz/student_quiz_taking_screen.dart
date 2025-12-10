import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mobile/data/models/student_quiz_models.dart';
import 'package:mobile/screens/student/quiz/student_quiz_view_model.dart';
import 'package:mobile/shared_widgets/student/confirm_exit_quiz_dialog.dart';
import 'package:mobile/shared_widgets/student/confirm_submit_quiz_dialog.dart';
import 'package:mobile/shared_widgets/student/reward_dialog.dart';
import 'package:mobile/utils/toast_helper.dart';
import 'package:provider/provider.dart';

class StudentQuizTakingScreen extends StatefulWidget {
  final String classId;
  final String quizId;
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
  // State quản lý câu trả lời
  final Map<String, dynamic> _userAnswers = {};
  final Map<String, TextEditingController> _textControllers = {};

  // Timer
  Timer? _timer;
  int _secondsRemaining = 0;
  bool _isSubmitting = false;

  // Audio Player Chung (Cho bài Listening tổng)
  final AudioPlayer _mainAudioPlayer = AudioPlayer();
  bool _isMainAudioLoaded = false;

  // Map quản lý Audio Player cho từng câu hỏi riêng lẻ
  final Map<String, AudioPlayer> _questionAudioPlayers = {};

  static const Color primaryBlue = Color(0xFF3B82F6);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadQuizData();
    });
  }

  Future<void> _loadQuizData() async {
    await context.read<StudentQuizViewModel>().loadQuizForTaking(
      widget.classId,
      widget.quizId,
    );

    final quiz = context.read<StudentQuizViewModel>().currentQuiz;
    if (quiz != null) {
      // 1. Thiết lập Timer
      if (quiz.timeLimitMinutes > 0) {
        setState(() {
          _secondsRemaining = quiz.timeLimitMinutes * 60;
          _startTimer();
        });
      }

      // 2. Load Audio Chung (nếu có)
      if (quiz.skillType == 'LISTENING' &&
          quiz.mediaUrl != null &&
          quiz.mediaUrl!.isNotEmpty) {
        try {
          debugPrint("🔊 Loading quiz audio: ${quiz.mediaUrl}");
          await _mainAudioPlayer.setUrl(quiz.mediaUrl!);
          setState(() => _isMainAudioLoaded = true);
          debugPrint("✅ Quiz audio loaded successfully");
        } catch (e) {
          debugPrint("❌ Lỗi load audio chung: $e");
          if (mounted) {
            ToastHelper.showError(
              "Không thể tải file nghe. Vui lòng kiểm tra kết nối.",
            );
          }
        }
      }

      // 3. Khởi tạo Controller cho các câu hỏi nhập liệu (Writing/Essay/Dictation)
      for (var q in quiz.questions) {
        if (q.questionType != 'MULTIPLE_CHOICE') {
          _textControllers[q.id] = TextEditingController();
        }
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _timer?.cancel();
        _handleSubmit(isTimeOut: true);
      }
    });
  }

  // Hàm dừng tất cả các player đang chạy để tránh chồng âm thanh
  void _stopAllOtherPlayers(String? currentPlayingId) {
    // Dừng player chung
    if (currentPlayingId != 'main' && _mainAudioPlayer.playing) {
      _mainAudioPlayer.pause();
    }

    // Dừng các player con
    _questionAudioPlayers.forEach((id, player) {
      if (id != currentPlayingId && player.playing) {
        player.pause();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();

    // Dispose tất cả player
    _mainAudioPlayer.dispose();
    for (var player in _questionAudioPlayers.values) {
      player.dispose();
    }

    for (var controller in _textControllers.values) {
      controller.dispose();
    }

    // Clear data trong service khi thoát
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<StudentQuizViewModel>().clearQuizDetail();
    });

    super.dispose();
  }

  // --- LOGIC THOÁT MÀN HÌNH (Back Button) ---
  Future<bool> _onWillPop() async {
    if (_isSubmitting) return false;

    bool shouldExit = false;

    await showDialog(
      context: context,
      builder:
          (context) => ConfirmExitQuizDialog(
            onConfirmExit: () {
              shouldExit = true;
            },
          ),
    );

    return shouldExit;
  }

  // --- LOGIC NỘP BÀI ---
  Future<void> _handleSubmit({bool isTimeOut = false}) async {
    if (_isSubmitting) return;

    if (!isTimeOut) {
      bool shouldSubmit = false;

      await showDialog(
        context: context,
        builder:
            (ctx) => ConfirmSubmitQuizDialog(
              onConfirmSubmit: () {
                shouldSubmit = true;
              },
            ),
      );

      if (!shouldSubmit) return;
    }

    setState(() => _isSubmitting = true);
    _timer?.cancel();
    _stopAllOtherPlayers(null); // Dừng mọi âm thanh

    final quiz = context.read<StudentQuizViewModel>().currentQuiz;
    if (quiz == null) return;

    Map<String, dynamic>? result;

    // 🟢 PHÂN LOẠI LOGIC NỘP BÀI: ESSAY vs BÀI THƯỜNG
    if (quiz.skillType == 'ESSAY') {
      // --- LOGIC ESSAY (AI CHẤM) ---
      String content = "";
      if (quiz.questions.isNotEmpty) {
        final qId = quiz.questions.first.id;
        content = _userAnswers[qId] ?? "";
      }

      if (content.trim().isEmpty) {
        ToastHelper.showError("Bài viết không được để trống!");
        setState(() => _isSubmitting = false);
        return;
      }

      result = await context.read<StudentQuizViewModel>().submitWritingQuiz(
        widget.classId,
        widget.quizId,
        content,
      );
    } else {
      // --- LOGIC THƯỜNG (TRẮC NGHIỆM / ĐIỀN TỪ) ---
      final List<StudentAnswerInputModel> answers = [];
      for (var q in quiz.questions) {
        final userAnswer = _userAnswers[q.id];
        if (userAnswer == null) continue;

        if (q.questionType == 'MULTIPLE_CHOICE') {
          answers.add(
            StudentAnswerInputModel(
              questionId: q.id,
              selectedOptionId: userAnswer as String,
            ),
          );
        } else {
          answers.add(
            StudentAnswerInputModel(
              questionId: q.id,
              answerText: userAnswer as String,
            ),
          );
        }
      }

      result = await context.read<StudentQuizViewModel>().submitQuiz(
        widget.classId,
        widget.quizId,
        answers,
      );
    }

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (result != null) {
        // ✅ XỬ LÝ HIỂN THỊ REWARD POPUP
        await _handleRewardPopup(result);

        // Chuyển trang sau khi đóng popup
        if (mounted) {
          // Pop màn hình làm bài trước
          context.pop();
          // Sau đó push màn hình review
          context.pushNamed(
            'student-quiz-review',
            extra: {'classId': widget.classId, 'quizId': widget.quizId},
          );
        }
      }
    }
  }

  Future<void> _handleRewardPopup(Map<String, dynamic> result) async {
    final reward = result['reward'];

    if (reward != null) {
      final int xp = reward['xp'] ?? 0;
      final int coins = reward['coins'] ?? 0;
      final String msg = reward['msg'] ?? "";

      if (xp > 0) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (ctx) => RewardDialog(
                exp: xp,
                coins: coins,
                message: msg.isNotEmpty ? msg : "Bạn đã làm rất tốt!",
                expLabel: 'XP',
              ),
        );
      } else {
        final score = result['score'];
        ToastHelper.showWarning(msg.isNotEmpty ? msg : "Điểm số: $score");
      }
    }
  }

  String _formatTime(int seconds) {
    final int min = seconds ~/ 60;
    final int sec = seconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<StudentQuizViewModel>();
    final quiz = service.currentQuiz;
    final isLoading = service.isLoadingDetail;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (await _onWillPop()) {
          if (context.mounted) context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close, size: 24),
            onPressed: () async {
              if (await _onWillPop()) {
                if (context.mounted) context.pop();
              }
            },
          ),
          title: Column(
            children: [
              const Text('Làm bài thi', style: TextStyle(fontSize: 16)),
              if (quiz != null && quiz.timeLimitMinutes > 0)
                Text(
                  _formatTime(_secondsRemaining),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _secondsRemaining < 60 ? Colors.red : Colors.white,
                  ),
                ),
            ],
          ),
          centerTitle: true,
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
          actions: [
            TextButton(
              onPressed: () => _handleSubmit(),
              child: const Text(
                'NỘP BÀI',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        body:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : quiz == null
                ? Center(child: Text(service.detailError ?? 'Lỗi tải đề'))
                : Column(
                  children: [
                    // Context Area (Reading/Listening chung)
                    if (_shouldShowContextArea(quiz))
                      Container(
                        height: MediaQuery.of(context).size.height * 0.25,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: _buildContextContent(quiz),
                      ),

                    // Danh sách câu hỏi
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: quiz.questions.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 20),
                        itemBuilder: (context, index) {
                          return _buildQuestionItem(
                            index,
                            quiz.questions[index],
                          );
                        },
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  bool _shouldShowContextArea(StudentQuizTakeModel quiz) {
    return (quiz.skillType == 'READING' && quiz.readingPassage != null) ||
        (quiz.skillType == 'LISTENING' && quiz.mediaUrl != null);
  }

  Widget _buildContextContent(StudentQuizTakeModel quiz) {
    if (quiz.skillType == 'READING') {
      return SingleChildScrollView(
        child: Text(
          quiz.readingPassage ?? '',
          style: const TextStyle(
            fontSize: 16,
            height: 1.5,
            color: Colors.black87,
          ),
        ),
      );
    } else if (quiz.skillType == 'LISTENING') {
      // Audio Player Chung
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.headphones, size: 40, color: primaryBlue),
          const SizedBox(height: 8),
          const Text("File nghe chung", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          if (!_isMainAudioLoaded)
            const CircularProgressIndicator()
          else
            StreamBuilder<PlayerState>(
              stream: _mainAudioPlayer.playerStateStream,
              builder: (context, snapshot) {
                final playing = snapshot.data?.playing ?? false;
                return IconButton(
                  icon: Icon(
                    playing ? Icons.pause_circle : Icons.play_circle,
                    size: 48,
                    color: primaryBlue,
                  ),
                  onPressed: () {
                    if (playing) {
                      _mainAudioPlayer.pause();
                    } else {
                      _stopAllOtherPlayers(
                        'main',
                      ); // Dừng các con để chạy cái chính
                      _mainAudioPlayer.play();
                    }
                  },
                );
              },
            ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildQuestionItem(int index, StudentQuestionModel question) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Câu ${index + 1}',
                  style: const TextStyle(
                    color: primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ✅ HIỂN THỊ AUDIO RIÊNG NẾU CÓ
          if (question.audioUrl != null && question.audioUrl!.isNotEmpty)
            _buildMiniAudioPlayer(question.audioUrl!, question.id),

          Text(
            question.questionText,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),

          if (question.questionType == 'MULTIPLE_CHOICE')
            _buildMultipleChoiceOptions(question)
          else
            _buildTextInput(question),
        ],
      ),
    );
  }

  Widget _buildMiniAudioPlayer(String url, String questionId) {
    // Tạo player mới nếu chưa có
    final player = _questionAudioPlayers.putIfAbsent(
      questionId,
      () => AudioPlayer(),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple.shade100),
      ),
      child: Row(
        children: [
          const Icon(Icons.volume_up, size: 20, color: Colors.purple),
          const SizedBox(width: 8),
          const Text(
            "Nghe câu hỏi",
            style: TextStyle(
              color: Colors.purple,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const Spacer(),
          StreamBuilder<PlayerState>(
            stream: player.playerStateStream,
            builder: (context, snapshot) {
              final playing = snapshot.data?.playing ?? false;
              final processingState = snapshot.data?.processingState;

              if (processingState == ProcessingState.loading ||
                  processingState == ProcessingState.buffering) {
                return const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                );
              }

              return IconButton(
                icon: Icon(
                  playing ? Icons.pause_circle_filled : Icons.play_circle_fill,
                  color: Colors.purple,
                  size: 32,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () async {
                  try {
                    if (playing) {
                      await player.pause();
                    } else {
                      _stopAllOtherPlayers(questionId); // Dừng cái khác
                      if (player.processingState == ProcessingState.idle) {
                        debugPrint("🔊 Loading question audio: $url");
                        await player.setUrl(url);
                      }
                      await player.play();
                    }
                  } catch (e) {
                    debugPrint("❌ Question audio error: $e");
                    ToastHelper.showError("Không thể phát audio câu hỏi");
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMultipleChoiceOptions(StudentQuestionModel question) {
    return Column(
      children:
          question.options.map((option) {
            final isSelected = _userAnswers[question.id] == option.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _userAnswers[question.id] = option.id;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? primaryBlue.withValues(alpha: 0.05)
                            : Colors.white,
                    border: Border.all(
                      color: isSelected ? primaryBlue : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: isSelected ? primaryBlue : Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          option.optionText,
                          style: TextStyle(
                            fontWeight:
                                isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                            color: isSelected ? primaryBlue : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildTextInput(StudentQuestionModel question) {
    if (!_textControllers.containsKey(question.id)) {
      _textControllers[question.id] = TextEditingController();
    }

    // Nếu là bài Essay thì cho phép nhập nhiều dòng
    final isEssay = question.questionType == 'ESSAY';

    return TextField(
      controller: _textControllers[question.id],
      onChanged: (value) {
        _userAnswers[question.id] = value;
      },
      maxLines: isEssay ? 10 : 1, // Essay 10 dòng
      minLines: isEssay ? 5 : 1,
      decoration: InputDecoration(
        hintText:
            isEssay
                ? 'Viết bài luận của bạn vào đây...'
                : 'Nhập câu trả lời...',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }
}
