import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/data/models/flashcard_session_model.dart';
import 'package:mobile/data/models/module_details_model.dart';
import 'package:mobile/data/models/pronunciation_result_model.dart';
import 'package:mobile/services/student/student_flashcard_service.dart';
import 'package:mobile/services/student/student_profile_service.dart';
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
  final Map<int, GlobalKey<FlipCardState>> _cardKeys = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    Future.microtask(() {
      context.read<StudentFlashcardService>().fetchFlashcards(widget.lesson.id);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<StudentFlashcardService>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.lesson.title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
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

  Widget _buildBody(StudentFlashcardService service) {
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
                    style: TextStyle(
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
          _buildFeedbackSection(service.lastResult!)
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
                  Icon(Icons.info_rounded, size: 18, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
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
              () => context.read<StudentFlashcardService>().playAudio(),
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
                  style: TextStyle(
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
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kết quả chấm điểm',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getScoreColor(result.accuracyScore).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _getScoreColor(
                      result.accuracyScore,
                    ).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  '${result.accuracyScore.toStringAsFixed(0)}/100',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _getScoreColor(result.accuracyScore),
                  ),
                ),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Phiên âm: ${result.phoneticWord.isNotEmpty ? result.phoneticWord : 'N/A'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...result.wordResults.map((word) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '"${word.word}"',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                '${word.accuracyScore.round()}%',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _getScoreColor(word.accuracyScore),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children:
                                word.phonemeResults.map((phoneme) {
                                  return Tooltip(
                                    message:
                                        'Lỗi: ${phoneme.errorType}\nĐiểm: ${phoneme.accuracyScore.toStringAsFixed(0)}%',
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
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
                                          fontSize: 11,
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
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return AppColors.success;
    if (score >= 50) return AppColors.warning;
    return AppColors.danger;
  }

  Widget _buildRecordingControls(StudentFlashcardService service) {
    if (service.status != FlashcardStatus.loaded || service.totalCards == 0) {
      return const SizedBox.shrink();
    }
    final profileService = context.read<StudentProfileService>();

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
        border: Border(top: BorderSide(color: AppColors.borderColor, width: 1)),
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
                      // <-- Thêm async
                      // Gọi hàm (hàm này giờ trả về int?)
                      final int? newStreak = await service.toggleRecording();

                      // Nếu có kết quả streak mới, cập nhật ProfileService
                      if (newStreak != null && mounted) {
                        profileService.updateLocalStreak(newStreak);
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
                    ? SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: const AlwaysStoppedAnimation(Colors.white),
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

  void _goToNextCard(StudentFlashcardService service) {
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
      ToastHelper.showSucess('Bạn đã hoàn thành bài học!');
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) context.pop();
      });
    }
  }
}
