import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mobile/data/models/grade_summary_model.dart';
import 'package:mobile/services/student/student_grade_service.dart';
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
    Future.microtask(() {
      context.read<StudentGradeService>().fetchGradeSummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<StudentGradeService>();

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
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade100.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ),
      body: _buildBody(service),
    );
  }

  Widget _buildBody(StudentGradeService service) {
    if (service.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation(Colors.blue.shade600),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Đang tải dữ liệu...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (service.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 40,
                  color: Colors.red.shade600,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Lỗi tải dữ liệu',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.red.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                service.error!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    if (service.summary == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.inbox_rounded,
                size: 40,
                color: Colors.blue.shade400,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có dữ liệu',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hãy hoàn thành bài luyện tập để xem kết quả',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    final summary = service.summary!;

    if (summary.averageAccuracy == 0 && summary.averageFluency == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade50, Colors.blue.shade100],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.trending_up_rounded,
                size: 40,
                color: Colors.blue.shade600,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Bắt đầu luyện tập',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hoàn thành các bài luyện tập để xem thống kê chi tiết',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Biểu đồ Radar
          _buildRadarChartCard(summary),
          const SizedBox(height: 32),

          // Tiêu đề "Điểm chi tiết"
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 0, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Điểm chi tiết',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade600, Colors.blue.shade400],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),

          // Các thẻ điểm
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
      ),
    );
  }

  // Biểu đồ Radar trong thẻ
  Widget _buildRadarChartCard(GradeSummaryModel summary) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade100.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tổng quan Kỹ năng Phát âm',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Phân tích chi tiết các khía cạnh của phát âm của bạn',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          AspectRatio(aspectRatio: 1.3, child: _buildRadarChart(summary)),
        ],
      ),
    );
  }

  // Widget Biểu đồ Radar (UI mềm hơn, tinh tế hơn)
  Widget _buildRadarChart(GradeSummaryModel summary) {
    return RadarChart(
      RadarChartData(
        radarBackgroundColor: Colors.transparent,
        radarShape: RadarShape.polygon,
        // Viền ngoài rất nhẹ, gần như mờ
        radarBorderData: BorderSide(
          color: Colors.blue.shade100.withOpacity(0.5),
          width: 1.2,
        ),
        //radarTouchData: ,
        // Lưới mảnh và nhẹ, màu xanh nhạt hơn
        gridBorderData: BorderSide(
          color: Colors.blue.shade50.withOpacity(0.8),
          width: 0.8,
        ),
        tickBorderData: const BorderSide(color: Colors.transparent),
        // Ít vòng hơn để UI không quá rối
        tickCount: 4,
        ticksTextStyle: TextStyle(
          color: Colors.transparent,
          fontSize: 9,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.3,
        ),
        // Tiêu đề trục nhỏ, nhẹ nhàng
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
          color: Color(0xFF1E293B),
          letterSpacing: 0.2,
        ),

        getTitle: (index, angle) {
          switch (index) {
            case 0:
              return const RadarChartTitle(text: 'Chính xác');
            case 1:
              return const RadarChartTitle(text: 'Lưu loát');
            case 2:
              return const RadarChartTitle(text: 'Đầy đủ');
            default:
              return const RadarChartTitle(text: '');
          }
        },
        dataSets: [
          RadarDataSet(
            // Màu fill rất nhẹ, trong suốt cao
            fillColor: Colors.blue.shade300.withOpacity(0.14),
            // Viền xanh mềm mại với bo tròn
            borderColor: Colors.blue.shade500,
            borderWidth: 1,
            // Làm điểm mềm hơn: chấm nhỏ + hiệu ứng bóng nhẹ
            entryRadius: 2.8,
            dataEntries: [
              RadarEntry(value: summary.averageAccuracy),
              RadarEntry(value: summary.averageFluency),
              RadarEntry(value: summary.averageCompleteness),
            ],
          ),
        ],
      ),
    );
  }

  // Thẻ điểm số tân tiến
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
        border: Border.all(color: color.withOpacity(0.1), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
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
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0F172A),
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
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}
