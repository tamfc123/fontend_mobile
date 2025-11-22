import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// 1. THÊM IMPORT CHO BIỂU ĐỒ
import 'package:fl_chart/fl_chart.dart';
import 'package:mobile/services/auth/auth_service.dart';
import 'package:mobile/services/teacher/teacher_dashboard_service.dart';
import 'package:mobile/shared_widgets/dashboard_header.dart';
import 'package:mobile/shared_widgets/stat_card.dart';
import 'package:mobile/shared_widgets/admin/base_dashboard_card.dart';
import 'package:provider/provider.dart';

class DashboardTeacherScreen extends StatefulWidget {
  const DashboardTeacherScreen({super.key});
  @override
  State<DashboardTeacherScreen> createState() => _DashboardTeacherScreenState();
}

class _DashboardTeacherScreenState extends State<DashboardTeacherScreen> {
  // MÀU CHỦ ĐẠO
  static const Color primaryBlue = Colors.blue;
  static const Color backgroundBlue = Color(0xFFF8F9FA);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Đảm bảo local 'vi' đã được đăng ký cho intl
      Intl.defaultLocale = 'vi_VN';
      context.read<TeacherDashboardService>().fetchDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardService = context.watch<TeacherDashboardService>();
    final authService = context.watch<AuthService>();
    final teacherName = authService.currentUser?.name ?? 'Giảng viên';

