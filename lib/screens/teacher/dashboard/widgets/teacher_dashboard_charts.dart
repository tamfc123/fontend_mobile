import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mobile/screens/teacher/dashboard/teacher_dashboard_view_model.dart';
import 'package:mobile/shared_widgets/admin/base_dashboard_card.dart';

class PassFailChart extends StatelessWidget {
  final TeacherDashboardViewModel viewModel;

  const PassFailChart({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    // --- DÙNG DỮ LIỆU THẬT ---
    final double passCount = viewModel.stats?.passCount.toDouble() ?? 0;
    final double failCount = viewModel.stats?.failCount.toDouble() ?? 0;
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

class GradeDistributionChart extends StatelessWidget {
  final TeacherDashboardViewModel viewModel;
  static const Color primaryBlue = Colors.blue;

  const GradeDistributionChart({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    // --- DÙNG DỮ LIỆU THẬT ---
    final List<double> gradeData =
        viewModel.stats?.gradeDistribution
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
