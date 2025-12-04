import 'package:flutter/material.dart';
import 'package:mobile/data/models/admin_recent_teacher_model.dart';
import 'package:mobile/screens/admin/dashboard/admin_dashboard_view_model.dart';
import 'package:provider/provider.dart';

class RecentTeachersList extends StatelessWidget {
  const RecentTeachersList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminDashboardViewModel>(
      builder: (context, viewModel, child) {
        final teachers = viewModel.recentTeachers;

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
                      Icons.person_add_rounded,
                      color: Colors.blue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Giáo viên mới đăng ký',
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
            (viewModel.isLoading && teachers.isEmpty)
                ? const SizedBox(
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.blue),
                  ),
                )
                : (teachers.isEmpty)
                ? const SizedBox(
                  height: 150,
                  child: Center(
                    child: Text(
                      "Không có giáo viên nào mới đăng ký.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
                : Column(
                  children:
                      teachers
                          .map((teacher) => _buildTeacherTile(teacher))
                          .toList(),
                ),
          ],
        );
      },
    );
  }

  Widget _buildTeacherTile(AdminRecentTeacherModel teacher) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.blue.withValues(alpha: 0.12),
            child: Text(
              teacher.name.isNotEmpty ? teacher.name[0].toUpperCase() : 'T',
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  teacher.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E3A8A),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  teacher.email,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color:
                  teacher.isActive
                      ? Colors.green.shade50
                      : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color:
                    teacher.isActive
                        ? Colors.green.shade200
                        : Colors.orange.shade200,
              ),
            ),
            child: Text(
              teacher.isActive ? 'Đã kích hoạt' : 'Chưa kích hoạt',
              style: TextStyle(
                color:
                    teacher.isActive
                        ? Colors.green.shade700
                        : Colors.orange.shade700,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
