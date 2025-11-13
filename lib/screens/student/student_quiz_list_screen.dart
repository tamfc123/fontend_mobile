import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/data/models/student_quiz_list_model.dart';
import 'package:mobile/services/student/student_quiz_service.dart';
import 'package:provider/provider.dart';

class StudentQuizListScreen extends StatefulWidget {
  final int classId;
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
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        elevation: 0,
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
                child: Text(
                  'Lỗi tải danh sách: ${service.listError}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (service.quizzes.isEmpty) {
            return const Center(
              child: Text(
                'Không có bài tập nào trong lớp này.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => service.fetchQuizList(widget.classId),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Danh sách bài tập',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                ...service.quizzes.map((quiz) => _buildQuizCard(context, quiz)),
              ],
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
        padding: const EdgeInsets.all(8), // Kích thước icon
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(iconData, color: color, size: 22),
      ),
    );
  }

  /// Xây dựng UI cho một thẻ bài tập (Đã cập nhật)
  Widget _buildQuizCard(BuildContext context, StudentQuizListModel quiz) {
    final bool isSubmitted = quiz.status == 'Submitted';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      color: Colors.white,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSkillIcon(quiz.skillType),
                const SizedBox(width: 12),
                // Tiêu đề
                Expanded(
                  child: Text(
                    'Bài tập: ${quiz.title}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                // Tag trạng thái
                _buildStatusTag(quiz.status),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            const SizedBox(height: 16),

            // Hàng 2: Thông tin chi tiết (Giữ nguyên)
            Row(
              children: [
                _buildInfoChip(
                  Icons.timer_outlined,
                  '${quiz.timeLimitMinutes} phút',
                  Colors.blue,
                ),
                const SizedBox(width: 12),
                _buildInfoChip(
                  Icons.quiz_outlined,
                  '${quiz.questionCount} câu hỏi',
                  Colors.green,
                ),
              ],
            ),

            // 👇 HÀNG 3: NÚT HÀNH ĐỘNG (MỚI)
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [_buildActionButton(context, quiz, isSubmitted)],
            ),
          ],
        ),
      ),
    );
  }

  /// Widget cho tag trạng thái (Pending/Submitted)
  Widget _buildStatusTag(String status) {
    final bool isSubmitted = status == 'Submitted';
    final Color color = isSubmitted ? Colors.green : Colors.orange;
    final String text = isSubmitted ? 'Đã nộp' : 'Chưa làm';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  /// Widget cho các chip thông tin (Icon + Text)
  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // SỬA Ở ĐÂY: Bỏ .shade700
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              // SỬA Ở ĐÂY: Bỏ .shade800
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Xây dựng nút hành động (Bắt đầu / Xem lịch sử)
  Widget _buildActionButton(
    BuildContext context,
    StudentQuizListModel quiz,
    bool isSubmitted,
  ) {
    if (isSubmitted) {
      // --- NÚT XEM LỊCH SỬ ---
      return TextButton.icon(
        icon: const Icon(Icons.history, size: 18, color: Colors.blueGrey),
        label: const Text(
          'Xem lịch sử',
          style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        onPressed: () {
          context.pushNamed(
            'student-quiz-review',
            extra: {'classId': widget.classId, 'quizId': quiz.id},
          );
        },
      );
    } else {
      // --- NÚT BẮT ĐẦU LÀM ---
      return ElevatedButton.icon(
        icon: const Icon(Icons.play_arrow_rounded, size: 20),
        label: const Text('Bắt đầu làm'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade600, // Màu xanh dương
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () {
          // Logic điều hướng (giống như cũ)
          context.pushNamed(
            'student-quiz-taking',
            extra: {
              'classId': widget.classId,
              'quizId': quiz.id,
              'quizTitle': quiz.title,
            },
          );
        },
      );
    }
  }
}
