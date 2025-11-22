import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/data/models/student_quiz_list_model.dart';
import 'package:mobile/services/student/student_quiz_service.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentQuizService>().fetchQuizList(widget.classId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F2937),
        centerTitle: true,
        title: Text(
          widget.className,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE5E7EB), height: 1),
        ),
      ),
      body: Consumer<StudentQuizService>(
        builder: (context, service, child) {
          if (service.isLoadingList) {
            return const Center(child: CircularProgressIndicator());
          }

          if (service.listError != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Lỗi tải danh sách:\n${service.listError}',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => service.fetchQuizList(widget.classId),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (service.quizzes.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.quiz_outlined,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Không có bài tập nào trong lớp này.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // ✅ SỬ DỤNG ListView.builder ĐỂ CÓ INDEX CHO ANIMATION
          return RefreshIndicator(
            onRefresh: () => service.fetchQuizList(widget.classId),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              // +1 để dành chỗ cho cái Header Text "Danh sách bài tập"
              itemCount: service.quizzes.length + 1,
              itemBuilder: (context, index) {
                // Item đầu tiên là Header Text
                if (index == 0) {
                  return const Padding(
                    padding: EdgeInsets.only(bottom: 12, left: 4),
                    child: Text(
                      'Danh sách bài tập',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  );
                }

                // Các item tiếp theo là Quiz Card
                final quizIndex = index - 1;
                final quiz = service.quizzes[quizIndex];

                // ✅ BỌC TRONG WIDGET ANIMATION TỰ TẠO (SlideInAnimation)
                return SlideInAnimation(
                  index: quizIndex, // Truyền index để tính độ trễ
                  child: _buildQuizCard(context, quiz),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSkillIcon(String skillType) {
    IconData iconData;
    String tooltip;
    Color color;

    switch (skillType.toUpperCase()) {
      case 'LISTENING':
        iconData = Icons.headphones_rounded;
        tooltip = 'Bài tập Nghe';
        color = Colors.purple.shade600;
        break;
      case 'WRITING':
      case 'DICTATION':
        iconData = Icons.edit_note_rounded;
        tooltip = 'Bài tập Viết';
        color = Colors.orange.shade700;
        break;
      case 'READING':
      default:
        iconData = Icons.menu_book_rounded;
        tooltip = 'Bài tập Đọc / Ngữ pháp';
        color = Colors.blue.shade600;
        break;
    }

    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
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
            color: Colors.blue.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
                  ? () {
                    context.pushNamed(
                      'student-quiz-review',
                      extra: {'classId': widget.classId, 'quizId': quiz.id},
                    );
                  }
                  : () {
                    context.pushNamed(
                      'student-quiz-taking',
                      extra: {
                        'classId': widget.classId,
                        'quizId': quiz.id,
                        'quizTitle': quiz.title,
                      },
                    );
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
        Icon(icon, size: 16, color: color.withOpacity(0.7)),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: color.withOpacity(0.9),
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
    if (isSubmitted) {
      return SizedBox(
        height: 32,
        child: OutlinedButton(
          onPressed: () {
            context.pushNamed(
              'student-quiz-review',
              extra: {'classId': widget.classId, 'quizId': quiz.id},
            );
          },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            side: BorderSide(color: Colors.grey.shade300),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
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
      );
    } else {
      return SizedBox(
        height: 32,
        child: ElevatedButton(
          onPressed: () {
            context.pushNamed(
              'student-quiz-taking',
              extra: {
                'classId': widget.classId,
                'quizId': quiz.id,
                'quizTitle': quiz.title,
              },
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 58, 116, 241),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Làm bài',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }
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
