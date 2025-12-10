import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/data/models/student_quiz_models.dart';
import 'package:mobile/screens/student/quiz/student_quiz_view_model.dart';
import 'package:mobile/shared_widgets/admin/common_empty_state.dart';
import 'package:provider/provider.dart';

class StudentQuizListScreen extends StatefulWidget {
  final String classId;
  final String className;

  const StudentQuizListScreen({
    super.key,
    required this.classId,
    required this.className,
  });

  @override
  State<StudentQuizListScreen> createState() => _StudentQuizListScreenState();
}

class _StudentQuizListScreenState extends State<StudentQuizListScreen> {
  static const Color primaryColor = Color(0xFF3B82F6);
  static const Color textDark = Color(0xFF1E293B);
  final List<Map<String, String>> _filters = [
    {'label': 'Tất cả', 'value': 'ALL'},
    {'label': 'Đọc hiểu', 'value': 'READING'},
    {'label': 'Nghe', 'value': 'LISTENING'},
    {'label': 'Điền từ', 'value': 'WRITING'},
    {'label': 'Viết luận', 'value': 'ESSAY'},
    {'label': 'Ngữ pháp', 'value': 'GRAMMAR'},
  ];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentQuizViewModel>().loadQuizList(
        widget.classId,
        filter: 'ALL',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final quizService = context.watch<StudentQuizViewModel>();
    final quizzes = quizService.quizzes;
    final isLoading = quizService.isLoadingList;
    final currentFilter = quizService.currentFilter;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Danh sách bài tập',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                color: textDark,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: textDark,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Modern Filter Section
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Icon(
                        Icons.filter_list_rounded,
                        size: 18,
                        color: Color(0xFF64748B),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Lọc theo kỹ năng',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 42,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _filters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final filter = _filters[index];
                      final isSelected = filter['value'] == currentFilter;

                      return _ModernFilterChip(
                        label: filter['label']!,
                        isSelected: isSelected,
                        onTap: () {
                          context.read<StudentQuizViewModel>().loadQuizList(
                            widget.classId,
                            filter: filter['value']!,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE5E7EB)),

          Expanded(
            child:
                isLoading
                    ? const Center(
                      child: CircularProgressIndicator(color: primaryColor),
                    )
                    : quizzes.isEmpty
                    ? const CommonEmptyState(
                      title: 'Không có bài tập',
                      subtitle: 'Không tìm thấy bài tập nào cho mục này.',
                      icon: Icons.filter_list_off, // Icon filter trống
                    )
                    : ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: quizzes.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final quiz = quizzes[index];
                        // Dùng hàm _buildQuizCard có sẵn của bạn
                        return SlideInAnimation(
                          index: index,
                          child: _buildQuizCard(context, quiz),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillIcon(String skillType) {
    IconData iconData;
    String tooltip;
    Color color;

    switch (skillType.toUpperCase()) {
      // 1. NGHE
      case 'LISTENING':
        iconData = Icons.headphones_rounded;
        tooltip = 'Luyện Nghe (Listening)';
        color = Colors.purple.shade600;
        break;

      // 2. VIẾT LUẬN (AI CHẤM) - Quan trọng
      case 'ESSAY':
        iconData = Icons.history_edu_rounded; // Icon cây bút lông/viết
        tooltip = 'Viết Luận (Essay)';
        color = Colors.pink.shade600; // Màu hồng đậm cho nổi bật
        break;

      // 3. VIẾT ĐIỀN TỪ
      case 'WRITING':
      case 'DICTATION':
        iconData = Icons.edit_note_rounded;
        tooltip = 'Điền từ (Writing)';
        color = Colors.orange.shade700;
        break;

      // 4. NGỮ PHÁP
      case 'GRAMMAR':
        iconData = Icons.spellcheck_rounded; // Icon kiểm tra chính tả/ngữ pháp
        tooltip = 'Ngữ pháp (Grammar)';
        color = Colors.teal.shade600; // Màu xanh cổ vịt
        break;

      // 5. ĐỌC HIỂU (Mặc định)
      case 'READING':
      default:
        iconData = Icons.menu_book_rounded;
        tooltip = 'Đọc hiểu (Reading)';
        color = Colors.blue.shade600;
        break;
    }

    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
          ), // Thêm viền nhẹ cho đẹp
        ),
        child: Icon(iconData, color: color, size: 24),
      ),
    );
  }

  Widget _buildQuizCard(BuildContext context, StudentQuizListModel quiz) {
    final bool isSubmitted = quiz.status == 'Submitted';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      // Dùng Container + Decoration thay vì Card để đổ bóng đẹp hơn
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap:
              isSubmitted
                  ? () async {
                    await context.pushNamed(
                      'student-quiz-review',
                      extra: {'classId': widget.classId, 'quizId': quiz.id},
                    );
                    // Reload quiz list after returning from review
                    if (context.mounted) {
                      context.read<StudentQuizViewModel>().loadQuizList(
                        widget.classId,
                        filter:
                            context.read<StudentQuizViewModel>().currentFilter,
                      );
                    }
                  }
                  : () async {
                    await context.pushNamed(
                      'student-quiz-taking',
                      extra: {
                        'classId': widget.classId,
                        'quizId': quiz.id,
                        'quizTitle': quiz.title,
                      },
                    );
                    // Reload quiz list after returning from taking
                    if (context.mounted) {
                      context.read<StudentQuizViewModel>().loadQuizList(
                        widget.classId,
                        filter:
                            context.read<StudentQuizViewModel>().currentFilter,
                      );
                    }
                  },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSkillIcon(quiz.skillType),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildStatusTag(quiz.status),
                              // Có thể thêm date nếu cần
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            quiz.title,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111827),
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFF3F4F6)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _buildInfoChip(
                          Icons.timer_outlined,
                          '${quiz.timeLimitMinutes}p',
                          Colors.blueGrey,
                        ),
                        const SizedBox(width: 12),
                        _buildInfoChip(
                          Icons.help_outline_rounded,
                          '${quiz.questionCount} câu',
                          Colors.blueGrey,
                        ),
                      ],
                    ),
                    _buildActionButton(context, quiz, isSubmitted),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusTag(String status) {
    final bool isSubmitted = status == 'Submitted';
    final Color color =
        isSubmitted ? const Color(0xFF10B981) : const Color(0xFFF59E0B);
    final String text = isSubmitted ? 'Đã nộp bài' : 'Chưa hoàn thành';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color.withValues(alpha: 0.7)),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: color.withValues(alpha: 0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    StudentQuizListModel quiz,
    bool isSubmitted,
  ) {
    // TRƯỜNG HỢP 1: CHƯA LÀM -> Hiện nút "Làm bài"
    if (!isSubmitted) {
      return SizedBox(
        height: 34,
        child: ElevatedButton(
          onPressed: () async {
            await context.pushNamed(
              'student-quiz-taking',
              extra: {
                'classId': widget.classId,
                'quizId': quiz.id,
                'quizTitle': quiz.title,
              },
            );
            // Reload quiz list after returning from taking
            if (context.mounted) {
              context.read<StudentQuizViewModel>().loadQuizList(
                widget.classId,
                filter: context.read<StudentQuizViewModel>().currentFilter,
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3B82F6), // Primary Blue
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Làm bài',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    // TRƯỜNG HỢP 2: ĐÃ LÀM -> Hiện 2 nút "Xem lại" và "Làm lại"
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Nút Xem lại (Nhẹ nhàng)
        InkWell(
          onTap: () async {
            await context.pushNamed(
              'student-quiz-review',
              extra: {'classId': widget.classId, 'quizId': quiz.id},
            );
            // Reload quiz list after returning from review
            if (context.mounted) {
              context.read<StudentQuizViewModel>().loadQuizList(
                widget.classId,
                filter: context.read<StudentQuizViewModel>().currentFilter,
              );
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Xem lại',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Nút Làm lại (Nổi bật hơn chút)
        InkWell(
          onTap: () async {
            // Chuyển hướng sang làm bài (như mới)
            await context.pushNamed(
              'student-quiz-taking',
              extra: {
                'classId': widget.classId,
                'quizId': quiz.id,
                'quizTitle': quiz.title,
              },
            );
            // Reload quiz list after returning from retaking
            if (context.mounted) {
              context.read<StudentQuizViewModel>().loadQuizList(
                widget.classId,
                filter: context.read<StudentQuizViewModel>().currentFilter,
              );
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF), // Xanh rất nhạt
              border: Border.all(
                color: const Color(0xFFBFDBFE),
              ), // Viền xanh nhạt
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.refresh_rounded, size: 14, color: Color(0xFF2563EB)),
                SizedBox(width: 4),
                Text(
                  'Làm lại',
                  style: TextStyle(
                    color: Color(0xFF2563EB), // Xanh đậm
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ✅ WIDGET ANIMATION TỰ TẠO (Không cần thư viện ngoài)
// Widget này giúp item trượt từ dưới lên và hiện dần ra
class SlideInAnimation extends StatefulWidget {
  final int index;
  final Widget child;

  const SlideInAnimation({super.key, required this.index, required this.child});

  @override
  State<SlideInAnimation> createState() => _SlideInAnimationState();
}

class _SlideInAnimationState extends State<SlideInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500), // Thời gian chạy hiệu ứng
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2), // Bắt đầu từ vị trí thấp hơn 20%
      end: Offset.zero, // Kết thúc ở vị trí gốc
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutQuint, // Curve mượt mà (nhanh lúc đầu, chậm dần)
      ),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0, // Bắt đầu trong suốt
      end: 1.0, // Kết thúc rõ nét
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Tạo độ trễ dựa trên index để các item xuất hiện lần lượt
    Future.delayed(Duration(milliseconds: widget.index * 80), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(position: _slideAnimation, child: widget.child),
    );
  }
}

// ✅ MODERN FILTER CHIP WIDGET
class _ModernFilterChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModernFilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_ModernFilterChip> createState() => _ModernFilterChipState();
}

class _ModernFilterChipState extends State<_ModernFilterChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) {
        _scaleController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _scaleController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            gradient:
                widget.isSelected
                    ? const LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                    : null,
            color: widget.isSelected ? null : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  widget.isSelected
                      ? Colors.transparent
                      : const Color(0xFFE2E8F0),
              width: 1.5,
            ),
            boxShadow:
                widget.isSelected
                    ? [
                      BoxShadow(
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                    : [],
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.w600,
              color: widget.isSelected ? Colors.white : const Color(0xFF64748B),
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}
