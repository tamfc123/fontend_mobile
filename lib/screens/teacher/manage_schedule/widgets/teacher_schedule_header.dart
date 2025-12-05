import 'package:flutter/material.dart';

class TeacherScheduleHeader extends StatelessWidget {
  final String selectedDay;
  final Function(String?) onDayChanged;
  final int scheduleCount;
  final Map<String, int?> dayOptions;

  const TeacherScheduleHeader({
    super.key,
    required this.selectedDay,
    required this.onDayChanged,
    required this.scheduleCount,
    required this.dayOptions,
  });

  static const Color primaryBlue = Colors.blue;
  static const Color surfaceBlue = Color(0xFFE3F2FD);

  // Responsive helpers
  bool _isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;
  bool _isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1024;

  double _getHorizontalPadding(BuildContext context) {
    if (_isMobile(context)) return 16.0;
    if (_isTablet(context)) return 20.0;
    return 24.0;
  }

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
    if (_isMobile(context)) return 22.0;
    if (_isTablet(context)) return 24.0;
    return 28.0;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = _isMobile(context);
    final horizontalPadding = _getHorizontalPadding(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.06),
            blurRadius: isMobile ? 12 : 16,
            offset: Offset(0, isMobile ? 4 : 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // HEADER ROW
          Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              isMobile ? 16 : 24,
              horizontalPadding,
              isMobile ? 12 : 16,
            ),
            child: Row(
              children: [
                // ICON
                Container(
                  padding: EdgeInsets.all(isMobile ? 10 : 12),
                  decoration: BoxDecoration(
                    color: surfaceBlue,
                    borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
                  ),
                  child: Icon(
                    Icons.calendar_today_rounded,
                    color: primaryBlue,
                    size: _getIconSize(context),
                  ),
                ),
                SizedBox(width: isMobile ? 12 : 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lịch giảng dạy',
                        style: TextStyle(
                          fontSize: _getTitleFontSize(context),
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E3A8A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Quản lý lịch học của tôi',
                        style: TextStyle(
                          fontSize: _getSubtitleFontSize(context),
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // FILTER + STATS
          Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              0,
              horizontalPadding,
              isMobile ? 16 : 20,
            ),
            child:
                isMobile
                    ? Column(
                      children: [
                        // Filter dropdown full width on mobile
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: surfaceBlue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedDay,
                              isExpanded: true,
                              icon: const Icon(
                                Icons.filter_list,
                                color: primaryBlue,
                              ),
                              items:
                                  dayOptions.keys
                                      .map(
                                        (day) => DropdownMenuItem(
                                          value: day,
                                          child: Text(day),
                                        ),
                                      )
                                      .toList(),
                              onChanged: onDayChanged,
                            ),
                          ),
                        ),
                        if (scheduleCount > 0) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: primaryBlue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.event_available,
                                  color: primaryBlue,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Tổng: $scheduleCount lịch học',
                                  style: const TextStyle(
                                    color: primaryBlue,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    )
                    : Row(
                      children: [
                        // Filter dropdown
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: surfaceBlue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedDay,
                              icon: const Icon(
                                Icons.filter_list,
                                color: primaryBlue,
                              ),
                              items:
                                  dayOptions.keys
                                      .map(
                                        (day) => DropdownMenuItem(
                                          value: day,
                                          child: Text(day),
                                        ),
                                      )
                                      .toList(),
                              onChanged: onDayChanged,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        if (scheduleCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: primaryBlue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.event_available,
                                  color: primaryBlue,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Tổng: $scheduleCount lịch học',
                                  style: const TextStyle(
                                    color: primaryBlue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
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
