import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/data/models/module_details_model.dart';
import 'package:mobile/data/models/vocabulary_modules_model.dart';
import 'package:mobile/services/student/student_vocabulary_lesson_service.dart';
import 'package:provider/provider.dart';

class AppColors {
  static const primary = Color(0xFF3B82F6);
  static const primaryLight = Color(0xFF60A5FA);
  static const primaryXLight = Color(0xFFEFF6FF);
  static const success = Color(0xFF10B981);
  static const successLight = Color(0xFFD1FAE5);
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const background = Color(0xFFF8FAFC);
  static const cardBackground = Color(0xFFFFFFFF);
  static const borderColor = Color(0xFFE2E8F0);
}

class VocabularyModuleDetailsScreen extends StatefulWidget {
  final ModuleInfoModel module;

  const VocabularyModuleDetailsScreen({super.key, required this.module});

  @override
  State<VocabularyModuleDetailsScreen> createState() =>
      _VocabularyModuleDetailsScreenState();
}

class _VocabularyModuleDetailsScreenState
    extends State<VocabularyModuleDetailsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<StudentVocabularyLessonService>().fetchLessons(
        widget.module.id,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final lessonService = context.watch<StudentVocabularyLessonService>();
    final data = lessonService.lessonData;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
        title: const Text(
          'Chi tiết chủ đề',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: AppColors.textPrimary,
          ),
        ),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: _buildBody(lessonService, data),
    );
  }

  Widget _buildBody(
    StudentVocabularyLessonService service,
    ModuleDetailsModel? data,
  ) {
    if (service.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (service.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(service.error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => service.fetchLessons(widget.module.id),
              child: const Text("Thử lại"),
            ),
          ],
        ),
      );
    }

    if (data == null || data.lessons.isEmpty) {
      return const Center(child: Text('Chưa có bài học nào'));
    }

    // Tính toán tổng quan tiến độ từ danh sách bài học
    int totalWords = 0;
    int completedWords = 0;
    int completedLessons = 0;

    for (var lesson in data.lessons) {
      totalWords += lesson.totalWords;
      completedWords += lesson.completedWords;
      if (lesson.completedWords >= lesson.totalWords && lesson.totalWords > 0) {
        completedLessons++;
      }
    }

    double overallProgress = totalWords > 0 ? completedWords / totalWords : 0.0;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // 1. HEADER CARD (Thông tin chủ đề & Tiến độ)
        SliverToBoxAdapter(
          child: _buildHeader(
            widget.module.name,
            data.lessons.length,
            completedLessons,
            overallProgress,
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Các bài từ vựng',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),

        // 2. DANH SÁCH BÀI HỌC (TIMELINE)
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final lesson = data.lessons[index];

              final double lessonProgress =
                  (lesson.totalWords > 0)
                      ? (lesson.completedWords / lesson.totalWords)
                      : 0.0;
              final bool isCompleted = lessonProgress >= 1.0;

              final bool isFirst = index == 0;
              final bool isLast = index == data.lessons.length - 1;

              return _AnimatedListItem(
                index: index,
                child: _buildTimelineItem(
                  context,
                  index + 1,
                  lesson,
                  lessonProgress,
                  isCompleted,
                  isFirst,
                  isLast,
                ),
              );
            }, childCount: data.lessons.length),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }

  // ✅ HEADER MỚI: Tạo điểm nhấn cho màn hình
  Widget _buildHeader(
    String moduleName,
    int totalLessons,
    int completedLessons,
    double progress,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF60A5FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tên chủ đề
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.library_books_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  moduleName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Thanh tiến độ tổng quan
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tiến độ chủ đề',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.black.withOpacity(0.1),
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Thống kê nhỏ
          Row(
            children: [
              _buildHeaderStat(
                Icons.check_circle_outline,
                '$completedLessons/$totalLessons hoàn thành',
              ),
              const SizedBox(width: 16),
              _buildHeaderStat(Icons.school_outlined, 'Học từ vựng'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.9), size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.95),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ... (Giữ nguyên _buildTimelineItem, _buildTimelineNode, _AnimatedLessonCard, _AnimatedListItem như cũ)

  Widget _buildTimelineItem(
    BuildContext context,
    int number,
    LessonInfoModel lesson,
    double progress,
    bool isCompleted,
    bool isFirst,
    bool isLast,
  ) {
    final color = isCompleted ? AppColors.success : AppColors.primary;
    const double nodeSize = 40.0;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- CỘT 1: TIMELINE ---
          SizedBox(
            width: nodeSize,
            child: Column(
              children: [
                Expanded(
                  child:
                      isFirst
                          ? const SizedBox()
                          : Container(width: 2, color: color.withOpacity(0.3)),
                ),
                _buildTimelineNode(number, isCompleted, color, nodeSize),
                Expanded(
                  child:
                      isLast
                          ? const SizedBox()
                          : Container(width: 2, color: color.withOpacity(0.3)),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // --- CỘT 2: CARD ---
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: _AnimatedLessonCard(
                lesson: lesson,
                progress: progress,
                isCompleted: isCompleted,
                color: color,
                moduleId: widget.module.id,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineNode(
    int number,
    bool completed,
    Color color,
    double size,
  ) {
    return Container(
      width: size,
      height: size,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.cardBackground,
        border: Border.all(color: color.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child:
            completed
                ? Icon(Icons.check_rounded, color: color, size: 20)
                : Text(
                  '$number',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
      ),
    );
  }
}

class _AnimatedListItem extends StatelessWidget {
  final int index;
  final Widget child;

  const _AnimatedListItem({required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOutQuad,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
        );
      },
      child: child,
    );
  }
}

class _AnimatedLessonCard extends StatefulWidget {
  final LessonInfoModel lesson;
  final double progress;
  final bool isCompleted;
  final Color color;
  final String moduleId;

  const _AnimatedLessonCard({
    required this.lesson,
    required this.progress,
    required this.isCompleted,
    required this.color,
    required this.moduleId,
  });

  @override
  State<_AnimatedLessonCard> createState() => _AnimatedLessonCardState();
}

class _AnimatedLessonCardState extends State<_AnimatedLessonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.03,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = 1.0 - _controller.value;
    final lesson = widget.lesson;

    return Transform.scale(
      scale: scale,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) async {
          _controller.reverse();
          await context.pushNamed('lessonFlashcards', extra: lesson);
          if (context.mounted) {
            context.read<StudentVocabularyLessonService>().fetchLessons(
              widget.moduleId,
            );
          }
        },
        onTapCancel: () => _controller.reverse(),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.color.withOpacity(0.15),
              width: 1.5,
            ),
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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      lesson.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (widget.isCompleted)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        "Xong",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: widget.progress.clamp(0.0, 1.0),
                  minHeight: 6,
                  backgroundColor: Colors.grey.shade100,
                  valueColor: AlwaysStoppedAnimation(widget.color),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.language_rounded,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${lesson.completedWords}/${lesson.totalWords} từ',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${(widget.progress * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: widget.color,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
