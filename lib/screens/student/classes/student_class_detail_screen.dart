import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/data/models/student_class_model.dart';
import 'package:mobile/screens/student/classes/student_class_detail_view_model.dart';
import 'package:mobile/screens/student/classes/widgets/module_expansion_item.dart';
import 'package:provider/provider.dart';

class StudentClassDetailScreen extends StatefulWidget {
  final StudentClassModel studentClassModel;

  const StudentClassDetailScreen({super.key, required this.studentClassModel});

  @override
  State<StudentClassDetailScreen> createState() =>
      _StudentClassDetailScreenState();
}

class _StudentClassDetailScreenState extends State<StudentClassDetailScreen> {
  // Palette màu đồng bộ
  static const Color primaryBlue = Color(0xFF3B82F6);
  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF1E293B);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentClassDetailViewModel>().fetchModules(
        widget.studentClassModel.classId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentClassDetailViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: bgLight,
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: textDark,
            elevation: 0,
            centerTitle: true,
            title: const Text(
              'Chi tiết lớp học',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                color: textDark,
              ),
            ),
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // 1. HEADER CARD (Thông tin lớp)
                // Thêm animation fade in nhẹ cho header
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value.clamp(
                        0.0,
                        1.0,
                      ), // ✅ FIX: Clamp giá trị an toàn
                      child: Transform.translate(
                        offset: Offset(0, -20 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: _buildClassHeader(),
                ),

                const SizedBox(height: 20),

                // 2. BÀI TẬP BUTTON - Full width, nổi bật
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _AnimatedActionCard(
                    icon: Icons.assignment_rounded,
                    title: 'Xem bài tập',
                    subtitle: 'Danh sách bài tập của lớp',
                    color: const Color(0xFFF59E0B), // Orange
                    delay: 100,
                    isFullWidth: true,
                    onTap: () {
                      context.pushNamed(
                        'student-quiz-list',
                        extra: widget.studentClassModel,
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // 3. MODULE LIST HEADER
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 24,
                        decoration: BoxDecoration(
                          color: primaryBlue,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Nội dung bài học',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 4. MODULE LIST CONTENT (Có animation trượt lên)
                _buildModuleList(viewModel),

                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- WIDGETS CON ---

  Widget _buildClassHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF60A5FA)], // Blue Gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.studentClassModel.className,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.studentClassModel.courseName,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  'GV: ${widget.studentClassModel.teacherName}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleList(StudentClassDetailViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(color: primaryBlue),
        ),
      );
    }

    if (viewModel.error != null) {
      return Center(
        child: Text(
          'Lỗi: ${viewModel.error}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (viewModel.modules.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(Icons.inbox_rounded, size: 60, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                'Chưa có nội dung bài học',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: viewModel.modules.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final module = viewModel.modules[index];

        // ✅ ÁP DỤNG ANIMATION XUẤT HIỆN (Đã fix lỗi)
        return _AnimatedListItem(
          index: index,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ModuleExpansionItem(module: module, index: index),
            ),
          ),
        );
      },
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
      curve: Curves.easeOutQuad, // Curve này an toàn, không vượt quá 1.0
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value.clamp(0.0, 1.0), // ✅ FIX: Kẹp giá trị cho chắc ăn
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

// ✅ 2. WIDGET ACTION CARD ĐỘNG (Có hiệu ứng nhún + Xuất hiện)
class _AnimatedActionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color color;
  final VoidCallback onTap;
  final int delay;
  final bool isFullWidth;

  const _AnimatedActionCard({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.color,
    required this.onTap,
    this.delay = 0,
    this.isFullWidth = false,
  });

  @override
  State<_AnimatedActionCard> createState() => _AnimatedActionCardState();
}

class _AnimatedActionCardState extends State<_AnimatedActionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.05, // Nhún 5%
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

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500 + widget.delay),
      curve: Curves.easeOutBack, // Curve này sẽ vọt quá 1.0
      builder: (context, value, child) {
        return Transform.scale(
          scale: value * scale,
          child: Opacity(
            // 🔴 ĐÂY LÀ CHỖ SỬA LỖI QUAN TRỌNG NHẤT
            // Vì easeOutBack sẽ làm value > 1.0, nên phải .clamp(0.0, 1.0)
            opacity: value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onTap();
        },
        onTapCancel: () => _controller.reverse(),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: widget.isFullWidth ? 20 : 20,
              horizontal: widget.isFullWidth ? 20 : 16,
            ),
            child:
                widget.isFullWidth
                    ? Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: widget.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            widget.icon,
                            color: widget.color,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              if (widget.subtitle != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  widget.subtitle!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: widget.color,
                          size: 20,
                        ),
                      ],
                    )
                    : Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: widget.color.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            widget.icon,
                            color: widget.color,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: const Color(
                              0xFF1E293B,
                            ).withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
          ),
        ),
      ),
    );
  }
}
