import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/data/models/flashcard_session_model.dart';
import 'package:mobile/data/models/module_details_model.dart';
import 'package:mobile/data/models/pronunciation_result_model.dart';
import 'package:mobile/screens/student/flashcards/student_flashcard_view_model.dart';
import 'package:mobile/screens/student/profile/student_profile_view_model.dart';
import 'package:mobile/utils/toast_helper.dart';
import 'package:provider/provider.dart';

class AppColors {
  static const primary = Color(0xFF3B82F6);
  static const primaryLight = Color(0xFF60A5FA);
  static const primaryXLight = Color(0xFFEFF6FF);
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFEF4444);
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const background = Color(0xFFF8FAFC);
  static const cardBackground = Color(0xFFFFFFFF);
  static const borderColor = Color(0xFFE2E8F0);
}

class LessonFlashcardsScreen extends StatefulWidget {
  final LessonInfoModel lesson;
  const LessonFlashcardsScreen({super.key, required this.lesson});

  @override
  State<LessonFlashcardsScreen> createState() => _LessonFlashcardsScreenState();
}

class _LessonFlashcardsScreenState extends State<LessonFlashcardsScreen> {
  late PageController _pageController;
  final Map<String, GlobalKey<FlipCardState>> _cardKeys = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    Future.microtask(() {
      context.read<StudentFlashcardViewModel>().loadFlashcards(
        widget.lesson.id,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<StudentFlashcardViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.lesson.title,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.cardBackground,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ),
      body: _buildBody(service),
      bottomNavigationBar: _buildRecordingControls(service),
    );
  }

