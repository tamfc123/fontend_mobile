import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/screens/admin/manage_schedule/manage_schedule_view_model.dart';
import 'package:mobile/screens/admin/manage_schedule/widgets/schedule_filter_bar.dart';
import 'package:provider/provider.dart';

class ScheduleHeader extends StatelessWidget {
  const ScheduleHeader({super.key});

  static const Color primaryBlue = Colors.blue;
  static const Color surfaceBlue = Color(0xFFE3F2FD);

  // Responsive helpers
  bool _isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;
  bool _isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1024;

  double _getHorizontalPadding(BuildContext context) {
    if (_isMobile(context)) return 12.0;
    if (_isTablet(context)) return 16.0;
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

  double _getButtonFontSize(BuildContext context) {
    if (_isMobile(context)) return 14.0;
    return 15.0;
  }

  double _getIconSize(BuildContext context) {
    if (_isMobile(context)) return 22.0;
    if (_isTablet(context)) return 24.0;
    return 28.0;
  }

  EdgeInsets _getButtonPadding(BuildContext context) {
    if (_isMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 12, vertical: 10);
    }

    if (_isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    }

    return const EdgeInsets.symmetric(horizontal: 22, vertical: 16);
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
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              horizontalPadding,
              horizontalPadding,
              isMobile ? 12 : 16,
            ),
            child:
                isMobile
                    ? _buildMobileHeader(context)
                    : _buildDesktopHeader(context),
            // Moved to helper methods below
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              0,
              horizontalPadding,
              isMobile ? 16 : 20,
            ),
            child: const ScheduleFilterBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: surfaceBlue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.calendar_month,
                color: primaryBlue,
                size: _getIconSize(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quản lý Lịch học',
                    style: TextStyle(
                      fontSize: _getTitleFontSize(context),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Lịch học của tất cả lớp trong hệ thống',
                    style: TextStyle(
                      fontSize: _getSubtitleFontSize(context),
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () async {
            await context.push('/admin/schedules/bulk-create');
            if (context.mounted) {
              context.read<ManageScheduleViewModel>().loadData();
            }
          },
          icon: Icon(
            Icons.add_circle_outline,
            size: _isMobile(context) ? 18 : 20,
          ),
          label: Text(
            'Thêm Lịch học',
            style: TextStyle(
              fontSize: _getButtonFontSize(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            padding: _getButtonPadding(context),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopHeader(BuildContext context) {
    final isTablet = _isTablet(context);
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(isTablet ? 10 : 12),
          decoration: BoxDecoration(
            color: surfaceBlue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.calendar_month,
            color: primaryBlue,
            size: _getIconSize(context),
          ),
        ),
        SizedBox(width: isTablet ? 12 : 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quản lý Lịch học',
                style: TextStyle(
                  fontSize: _getTitleFontSize(context),
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E3A8A),
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'Lịch học của tất cả lớp trong hệ thống',
                style: TextStyle(
                  fontSize: _getSubtitleFontSize(context),
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        SizedBox(width: isTablet ? 8 : 16),
        ElevatedButton.icon(
          onPressed: () async {
            await context.push('/admin/schedules/bulk-create');
            if (context.mounted) {
              context.read<ManageScheduleViewModel>().loadData();
            }
          },
          icon: Icon(Icons.add_circle_outline, size: isTablet ? 18 : 20),
          label: Text(
            'Thêm Lịch học',
            style: TextStyle(
              fontSize: _getButtonFontSize(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            padding: _getButtonPadding(context),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}
