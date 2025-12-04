import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mobile/screens/admin/dashboard/admin_dashboard_view_model.dart';
import 'package:provider/provider.dart';

class SkillDistributionChart extends StatefulWidget {
  const SkillDistributionChart({super.key});

  @override
  State<SkillDistributionChart> createState() => _SkillDistributionChartState();
}

class _SkillDistributionChartState extends State<SkillDistributionChart> {
  int _touchedIndex = -1;

  final List<Color> _pieColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
  ];

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
                    Icons.pie_chart_rounded,
                    color: Colors.blue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Phân bố kỹ năng Quiz',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 280,
              child:
                  (viewModel.isLoading && viewModel.skillPieData.isEmpty)
                      ? const Center(
                        child: CircularProgressIndicator(color: Colors.blue),
                      )
                      : (viewModel.skillPieData.isEmpty)
                      ? const Center(child: Text("Chưa có dữ liệu bài tập."))
                      : _buildPieChartData(viewModel),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPieChartData(AdminDashboardViewModel viewModel) {
    final int totalCount = viewModel.skillPieData.fold(
      0,
      (sum, item) => sum + item.count,
    );

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      _touchedIndex = -1;
                      return;
                    }
                    _touchedIndex =
                        pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 3,
              centerSpaceRadius: 50,
              sections:
                  viewModel.skillPieData.asMap().entries.map((entry) {
                    final index = entry.key;
                    final data = entry.value;
                    final isTouched = (index == _touchedIndex);
                    final fontSize = isTouched ? 16.0 : 13.0;
                    final radius = isTouched ? 70.0 : 60.0;
                    final color = _pieColors[index % _pieColors.length];
                    final double percentage =
                        totalCount > 0 ? (data.count / totalCount) * 100 : 0;

                    return PieChartSectionData(
                      color: color,
                      value: data.count.toDouble(),
                      title: '${percentage.toStringAsFixed(0)}%',
                      radius: radius,
                      titleStyle: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                viewModel.skillPieData.asMap().entries.map((entry) {
                  final index = entry.key;
                  final data = entry.value;
                  final color = _pieColors[index % _pieColors.length];

                  return _buildIndicator(
                    color: color,
                    text: data.label,
                    count: data.count,
                    isTouched: (index == _touchedIndex),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildIndicator({
    required Color color,
    required String text,
    required int count,
    bool isTouched = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: <Widget>[
          Container(
            width: isTouched ? 18 : 16,
            height: isTouched ? 18 : 16,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    fontSize: isTouched ? 14 : 13,
                    fontWeight: isTouched ? FontWeight.bold : FontWeight.w500,
                    color: const Color(0xFF1E3A8A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$count bài',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