    if (dashboardService.isLoading && dashboardService.stats == null) {
      return const Scaffold(
        backgroundColor: backgroundBlue,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final stats = dashboardService.stats;

    return Scaffold(
      backgroundColor: backgroundBlue,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DashboardHeader(
                icon: Icons.school_rounded,
                title: 'Chào mừng trở lại, $teacherName!',
                subtitle: 'Đây là tổng quan nhanh về các hoạt động của bạn.',
              ),
              const SizedBox(height: 24),

              // Dãy StatCard (Giữ nguyên)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: StatCard(
                      icon: Icons.class_,
                      title: 'Tổng số lớp',
                      value: stats?.totalClasses.toString() ?? '...',
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: StatCard(
                      icon: Icons.people,
                      title: 'Tổng số học viên',
                      value: stats?.totalStudents.toString() ?? '...',
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: StatCard(
                      icon: Icons.quiz,
                      title: 'Tổng số bài quiz',
                      value: stats?.totalQuizzes.toString() ?? '...',
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: StatCard(
                      icon: Icons.calendar_today,
                      title: 'Lịch dạy hôm nay',
                      value: stats?.todayClasses.toString() ?? '...',
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // ✅ 2. LAYOUTBUILDER (Layout 2x2 Grid)
              LayoutBuilder(
                builder: (context, constraints) {
                  // Đặt breakpoint cho 2 cột
                  bool isSmallScreen = constraints.maxWidth < 900;

                  // NẾU MÀN HÌNH NHỎ: DÙNG COLUMN (Xếp chồng 4 mục)
                  if (isSmallScreen) {
                    return Column(
                      children: [
                        _buildPassFailChart(dashboardService),
                        const SizedBox(height: 24),
                        _buildGradeDistributionChart(dashboardService),
                        const SizedBox(height: 24),
                        _buildUpcomingSchedule(dashboardService),
                        const SizedBox(height: 24),
                        _buildMyClasses(dashboardService),
                      ],
                    );
                  }

                  // NẾU MÀN HÌNH LỚN: DÙNG LAYOUT 2x2
                  return Column(
                    children: [
                      // HÀNG 1: HAI BIỂU ĐỒ
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1, // 50%
                            child: _buildPassFailChart(dashboardService),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 1, // 50%
                            child: _buildGradeDistributionChart(
                              dashboardService,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24), // Khoảng cách giữa 2 hàng
                      // HÀNG 2: HAI DANH SÁCH
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1, // 50%
                            child: _buildUpcomingSchedule(dashboardService),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 1, // 50%
                            child: _buildMyClasses(dashboardService),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Lịch dạy
  Widget _buildUpcomingSchedule(TeacherDashboardService service) {
    return BaseDashboardCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChartTitle('Lịch dạy sắp tới'), // Dùng helper
          const Divider(height: 24),
          if (service.upcomingSchedules.isEmpty)
            const Center(child: Text('Không có lịch dạy nào sắp tới.')),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: service.upcomingSchedules.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final schedule = service.upcomingSchedules[index];
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

  // Widget Lớp học
  Widget _buildMyClasses(TeacherDashboardService service) {
    return BaseDashboardCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChartTitle('Các lớp học của tôi (Top 5)'), // Dùng helper
          const Divider(height: 24),
          if (service.myClasses.isEmpty)
            const Center(child: Text('Bạn chưa phụ trách lớp học nào.')),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: service.myClasses.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final classItem = service.myClasses[index];
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

  // 3. WIDGET BIỂU ĐỒ TRÒN (DÙNG DỮ LIỆU THẬT)
  Widget _buildPassFailChart(TeacherDashboardService service) {
    // --- DÙNG DỮ LIỆU THẬT ---
    final double passCount = service.stats?.passCount.toDouble() ?? 0;
    final double failCount = service.stats?.failCount.toDouble() ?? 0;
    // ------------------------
    final double total = passCount + failCount;

    if (total == 0) {
      return BaseDashboardCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildChartTitle('Hiệu suất học viên'),
            const SizedBox(
              height: 100,
              child: Center(child: Text('Chưa có dữ liệu thống kê.')),
            ),
          ],
        ),
      );
    }

    final double passPercentage = (passCount / total) * 100;
    final double failPercentage = (failCount / total) * 100;

    return BaseDashboardCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChartTitle('Hiệu suất học viên (Đậu/Rớt)'),
          const Divider(height: 24),
          SizedBox(
            height: 180, // Set chiều cao cố định cho biểu đồ
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(
                    color: Colors.green,
                    value: passCount,
                    title: '${passPercentage.toStringAsFixed(0)}%',
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    color: Colors.red,
                    value: failCount,
                    title: '${failPercentage.toStringAsFixed(0)}%',
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(Colors.green, 'Đậu (${passCount.toInt()})'),
              const SizedBox(width: 20),
              _buildLegendItem(Colors.red, 'Rớt (${failCount.toInt()})'),
            ],
          ),
        ],
      ),
    );
  }

  // 4. WIDGET BIỂU ĐỒ CỘT (DÙNG DỮ LIỆU THẬT)
  Widget _buildGradeDistributionChart(TeacherDashboardService service) {
    // --- DÙNG DỮ LIỆU THẬT ---
    final List<double> gradeData =
        service.stats?.gradeDistribution
            .map((count) => count.toDouble())
            .toList() ??
        [0, 0, 0, 0, 0];
    // ------------------------

    if (gradeData.every((count) => count == 0)) {
      return BaseDashboardCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildChartTitle('Phân bổ điểm số'),
            const SizedBox(
              height: 100,
              child: Center(child: Text('Chưa có dữ liệu điểm.')),
            ),
          ],
        ),
      );
    }

    final double maxDataValue = gradeData.reduce((a, b) => a > b ? a : b);
    final double safeMaxY = (maxDataValue == 0) ? 5 : (maxDataValue * 1.2);
    final double safeInterval = (safeMaxY / 5).clamp(1.0, safeMaxY);

    return BaseDashboardCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChartTitle('Phân bổ điểm số'),
          const Divider(height: 24),
          SizedBox(
            height: 220, // Set chiều cao
            child: BarChart(
              BarChartData(
                maxY: safeMaxY,
                minY: 0,
                alignment: BarChartAlignment.spaceAround,
                barGroups:
                    gradeData.asMap().entries.map((entry) {
                      return BarChartGroupData(
                        x: entry.key, // 0, 1, 2, 3, 4
                        barRods: [
                          BarChartRodData(
                            toY: entry.value,
                            color: primaryBlue,
                            width: 16,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(4),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        String text;
                        switch (value.toInt()) {
                          case 0:
                            text = '0-2';
                            break;
                          case 1:
                            text = '3-4';
                            break;
                          case 2:
                            text = '5-6';
                            break;
                          case 3:
                            text = '7-8';
                            break;
                          case 4:
                            text = '9-10';
                            break;
                          default:
                            text = '';
                            break;
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            text,
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: safeInterval,
                      getTitlesWidget: (value, meta) {
                        if (value % 1 != 0 && value != 0) return Container();
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: safeInterval,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(color: Colors.grey.shade300, strokeWidth: 1);
                  },
                ),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 5. WIDGET HỖ TRỢ (TÁI SỬ DỤNG)
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

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }
}
