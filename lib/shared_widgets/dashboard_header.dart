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

  // Responsive helpers
  bool _isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  bool _isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1024;

  double _getTitleFontSize(BuildContext context) {
    if (_isMobile(context)) return 18.0;
    if (_isTablet(context)) return 20.0;
    return 24.0;
  }

  double _getSubtitleFontSize(BuildContext context) {
    if (_isMobile(context)) return 13.0;
    if (_isTablet(context)) return 14.0;
    return 15.0;
  }

  double _getIconSize(BuildContext context) {
    if (_isMobile(context)) return 24.0;
    if (_isTablet(context)) return 26.0;
    return 28.0;
  }

  double _getIconPadding(BuildContext context) {
    if (_isMobile(context)) return 10.0;
    return 12.0;
  }

  double _getSpacing(BuildContext context) {
    if (_isMobile(context)) return 12.0;
    return 16.0;
  }

  @override
  Widget build(BuildContext context) {
    // Dùng BaseDashboardCard để có style đồng nhất
    // Pass responsive padding
    return BaseDashboardCard(
      padding: EdgeInsets.all(_isMobile(context) ? 16 : 24),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(_getIconPadding(context)),
            decoration: BoxDecoration(
              color: surfaceBlue,
              borderRadius: BorderRadius.circular(_isMobile(context) ? 10 : 12),
            ),
            child: Icon(icon, color: primaryBlue, size: _getIconSize(context)),
          ),
          SizedBox(width: _getSpacing(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: _getTitleFontSize(context),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E3A8A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: _getSubtitleFontSize(context),
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: _isMobile(context) ? 1 : 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
