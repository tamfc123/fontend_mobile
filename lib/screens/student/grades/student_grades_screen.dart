import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mobile/screens/student/grades/student_grades_view_model.dart';
import 'package:mobile/shared_widgets/admin/common_empty_state.dart';
import 'package:provider/provider.dart';

class StudentGradesScreen extends StatefulWidget {
  const StudentGradesScreen({super.key});

  @override
  State<StudentGradesScreen> createState() => _StudentGradesScreenState();
}

class _StudentGradesScreenState extends State<StudentGradesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentGradesViewModel>().loadGradeSummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentGradesViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            title: const Text(
              'Tổng quan Kết quả',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF0F172A),
            elevation: 0,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: Colors.grey.shade200),
            ),
          ),
          body: _buildBody(viewModel),
        );
      },
    );
  }

  Widget _buildBody(StudentGradesViewModel viewModel) {
    if (viewModel.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: Colors.blue.shade600),
      );
    }

    if (viewModel.error != null) {
      return Center(child: Text('Lỗi: ${viewModel.error}'));
    }

    if (viewModel.summary == null) {
      return const Center(child: Text("Chưa có dữ liệu"));
    }

    final summary = viewModel.summary!;

    // Nếu chưa làm bài nào cả
    if (summary.overallSkills.isEmpty && summary.averageAccuracy == 0) {
      return const CommonEmptyState(
        title: "Chưa có dữ liệu",
        subtitle: "Hãy hoàn thành các bài luyện tập để xem đánh giá năng lực.",
        icon: Icons.bar_chart_rounded,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. BIỂU ĐỒ RADAR TỔNG HỢP (5 KỸ NĂNG)
          if (summary.overallSkills.isNotEmpty)
            _buildRadarChartCard(summary.overallSkills),

          const SizedBox(height: 32),

          // 2. CHI TIẾT KỸ NĂNG NÓI (SPEAKING)
          if (summary.averageAccuracy > 0) ...[
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                'Chi tiết Kỹ năng Nói (Speaking)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
            _buildScoreCard(
              icon: Icons.track_changes_rounded,
              title: 'Độ chính xác',
              subtitle: 'Accuracy',
              score: summary.averageAccuracy,
              color: Colors.blue.shade600,
              lightColor: Colors.blue.shade50,
            ),
            const SizedBox(height: 12),
            _buildScoreCard(
              icon: Icons.flash_on_rounded,
              title: 'Độ lưu loát',
              subtitle: 'Fluency',
              score: summary.averageFluency,
              color: Colors.cyan.shade600,
              lightColor: Colors.cyan.shade50,
            ),
            const SizedBox(height: 12),
            _buildScoreCard(
              icon: Icons.check_circle_rounded,
              title: 'Độ đầy đủ',
              subtitle: 'Completeness',
              score: summary.averageCompleteness,
              color: Colors.teal.shade600,
              lightColor: Colors.teal.shade50,
            ),
          ],
        ],
      ),
    );
  }

  // Widget chứa biểu đồ Radar
  Widget _buildRadarChartCard(Map<String, double> skills) {
    return Container(
      height: 480,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade100.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Center(
            child: Text(
              "Biểu đồ năng lực toàn diện",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: _buildRadarChart(skills),
            ),
          ),
          _buildChartNote(),
        ],
      ),
    );
  }

  // Vẽ biểu đồ Radar từ Map dữ liệu
  Widget _buildRadarChart(Map<String, double> skills) {
    final keys = skills.keys.toList();
    final values = skills.values.toList();

    if (keys.length < 3) {
      return const Center(
        child: Text("Cần làm ít nhất 3 loại bài tập để hiện biểu đồ"),
      );
    }

    return RadarChart(
      RadarChartData(
        radarBackgroundColor: Colors.transparent,
        radarShape: RadarShape.polygon,
        radarBorderData: BorderSide(
          color: Colors.blue.shade100.withValues(alpha: 0.5),
          width: 1.2,
        ),
        gridBorderData: BorderSide(
          color: Colors.blue.shade50.withValues(alpha: 0.8),
          width: 0.8,
        ),
        tickBorderData: const BorderSide(color: Colors.transparent),
        tickCount: 4,
        ticksTextStyle: const TextStyle(color: Colors.transparent),

        // Style chữ các đỉnh
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
          color: Color(0xFF1E293B),
        ),

        getTitle: (index, angle) {
          if (index < keys.length) {
            // ✅ VIỆT HÓA TÊN KỸ NĂNG
            String label = keys[index];
            if (label == 'Reading') {
              label = 'Đọc';
            } else if (label == 'Listening') {
              label = 'Nghe';
            } else if (label == 'Writing') {
              label = 'Viết';
            } else if (label == 'Speaking') {
              label = 'Nói';
            } else if (label == 'Grammar') {
              label = 'Ngữ pháp';
            }

            return RadarChartTitle(
              text: "$label\n${values[index].toInt()}",
              angle: 0,
            );
          }
          return const RadarChartTitle(text: '');
        },

        dataSets: [
          RadarDataSet(
            fillColor: Colors.blue.shade500.withValues(alpha: 0.2),
            borderColor: Colors.blue.shade600,
            borderWidth: 2,
            entryRadius: 3,
            dataEntries: values.map((v) => RadarEntry(value: v)).toList(),
          ),
        ],
      ),
    );
  }

  // Thẻ điểm số (Giữ nguyên)
  Widget _buildScoreCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required double score,
    required Color color,
    required Color lightColor,
  }) {
    final percentage = (score / 100 * 100).clamp(0, 100);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.1), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: lightColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    score.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                  Text(
                    '/100',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 6,
              backgroundColor: color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartNote() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Co lại vừa nội dung
        children: [
          // Giải thích vùng màu xanh
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.2),
              border: Border.all(color: Colors.blue),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            "Vùng kỹ năng",
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),

          const SizedBox(width: 20), // Khoảng cách
          // Giải thích con số
          const Icon(Icons.onetwothree, size: 20, color: Colors.black87),
          const SizedBox(width: 4),
          const Text(
            "Điểm TB (0-100)",
            style: TextStyle(
              fontSize: 13,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
