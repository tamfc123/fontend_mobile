import 'package:flutter/material.dart';
import 'package:mobile/shared_widgets/admin/base_dashboard_card.dart'; // Dùng lại card chung

class DashboardHeader extends StatelessWidget {
  // MÀU SẮC
  static const Color primaryBlue = Colors.blue;
  static const Color surfaceBlue = Color(0xFFE3F2FD);

  final IconData icon;
  final String title;
  final String subtitle;

  const DashboardHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    // Dùng BaseDashboardCard để có style đồng nhất
    return BaseDashboardCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: surfaceBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: primaryBlue, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
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
