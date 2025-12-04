import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/screens/teacher/dashboard/teacher_dashboard_view_model.dart';
import 'package:mobile/shared_widgets/admin/base_dashboard_card.dart';

class UpcomingScheduleList extends StatelessWidget {
  final TeacherDashboardViewModel viewModel;
  static const Color primaryBlue = Colors.blue;

  const UpcomingScheduleList({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return BaseDashboardCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChartTitle('Lịch dạy sắp tới'),
          const Divider(height: 24),
          if (viewModel.upcomingSchedules.isEmpty)
            const Center(child: Text('Không có lịch dạy nào sắp tới.')),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: viewModel.upcomingSchedules.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final schedule = viewModel.upcomingSchedules[index];
              return ListTile(
                leading: const Icon(Icons.calendar_month, color: primaryBlue),
                title: Text(
                  schedule.className,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${schedule.courseName}\n'
                  // Format ngày giờ theo 'vi'
                  '${DateFormat('EEE, dd/MM - HH:mm', 'vi').format(schedule.startTime.toLocal())} | P: ${schedule.roomName}',
                ),
                isThreeLine: true,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChartTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E3A8A),
      ),
    );
  }
}

class MyClassesList extends StatelessWidget {
  final TeacherDashboardViewModel viewModel;

  const MyClassesList({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return BaseDashboardCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChartTitle('Các lớp học của tôi (Top 5)'),
          const Divider(height: 24),
          if (viewModel.myClasses.isEmpty)
            const Center(child: Text('Bạn chưa phụ trách lớp học nào.')),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: viewModel.myClasses.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final classItem = viewModel.myClasses[index];
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.school)),
                title: Text(
                  classItem.className,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(classItem.courseName),
                trailing: Text(
                  '${classItem.studentCount} HV',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChartTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E3A8A),
      ),
    );
  }
}
