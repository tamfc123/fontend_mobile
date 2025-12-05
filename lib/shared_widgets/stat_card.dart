import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isUrgent;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.isUrgent = false,
  });

  // Responsive helpers
  bool _isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  bool _isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1024;

  double _getValueFontSize(BuildContext context) {
    if (_isMobile(context)) return 20.0;
    if (_isTablet(context)) return 22.0;
    return 24.0;
  }

  double _getTitleFontSize(BuildContext context) {
    if (_isMobile(context)) return 12.0;
    if (_isTablet(context)) return 13.0;
    return 14.0;
  }

  double _getIconSize(BuildContext context) {
    if (_isMobile(context)) return 24.0;
    if (_isTablet(context)) return 26.0;
    return 28.0;
  }

  double _getPadding(BuildContext context) {
    if (_isMobile(context)) return 16.0;
    if (_isTablet(context)) return 18.0;
    return 20.0;
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
    return Container(
      padding: EdgeInsets.all(_getPadding(context)),
      decoration: BoxDecoration(
        color: isUrgent ? color.withValues(alpha: 0.1) : Colors.white,
        borderRadius: BorderRadius.circular(_isMobile(context) ? 12 : 16),
        border: isUrgent ? Border.all(color: color, width: 1.5) : null,
        boxShadow:
            isUrgent
                ? null
                : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(_getIconPadding(context)),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(_isMobile(context) ? 10 : 12),
            ),
            child: Icon(icon, color: color, size: _getIconSize(context)),
          ),
          SizedBox(width: _getSpacing(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: _getValueFontSize(context),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E3A8A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: _getTitleFontSize(context),
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
