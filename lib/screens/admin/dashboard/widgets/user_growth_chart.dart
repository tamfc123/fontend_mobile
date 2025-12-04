import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/screens/admin/dashboard/admin_dashboard_view_model.dart';
import 'package:provider/provider.dart';

class UserGrowthChart extends StatelessWidget {
  const UserGrowthChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminDashboardViewModel>(
      builder: (context, viewModel, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.bar_chart_rounded,
                    color: Colors.blue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Người dùng mới (7 ngày qua)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 280,
              child:
                  viewModel.isLoading && viewModel.userChartData.isEmpty
                      ? const Center(
                        child: CircularProgressIndicator(color: Colors.blue),
                      )
                      : _buildBarChart(viewModel),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBarChart(AdminDashboardViewModel viewModel) {
    if (viewModel.userChartData.isEmpty) {
      return const Center(child: Text('Chưa có dữ liệu'));
    }

    final bottomTitles =
        viewModel.userChartData.asMap().entries.map((entry) {
          final index = entry.key.toDouble();
          final date = entry.value.date;
          final label = DateFormat('dd/MM').format(date.toLocal());
          return MapEntry(index, label);
        }).toList();

    final double calculatedMaxY =
        (viewModel.userChartData
                    .map((d) => d.count)
                    .reduce((a, b) => a > b ? a : b) *
                1.2)
            .toDouble();

    final double safeMaxY = calculatedMaxY == 0 ? 5.0 : calculatedMaxY;
    final double safeInterval = (safeMaxY / 5).clamp(1.0, safeMaxY);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: safeMaxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: safeInterval,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: const Color(0xFFE3F2FD), strokeWidth: 1);
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: safeInterval,
              getTitlesWidget: (value, meta) {
                if (value % 1 != 0) return Container();
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final label =
                    bottomTitles
                        .firstWhere(
                          (e) => e.key == value,
                          orElse: () => const MapEntry(0, ''),
                        )
                        .value;
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 8.0,
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups:
            viewModel.userChartData.asMap().entries.map((entry) {
              final index = entry.key;
              final data = entry.value;

              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: data.count.toDouble(),
                    color: Colors.blue,
                    width: 20,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(6),
                    ),
                  ),
                ],
              );
            }).toList(),
      ),
    );
  }
}