  Widget _buildBody(StudentFlashcardViewModel service) {
    if (service.status == FlashcardStatus.loading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Đang tải thẻ từ vựng...',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (service.status == FlashcardStatus.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: AppColors.danger,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Lỗi: ${service.error}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    if (service.session == null || service.session!.flashcards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryXLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.library_books_outlined,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Chưa có từ vựng nào',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    service.session!.flashcards.asMap().forEach((index, card) {
      _cardKeys.putIfAbsent(
        card.vocabularyId,
        () => GlobalKey<FlipCardState>(),
      );
    });

    return Column(
      children: [
        // Progress section
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${service.currentIndex + 1}/${service.totalCards}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${((service.currentIndex + 1) / service.totalCards * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (service.currentIndex + 1) / service.totalCards,
                  minHeight: 8,
                  backgroundColor: AppColors.borderColor,
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),
            ],
          ),
        ),

        // Flashcards
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: service.totalCards,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) {
              for (var key in _cardKeys.values) {
                if (key.currentState?.isFront == false) {
                  key.currentState?.toggleCard();
                }
              }
              service.onPageChanged(index);
            },
            itemBuilder: (context, index) {
              final card = service.session!.flashcards[index];
              return _buildFlashcard(card, _cardKeys[card.vocabularyId]!);
            },
          ),
        ),

        // Feedback display
        if (service.lastResult != null)
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: _buildFeedbackSection(service.lastResult!),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryXLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Nhấn nút 🎙️ bên dưới để thu âm và chấm điểm',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // ✅ ĐÃ SỬA LỖI TYPE CASTING Ở ĐÂY
  Widget _buildFeedbackSection(PronunciationResultModel result) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Điểm số
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Kết quả chấm điểm',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getScoreColor(
                      result.accuracyScore,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${result.accuracyScore.round()}/100',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getScoreColor(result.accuracyScore),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderColor),

          // Chi tiết Words & Phonemes
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hiển thị phiên âm nếu có
                if (result.phoneticWord.isNotEmpty) ...[
                  Text(
                    'Phiên âm chuẩn: /${result.phoneticWord}/',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // ✅ SỬA LỖI: Thêm .map<Widget> để ép kiểu về Widget
                ...result.wordResults.map<Widget>((word) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tên từ và điểm
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              word.word,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '${word.accuracyScore.round()}%',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _getScoreColor(word.accuracyScore),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Danh sách Phonemes
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          // ✅ SỬA LỖI: Thêm .map<Widget> để ép kiểu về Widget
                          children:
                              word.phonemeResults.map<Widget>((phoneme) {
                                return Tooltip(
                                  triggerMode: TooltipTriggerMode.tap,
                                  message:
                                      'Lỗi: ${phoneme.errorType}\nĐiểm: ${phoneme.accuracyScore.round()}',
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: phoneme.color.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: phoneme.color.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      '/${phoneme.phoneme}/',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: phoneme.color,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashcard(
    FlashcardItemModel card,
    GlobalKey<FlipCardState> cardKey,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: FlipCard(
        key: cardKey,
        flipOnTouch: true,
        front: _buildCardFace(
          content: card.referenceText,
          phonetic: card.phonetic,
          onPlayAudio:
              () => context.read<StudentFlashcardViewModel>().playAudio(),
        ),
        back: _buildCardFace(content: card.meaning ?? "N/A", isBack: true),
      ),
    );
  }

  Widget _buildCardFace({
    required String content,
    String? phonetic,
    bool isBack = false,
    VoidCallback? onPlayAudio,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:
              isBack
                  ? [AppColors.primaryXLight, AppColors.background]
                  : [Colors.white, AppColors.background.withOpacity(0.3)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              content,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
            if (phonetic != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  phonetic,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            if (onPlayAudio != null) ...[
              const SizedBox(height: 28),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.volume_up_rounded),
                  iconSize: 36,
                  color: AppColors.primary,
                  onPressed: onPlayAudio,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return AppColors.success;
    if (score >= 50) return AppColors.warning;
    return AppColors.danger;
  }

  Widget _buildRecordingControls(StudentFlashcardViewModel service) {
    if (service.status != FlashcardStatus.loaded || service.totalCards == 0) {
      return const SizedBox.shrink();
    }
    final profileService = context.read<StudentProfileViewModel>();

    IconData icon;
    Color color;
    if (service.isAssessing) {
      icon = Icons.hourglass_top_rounded;
      color = Colors.grey;
    } else if (service.isRecording) {
      icon = Icons.stop_rounded;
      color = AppColors.danger;
    } else {
      icon = Icons.mic_rounded;
      color = AppColors.primary;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: const Border(
          top: BorderSide(color: AppColors.borderColor, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment:
            service.lastResult != null &&
                    service.lastResult!.accuracyScore >= 80
                ? MainAxisAlignment.spaceEvenly
                : MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed:
                (service.isAssessing)
                    ? null
                    : () async {
                      final result = await service.toggleRecording();

                      if (result != null && mounted) {
                        profileService.updateLocalStreak(result.newStreak);

                        if (result.expGained > 0 || result.coinsGained > 0) {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder:
                                (ctx) => _RewardDialog(
                                  exp: result.expGained,
                                  coins: result.coinsGained,
                                ),
                          );
                        } else if (result.accuracyScore < 85) {
                          ToastHelper.showWarning(
                            "Cố lên! Đạt 85 điểm để nhận thưởng.",
                          );
                        }
                      }
                    },
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(20),
              elevation: 4,
              disabledBackgroundColor: Colors.grey.shade300,
            ),
            child:
                (service.isAssessing)
                    ? const SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                    : Icon(icon, size: 32),
          ),

          if (service.lastResult != null &&
              service.lastResult!.accuracyScore >= 80)
            ElevatedButton.icon(
              onPressed: () => _goToNextCard(service),
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Tiếp theo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
              ),
            ),
        ],
      ),
    );
  }

  void _goToNextCard(StudentFlashcardViewModel service) {
    var currentCardKey = _cardKeys[service.currentCard?.vocabularyId];
    if (currentCardKey?.currentState?.isFront == false) {
      currentCardKey?.currentState?.toggleCard();
    }

    if (service.currentIndex < service.totalCards - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      ToastHelper.showSuccess('Bạn đã hoàn thành bài học!');
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) context.pop();
      });
    }
  }
}

class _RewardDialog extends StatefulWidget {
  final int exp;
  final int coins;

  const _RewardDialog({required this.exp, required this.coins});

  @override
  State<_RewardDialog> createState() => _RewardDialogState();
}

class _RewardDialogState extends State<_RewardDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("🎉", style: TextStyle(fontSize: 60)),
              const SizedBox(height: 16),
              const Text(
                "Tuyệt vời!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Phát âm của bạn rất chuẩn.",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 24,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryXLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 32,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "+${widget.exp} EXP",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.grey.shade300,
                    ),
                    Column(
                      children: [
                        const Icon(
                          Icons.monetization_on_rounded,
                          color: Colors.orange,
                          size: 32,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "+${widget.coins} Xu",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Nhận thưởng"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
