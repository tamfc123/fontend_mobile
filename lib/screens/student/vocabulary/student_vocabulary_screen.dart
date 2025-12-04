import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/data/models/vocabulary_levels_model.dart';
import 'package:mobile/screens/student/vocabulary/student_vocabulary_view_model.dart';
import 'package:mobile/utils/color_helper.dart';
import 'package:mobile/utils/toast_helper.dart';
import 'package:provider/provider.dart';

class VocabularyStudentScreen extends StatefulWidget {
  const VocabularyStudentScreen({super.key});

  @override
  State<VocabularyStudentScreen> createState() =>
      _VocabularyStudentScreenState();
}

class _VocabularyStudentScreenState extends State<VocabularyStudentScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<StudentVocabularyViewModel>().loadVocabularyLevels();
    });
  }

  // Tìm tên level dựa trên số level (int)
  String _getCurrentLevelName(
    int currentLevelNum,
    List<LevelInfoModel> levels,
  ) {
    try {
      return levels.firstWhere((level) => level.level == currentLevelNum).name;
    } catch (e) {
      return 'Sơ cấp'; // Fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    final levelService = context.watch<StudentVocabularyViewModel>();
    final data = levelService.vocabularyData;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F2937),
        centerTitle: true,
        elevation: 0,
        title: const Text(
          'Lộ trình Từ vựng',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
      ),
      body: _buildBody(levelService, data),
    );
  }

  Widget _buildBody(
    StudentVocabularyViewModel service,
    VocabularyLevelsModel? data,
  ) {
    if (service.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (service.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(service.error!, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => service.loadVocabularyLevels(),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (data == null || data.levels.isEmpty) {
      return const Center(child: Text('Chưa có dữ liệu cấp độ'));
    }

    // So sánh 'level' (int) với 'currentUserLevel' (int)
    int currentUserIndex = data.levels.indexWhere(
      (l) => l.level == data.currentUserLevel,
    );

    if (currentUserIndex == -1) {
      if (data.currentUserLevel <= 1) {
        currentUserIndex = 0;
      } else {
        currentUserIndex = data.levels.length - 1;
      }
    }

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  'Cấp độ hiện tại: ${_getCurrentLevelName(data.currentUserLevel, data.levels)} (Lv.${data.currentUserLevel})',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Hoàn thành bài học và tham gia lớp để mở khóa cấp độ mới!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Danh sách Level
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final level = data.levels[index];

              // ✅ ANIMATION 1: Xuất hiện lần lượt (Staggered List)
              return _AnimatedListItem(
                index: index,
                child: _LevelCard(
                  level: level,
                  itemIndex: index,
                  userLevelIndex: currentUserIndex,
                ),
              );
            }, childCount: data.levels.length),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }
}

// ✅ WIDGET ANIMATION: Xuất hiện từ từ (Slide Up + Fade In)
class _AnimatedListItem extends StatelessWidget {
  final int index;
  final Widget child;

  const _AnimatedListItem({required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      // Delay dựa trên index để tạo hiệu ứng thác đổ
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutQuad,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Padding(padding: const EdgeInsets.only(bottom: 0), child: child),
    );
  }
}

// ✅ LEVEL CARD (Đã tách ra Stateful để xử lý Animation Rung Lắc & Nhún)
class _LevelCard extends StatefulWidget {
  final LevelInfoModel level;
  final int itemIndex;
  final int userLevelIndex;

  const _LevelCard({
    required this.level,
    required this.itemIndex,
    required this.userLevelIndex,
  });

  @override
  State<_LevelCard> createState() => _LevelCardState();
}

class _LevelCardState extends State<_LevelCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _shakeOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.05, // Nhún xuống 5%
    );
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Hàm thực hiện rung lắc (Shake)
  Future<void> _shakeCard() async {
    for (int i = 0; i < 3; i++) {
      setState(() => _shakeOffset = 5.0);
      await Future.delayed(const Duration(milliseconds: 50));
      setState(() => _shakeOffset = -5.0);
      await Future.delayed(const Duration(milliseconds: 50));
    }
    setState(() => _shakeOffset = 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final level = widget.level;

    // ✅ Logic khóa từ Backend
    final bool isLocked = level.isLocked;
    final bool isCompleted = widget.itemIndex < widget.userLevelIndex;
    final bool isCurrent = widget.itemIndex == widget.userLevelIndex;

    // Lấy màu từ Helper
    final colorHelper = ColorHelper();
    final config = colorHelper.getLevelConfig(level.level);
    final Color themeColor = config['color'];
    final List<Color> gradient = config['gradient'];
    final IconData iconData = config['icon'];
    final String levelName = config['name'];

    final displayColor = isLocked ? Colors.grey : themeColor;
    final displayGradient =
        isLocked ? [Colors.grey.shade300, Colors.grey.shade400] : gradient;

    // Scale factor cho hiệu ứng nhún
    final scale = 1.0 - _controller.value;

    return Transform.translate(
      offset: Offset(_shakeOffset, 0), // Xử lý rung lắc
      child: Transform.scale(
        scale: scale, // Xử lý nhún
        child: GestureDetector(
          onTapDown: (_) => _controller.forward(),
          onTapUp: (_) {
            _controller.reverse();
            if (isLocked) {
              _shakeCard(); // Rung nếu bị khóa
              // ✅ Dùng ToastHelper thay cho SnackBar
              ToastHelper.showError(
                'Cấp độ này đang bị khóa. Hãy tham gia lớp học Level ${level.level} để mở khóa!',
              );
            } else {
              // Delay nhẹ để animation chạy xong rồi mới chuyển màn hình
              Future.delayed(const Duration(milliseconds: 100), () {
                context.pushNamed('levelContent', extra: level);
              });
            }
          },
          onTapCancel: () => _controller.reverse(),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: displayColor.withValues(alpha: isLocked ? 0.1 : 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // Background mờ
                  Positioned(
                    right: -20,
                    top: -20,
                    child: Icon(
                      iconData,
                      size: 120,
                      color: displayColor.withValues(alpha: 0.05),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        // 1. Icon Box
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: displayGradient,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow:
                                isLocked
                                    ? []
                                    : [
                                      BoxShadow(
                                        color: displayColor.withValues(
                                          alpha: 0.4,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                          ),
                          child: Icon(
                            isLocked ? Icons.lock_rounded : iconData,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),

                        // 2. Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: displayColor.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'LEVEL ${level.level}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: displayColor,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  if (isCurrent) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'HIỆN TẠI',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                level.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color:
                                      isLocked
                                          ? Colors.grey.shade600
                                          : const Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                levelName,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 3. Arrow
                        if (!isLocked)
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 18,
                            color: Colors.grey.shade300,
                          ),
                      ],
                    ),
                  ),

                  // Overlay nếu Completed
                  if (isCompleted && !isCurrent)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
