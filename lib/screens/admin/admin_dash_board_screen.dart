import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/data/models/admin_recent_teacher_model.dart';
import 'package:mobile/data/models/admin_top_student_model.dart';
import 'package:mobile/services/admin/admin_dashboard_service.dart';
import 'package:mobile/shared_widgets/dashboard_header.dart';
import 'package:mobile/shared_widgets/avatar_widget.dart';
import 'package:provider/provider.dart';
import 'package:mobile/shared_widgets/admin/base_dashboard_card.dart';
import 'package:mobile/shared_widgets/stat_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const Color primaryBlue = Colors.blue;
  static const Color backgroundBlue = Color(0xFFF3F8FF);
  static const Color surfaceBlue = Color(0xFFE3F2FD);

  final List<Color> _pieColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
  ];
  int _touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminDashboardService>().fetchDashboardStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundBlue,
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const DashboardHeader(
                  icon: Icons.dashboard_rounded,
                  title: 'Tổng quan',
                  subtitle: 'Thống kê tổng quan toàn bộ hệ thống',
                ),
                const SizedBox(height: 24),
                _buildStatsCards(),
                const SizedBox(height: 24),
                _buildChartsRow(),
                const SizedBox(height: 24),
                _buildListsRow(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ========== STATS CARDS ==========
  Widget _buildStatsCards() {
    final service = context.watch<AdminDashboardService>();
    final stats = service.stats;

    if (service.isLoading && stats == null) {
      return const Center(child: CircularProgressIndicator(color: primaryBlue));
    }
    if (service.error != null) {
      return Center(
        child: Text(service.error!, style: const TextStyle(color: Colors.red)),
      );
    }
    if (stats == null) {
      return const Center(child: Text('Không có dữ liệu thống kê.'));
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: StatCard(
            title: 'Tổng Người Dùng',
            value: stats.totalUsers.toString(),
            icon: Icons.group_rounded,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 16), // 👈 Thêm khoảng cách
        Expanded(
          // 👈 Bọc card 2
          child: StatCard(
            title: 'Giáo viên',
            value: stats.totalTeachers.toString(),
            icon: Icons.school_rounded,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 16), // 👈 Thêm khoảng cách
        Expanded(
          // 👈 Bọc card 3
          child: StatCard(
            title: 'Sinh viên',
            value: stats.totalStudents.toString(),
            icon: Icons.person_rounded,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 16), // 👈 Thêm khoảng cách
        Expanded(
          // 👈 Bọc card 4
          child: StatCard(
            title: 'Lớp học',
            value: stats.totalClasses.toString(),
            icon: Icons.class_rounded,
            color: Colors.purple,
          ),
        ),
        const SizedBox(width: 16), // 👈 Thêm khoảng cách
        Expanded(
          // 👈 Bọc card 5
          child: StatCard(
            title: 'Bài tập',
            value: stats.totalQuizzes.toString(),
            icon: Icons.quiz_rounded,
            color: Colors.red,
          ),
        ),
      ],
    );
  }

  // ========== CHARTS ROW ==========
  Widget _buildChartsRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start, // 👈 Thêm
      children: [
        // ✅ 7. SỬ DỤNG BaseDashboardCard
        Expanded(
          child: BaseDashboardCard(
            child: _buildUserChartContent(), // 👈 Sửa tên
          ),
        ),
        const SizedBox(width: 24),
        SizedBox(
          width: 450,
          child: BaseDashboardCard(
            child: _buildSkillPieChartContent(), // 👈 Sửa tên
          ),
        ),
      ],
    );
  }

  // ✅ 8. Sửa tên hàm (chỉ build nội dung)
  Widget _buildUserChartContent() {
    final service = context.watch<AdminDashboardService>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: surfaceBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.bar_chart_rounded,
                color: primaryBlue,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Người dùng mới (7 ngày qua)',
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
              service.isLoading && service.userChartData.isEmpty
                  ? const Center(
                    child: CircularProgressIndicator(color: primaryBlue),
                  )
                  : _buildBarChart(service),
        ),
      ],
    );
  }

  Widget _buildBarChart(AdminDashboardService service) {
    if (service.userChartData.isEmpty) {
      return const Center(child: Text('Chưa có dữ liệu'));
    }

    final bottomTitles =
        service.userChartData.asMap().entries.map((entry) {
          final index = entry.key.toDouble();
          final date = entry.value.date;
          final label = DateFormat('dd/MM').format(date.toLocal());
          return MapEntry(index, label);
        }).toList();

    // 1. TÍNH MAX Y GỐC (CÓ THỂ BẰNG 0)
    final double calculatedMaxY =
        (service.userChartData
                    .map((d) => d.count)
                    .reduce((a, b) => a > b ? a : b) *
                1.2)
            .toDouble();

    // 2. TẠO MAX Y "AN TOÀN" (LUÔN LỚN HƠN 0)
    // Nếu max Y gốc là 0, ta đặt là 5 (hoặc 1, 10... tùy bạn)
    final double safeMaxY = calculatedMaxY == 0 ? 5.0 : calculatedMaxY;

    // 3. TÍNH INTERVAL AN TOÀN
    // Đảm bảo interval cũng phải hợp lệ, ít nhất là 1
    final double safeInterval = (safeMaxY / 5).clamp(1.0, safeMaxY);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        // 4. SỬ DỤNG GIÁ TRỊ AN TOÀN Ở ĐÂY
        maxY: safeMaxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          // 5. SỬ DỤNG INTERVAL AN TOÀN
          horizontalInterval: safeInterval,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: surfaceBlue, strokeWidth: 1);
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          // (Bỏ qua rightTitles, topTitles...)
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
              // 6. SỬ DỤNG INTERVAL AN TOÀN
              interval: safeInterval,
              getTitlesWidget: (value, meta) {
                // Chỉ hiển thị số nguyên
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
          // (Phần bottomTitles giữ nguyên...)
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
        // (Phần barGroups giữ nguyên...)
        barGroups:
            service.userChartData.asMap().entries.map((entry) {
              final index = entry.key;
              final data = entry.value;

              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: data.count.toDouble(),
                    color: primaryBlue,
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

  // ✅ 9. Sửa tên hàm (chỉ build nội dung)
  Widget _buildSkillPieChartContent() {
    final service = context.watch<AdminDashboardService>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: surfaceBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.pie_chart_rounded,
                color: primaryBlue,
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
              (service.isLoading && service.skillPieData.isEmpty)
                  ? const Center(
                    child: CircularProgressIndicator(color: primaryBlue),
                  )
                  : (service.skillPieData.isEmpty)
                  ? const Center(child: Text("Chưa có dữ liệu bài tập."))
                  // ✅ 10. SỬA LỖI ĐỆ QUY
                  // Gọi hàm _buildPieChartData (đổi tên từ hàm cũ)
                  : _buildPieChartData(service),
        ),
      ],
    );
  }

  // ✅ 11. ĐỔI TÊN HÀM TỪ _buildPieChartContent
  Widget _buildPieChartData(AdminDashboardService service) {
    final int totalCount = service.skillPieData.fold(
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
                  service.skillPieData.asMap().entries.map((entry) {
                    final index = entry.key;
                    final data = entry.value;
                    final isTouched = (index == _touchedIndex);
                    final fontSize = isTouched ? 16.0 : 13.0;
                    final radius = isTouched ? 70.0 : 60.0;
                    final color = _pieColors[index % _pieColors.length];
                    // An toàn: kiểm tra totalCount > 0
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
                service.skillPieData.asMap().entries.map((entry) {
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

  // (Hàm _buildIndicator giữ nguyên)
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

  // ========== LISTS ROW ==========
  Widget _buildListsRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ 12. SỬ DỤNG BaseDashboardCard
        Expanded(
          child: BaseDashboardCard(
            padding: const EdgeInsets.all(0), // 👈 Xóa padding
            child: _buildRecentTeachers(),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: BaseDashboardCard(
            padding: const EdgeInsets.all(0), // 👈 Xóa padding
            child: _buildTopStudents(),
          ),
        ),
      ],
    );
  }

  // ✅ 13. Sửa hàm (chỉ build nội dung)
  Widget _buildRecentTeachers() {
    final service = context.watch<AdminDashboardService>();
    final teachers = service.recentTeachers;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: surfaceBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.person_add_rounded,
                  color: primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Giáo viên mới đăng ký',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE2E8F0)),
        (service.isLoading && teachers.isEmpty)
            ? const SizedBox(
              height: 200,
              child: Center(
                child: CircularProgressIndicator(color: primaryBlue),
              ),
            )
            : (teachers.isEmpty)
            ? const SizedBox(
              height: 150,
              child: Center(
                child: Text(
                  "Không có giáo viên nào mới đăng ký.",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
            : Column(
              children:
                  teachers
                      .map((teacher) => _buildTeacherTile(teacher))
                      .toList(),
            ),
      ],
    );
  }

  // (Hàm _buildTeacherTile giữ nguyên)
  Widget _buildTeacherTile(AdminRecentTeacherModel teacher) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: primaryBlue.withOpacity(0.12),
            child: Text(
              teacher.name.isNotEmpty ? teacher.name[0].toUpperCase() : 'T',
              style: const TextStyle(
                color: primaryBlue,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  teacher.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E3A8A),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  teacher.email,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color:
                  teacher.isActive
                      ? Colors.green.shade50
                      : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color:
                    teacher.isActive
                        ? Colors.green.shade200
                        : Colors.orange.shade200,
              ),
            ),
            child: Text(
              teacher.isActive ? 'Đã kích hoạt' : 'Chưa kích hoạt',
              style: TextStyle(
                color:
                    teacher.isActive
                        ? Colors.green.shade700
                        : Colors.orange.shade700,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ 14. Sửa hàm (chỉ build nội dung)
  Widget _buildTopStudents() {
    final service = context.watch<AdminDashboardService>();
    final students = service.topStudents;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: surfaceBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Top 5 Sinh viên (XP)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE2E8F0)),
        (service.isLoading && students.isEmpty)
            ? const SizedBox(
              height: 200,
              child: Center(
                child: CircularProgressIndicator(color: primaryBlue),
              ),
            )
            : (students.isEmpty)
            ? const SizedBox(
              height: 150,
              child: Center(
                child: Text(
                  "Chưa có dữ liệu sinh viên.",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
            : Column(
              children:
                  students
                      .map((student) => _buildStudentTile(student))
                      .toList(),
            ),
      ],
    );
  }

  // (Hàm _buildStudentTile giữ nguyên)
  Widget _buildStudentTile(AdminTopStudentModel student) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          AvatarWidget(
            avatarUrl: student.avatarUrl,
            name: student.name,
            radius: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E3A8A),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Level: ${student.level}",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.stars_rounded,
                  color: Colors.orange.shade700,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${student.experiencePoints} XP',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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
