import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/data/models/vocabulary_levels_model.dart';
import 'package:mobile/data/models/vocabulary_modules_model.dart';
import 'package:mobile/screens/student/vocabulary/student_vocabulary_module_view_model.dart';
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
  static const divider = Color(0xFFCBD5E1);
}

class VocabularyLevelContentScreen extends StatefulWidget {
  final LevelInfoModel level;

  const VocabularyLevelContentScreen({super.key, required this.level});

  @override
  State<VocabularyLevelContentScreen> createState() =>
      _VocabularyLevelContentScreenState();
}

class _VocabularyLevelContentScreenState
    extends State<VocabularyLevelContentScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<StudentVocabularyModuleViewModel>().loadModules(
        widget.level.id,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<StudentVocabularyModuleViewModel>();
    final data = service.modulesData;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.level.name,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.cardBackground,
        foregroundColor: AppColors.textPrimary,
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
      body: _buildBody(service, data),
    );
  }

  Widget _buildBody(
    StudentVocabularyModuleViewModel service,
    VocabularyModulesModel? data,
  ) {
    if (service.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (service.error != null) {
      return Center(child: Text('Lỗi: ${service.error}'));
    }

    if (data == null || data.topics.isEmpty) {
      return const Center(child: Text('Chưa có chủ đề nào'));
    }

    // ✅ TÍNH TOÁN TIẾN ĐỘ TỔNG QUAN
    int totalModules = data.topics.length;
    int totalWords = data.topics.fold(0, (sum, item) => sum + item.totalWords);
    int completedModules =
        data.topics
            .where((m) => m.completedWords >= m.totalWords && m.totalWords > 0)
            .length;

    double overallProgress =
        totalModules > 0 ? completedModules / totalModules : 0.0;
    // ✅ FIX LỖI UNDEFINED NAME: Định nghĩa biến ở đây
    String moduleProgressText = '$completedModules/$totalModules Chủ đề';

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // 1. HEADER CARD (Dashboard style)
        SliverToBoxAdapter(
          child: _buildHeader(
            levelName: widget.level.name,
            totalWords: totalWords,
            moduleProgressText: moduleProgressText,
            overallProgress: overallProgress,
          ),
        ),

        // 2. DANH SÁCH MODULES HEADER
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
                  'Các chương từ vựng',
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

        // 3. DANH SÁCH MODULES (TIMELINE)
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final module = data.topics[index];
              final double progress =
                  module.totalWords == 0
                      ? 0.0
                      : module.completedWords.toDouble() /
                          module.totalWords.toDouble();

              final bool isFirst = index == 0;
              final bool isLast = index == data.topics.length - 1;
              final bool isCompleted = progress >= 1.0; // Tính toán cho Node

              // ✅ FIX LỖI THAM SỐ: Thêm isCompleted vào đây (tổng 7 tham số)
              return _AnimatedListItem(
                index: index,
                child: _buildTimelineItem(
                  context,
                  index + 1,
                  module,
                  progress,
                  isCompleted, // ✅ Tham số thứ 5
                  isFirst,
                  isLast,
                ),
              );
            }, childCount: data.topics.length),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }

  // ✅ WIDGET MỚI: HEADER DASHBOARD
  Widget _buildHeader({
    required String levelName,
    required int totalWords,
    required String moduleProgressText,
    required double overallProgress,
  }) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
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
          // Title & Icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.star_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  levelName, // Tên level
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Progress Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tiến độ Module',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${(overallProgress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: overallProgress,
              minHeight: 8,
              backgroundColor: Colors.black.withOpacity(0.15),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),

          const SizedBox(height: 20),

          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildHeaderStat(Icons.check_circle_outline, moduleProgressText),
              _buildHeaderStat(Icons.language_rounded, '$totalWords Từ vựng'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.8), size: 16),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // --- LESSON TIMELINE ITEMS (Cấu trúc Timeline Node) ---

  // ✅ FIX: Đã thêm tham số isCompleted vào signature
  Widget _buildTimelineItem(
    BuildContext context,
    int number,
    ModuleInfoModel module,
    double progress,
    bool isCompleted, // ✅ THÊM THAM SỐ THỨ 5
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

          // --- CỘT 2: CARD (CÓ ANIMATION NHÚN) ---
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: _AnimatedModuleCard(
                module: module,
                progress: progress,
                completed: isCompleted,
                color: color,
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

// ✅ 1. WIDGET ANIMATION LIST ITEM (Slide Up + Fade In)
class _AnimatedListItem extends StatelessWidget {
  final int index;
  final Widget child;

  const _AnimatedListItem({required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    final int delay = index * 100;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + delay),
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

// ✅ 2. WIDGET MODULE CARD (Có hiệu ứng nhún)
class _AnimatedModuleCard extends StatefulWidget {
  final ModuleInfoModel module;
  final double progress;
  final bool completed;
  final Color color;

  const _AnimatedModuleCard({
    required this.module,
    required this.progress,
    required this.completed,
    required this.color,
  });

  @override
  State<_AnimatedModuleCard> createState() => _AnimatedModuleCardState();
}

class _AnimatedModuleCardState extends State<_AnimatedModuleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.03, // Nhún 3%
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

    return Transform.scale(
      scale: scale,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          context.pushNamed('moduleDetails', extra: widget.module);
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
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      widget.module.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (widget.completed)
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
                        "Đã xong",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Progress
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

              // Footer Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${widget.module.completedWords}/${widget.module.totalWords} từ vựng',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
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
