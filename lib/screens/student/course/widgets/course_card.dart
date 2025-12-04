import 'package:flutter/material.dart';
import 'package:mobile/data/models/course_model.dart';
import 'package:mobile/utils/color_helper.dart';

class CourseCard extends StatelessWidget {
  final CourseModel course;
  final VoidCallback onTap;

  const CourseCard({super.key, required this.course, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorHelper = ColorHelper();
    final levelConfig = colorHelper.getLevelConfig(course.requiredLevel);
    final levelColor = levelConfig['color'] as Color;
    final levelText = levelConfig['name'] as String;
    final levelIcon = levelConfig['icon'] as IconData;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24), // Bo góc lớn hơn -> Hiện đại
        border: Border.all(color: Colors.grey.shade100), // Viền siêu mỏng
        boxShadow: [
          BoxShadow(
            color: const Color(
              0xFF475569,
            ).withValues(alpha: 0.08), // Shadow màu xám xanh hiện đại
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- HEADER: ICON & TITLE ---
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Course Icon Box
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: levelColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: levelColor.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                      child: Icon(levelIcon, color: levelColor, size: 28),
                    ),
                    const SizedBox(width: 16),

                    // 2. Title & Level Badge
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Level Badge (Capsule style)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: levelColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Level $levelText',
                              style: TextStyle(
                                color: levelColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Course Name
                          Text(
                            course.name,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B), // Slate 800
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

                // --- DESCRIPTION (Optional) ---
                if (course.description != null &&
                    course.description!.isNotEmpty) ...[
                  Text(
                    course.description!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                ],

                // --- DIVIDER ---
                Divider(height: 1, color: Colors.grey.shade100),
                const SizedBox(height: 16),

                // --- FOOTER: STATS & ACTION ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Stats Row
                    Row(
                      children: [
                        _buildMiniStat(
                          Icons.access_time_rounded,
                          '${course.durationInWeeks} tuần',
                          Colors.blue.shade400,
                        ),
                        const SizedBox(width: 16),
                        _buildMiniStat(
                          Icons.monetization_on_rounded,
                          '${course.rewardCoins}',
                          Colors.amber.shade500,
                        ),
                        const SizedBox(width: 16),
                        _buildMiniStat(
                          Icons.star_rounded,
                          '${course.rewardExp}',
                          Colors.purple.shade400,
                        ),
                      ],
                    ),

                    // Arrow Action (Thay cho nút Xem chi tiết to đùng)
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget cho các icon thống kê nhỏ
  Widget _buildMiniStat(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
