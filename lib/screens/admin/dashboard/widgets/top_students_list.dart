import 'package:flutter/material.dart';
import 'package:mobile/data/models/admin_top_student_model.dart';
import 'package:mobile/screens/admin/dashboard/admin_dashboard_view_model.dart';
import 'package:mobile/shared_widgets/avatar_widget.dart';
import 'package:provider/provider.dart';

class TopStudentsList extends StatelessWidget {
  const TopStudentsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminDashboardViewModel>(
      builder: (context, viewModel, child) {
        final students = viewModel.topStudents;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.emoji_events_rounded,
                      color: Colors.blue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Top 5 Sinh viên (XP)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            (viewModel.isLoading && students.isEmpty)
                ? const SizedBox(
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.blue),
                  ),
                )
                : (students.isEmpty)
                ? const SizedBox(
                  height: 150,
                  child: Center(
                    child: Text(
                      "Chưa có dữ liệu sinh viên.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
                : Column(
                  children:
                      students
                          .map((student) => _buildStudentTile(student))
                          .toList(),
                ),
          ],
        );
      },
    );
  }

  Widget _buildStudentTile(AdminTopStudentModel student) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          AvatarWidget(
            avatarUrl: student.avatarUrl,
            name: student.name,
            radius: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E3A8A),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Level: ${student.level}",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.stars_rounded,
                  color: Colors.orange.shade700,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${student.experiencePoints} XP',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontSize: 12,
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
}
