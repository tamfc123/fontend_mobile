import 'package:flutter/material.dart';
import 'package:mobile/screens/admin/dashboard/admin_dashboard_view_model.dart';
import 'package:mobile/shared_widgets/stat_card.dart';
import 'package:provider/provider.dart';

class DashboardStatsCards extends StatelessWidget {
  const DashboardStatsCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminDashboardViewModel>(
      builder: (context, viewModel, child) {
        final stats = viewModel.stats;

        if (viewModel.isLoading && stats == null) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.blue),
          );
        }
        if (viewModel.error != null) {
          return Center(
            child: Text(
              viewModel.error!,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }
        if (stats == null) {
          return const Center(child: Text('Không có dữ liệu thống kê.'));
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            // Large screen: Use Row (cards expand to fill width)
            if (constraints.maxWidth >= 1200) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Tổng Người Dùng',
                      value: stats.totalUsers.toString(),
                      icon: Icons.group_rounded,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StatCard(
                      title: 'Giáo viên',
                      value: stats.totalTeachers.toString(),
                      icon: Icons.school_rounded,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StatCard(
                      title: 'Sinh viên',
                      value: stats.totalStudents.toString(),
                      icon: Icons.person_rounded,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StatCard(
                      title: 'Lớp học',
                      value: stats.totalClasses.toString(),
                      icon: Icons.class_rounded,
                      color: Colors.purple,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StatCard(
                      title: 'Bài tập',
                      value: stats.totalQuizzes.toString(),
                      icon: Icons.quiz_rounded,
                      color: Colors.red,
                    ),
                  ),
                ],
              );
            }

            // Small screen: Use Wrap (cards wrap to new lines)
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: 200,
                    maxWidth:
                        constraints.maxWidth < 600
                            ? double.infinity
                            : (constraints.maxWidth - 16) / 2,
                  ),
                  child: StatCard(
                    title: 'Tổng Người Dùng',
                    value: stats.totalUsers.toString(),
                    icon: Icons.group_rounded,
                    color: Colors.blue,
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: 200,
                    maxWidth:
                        constraints.maxWidth < 600
                            ? double.infinity
                            : (constraints.maxWidth - 16) / 2,
                  ),
                  child: StatCard(
                    title: 'Giáo viên',
                    value: stats.totalTeachers.toString(),
                    icon: Icons.school_rounded,
                    color: Colors.green,
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: 200,
                    maxWidth:
                        constraints.maxWidth < 600
                            ? double.infinity
                            : (constraints.maxWidth - 16) / 2,
                  ),
                  child: StatCard(
                    title: 'Sinh viên',
                    value: stats.totalStudents.toString(),
                    icon: Icons.person_rounded,
                    color: Colors.orange,
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: 200,
                    maxWidth:
                        constraints.maxWidth < 600
                            ? double.infinity
                            : (constraints.maxWidth - 16) / 2,
                  ),
                  child: StatCard(
                    title: 'Lớp học',
                    value: stats.totalClasses.toString(),
                    icon: Icons.class_rounded,
                    color: Colors.purple,
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: 200,
                    maxWidth:
                        constraints.maxWidth < 600
                            ? double.infinity
                            : (constraints.maxWidth - 16) / 2,
                  ),
                  child: StatCard(
                    title: 'Bài tập',
                    value: stats.totalQuizzes.toString(),
                    icon: Icons.quiz_rounded,
                    color: Colors.red,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
