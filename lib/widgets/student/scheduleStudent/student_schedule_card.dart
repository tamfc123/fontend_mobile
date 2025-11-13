import 'package:flutter/material.dart';
import 'package:mobile/data/models/student_schedule_model.dart';

class StudentScheduleCard extends StatelessWidget {
  final StudentScheduleModel schedule;

  const StudentScheduleCard({super.key, required this.schedule});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // Handle tap if needed
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header với tên lớp và môn học
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getColorByDay(schedule.dayOfWeek),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          schedule.courseName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          schedule.className,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getColorByDay(
                        schedule.dayOfWeek,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      schedule.dayOfWeek,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getColorByDay(schedule.dayOfWeek),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Thông tin chi tiết
              Row(
                children: [
                  // Thời gian
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.access_time,
                      label: 'Thời gian',
                      value: '${schedule.startTime} - ${schedule.endTime}',
                      color: _getColorByDay(schedule.dayOfWeek),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Phòng học
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.room,
                      label: 'Phòng',
                      value: schedule.room ?? 'Chưa rõ',
                      color: _getColorByDay(schedule.dayOfWeek),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Giáo viên
              _buildInfoItem(
                icon: Icons.person,
                label: 'Giáo viên',
                value: schedule.teacherName ?? 'Chưa rõ',
                color: _getColorByDay(schedule.dayOfWeek),
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isFullWidth = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child:
          isFullWidth
              ? Row(
                children: [
                  Icon(icon, size: 16, color: color),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ),
                ],
              )
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, size: 16, color: color),
                      const SizedBox(width: 6),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ],
              ),
    );
  }

  Color _getColorByDay(String day) {
    switch (day) {
      case 'Thứ 2':
        return const Color(0xFF1976D2); // Blue
      case 'Thứ 3':
        return const Color(0xFF388E3C); // Green
      case 'Thứ 4':
        return const Color(0xFFFF9800); // Orange
      case 'Thứ 5':
        return const Color(0xFF7B1FA2); // Purple
      case 'Thứ 6':
        return const Color(0xFF00ACC1); // Cyan
      case 'Thứ 7':
        return const Color(0xFF00695C); // Teal
      case 'Chủ nhật':
        return const Color(0xFFD32F2F); // Red
      default:
        return const Color(0xFF1976D2);
    }
  }
}
