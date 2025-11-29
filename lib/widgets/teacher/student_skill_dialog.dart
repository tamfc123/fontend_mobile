import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mobile/services/teacher/teacher_class_service.dart';
import 'package:provider/provider.dart';

class StudentSkillDialog extends StatefulWidget {
  final String classId;
  final String studentId;
  final String studentName;
  final String? avatarUrl;

  const StudentSkillDialog({
    super.key,
    required this.classId,
    required this.studentId,
    required this.studentName,
    this.avatarUrl,
  });

  @override
  State<StudentSkillDialog> createState() => _StudentSkillDialogState();
}

class _StudentSkillDialogState extends State<StudentSkillDialog> {
  bool _isLoading = true;
  Map<String, double>? _skills;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final service = context.read<TeacherAdminClassService>();
    await service.fetchClassSkills(widget.classId); // Đảm bảo data được load

    if (mounted) {
      try {
        final studentData = service.skillOverviews.firstWhere(
          (s) => s.studentId == widget.studentId,
        );
        setState(() {
          _skills = studentData.skills;
          _isLoading = false;
        });
      } catch (e) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: 500,
        height: 550, // Chiều cao vừa đủ
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage:
                        widget.avatarUrl != null
                            ? NetworkImage(widget.avatarUrl!)
                            : null,
                    child:
                        widget.avatarUrl == null
                            ? Text(widget.studentName[0].toUpperCase())
                            : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.studentName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3A8A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Text(
                          "Biểu đồ năng lực",
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // CONTENT
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _skills == null || _skills!.isEmpty
                      ? const Center(child: Text("Chưa có dữ liệu đánh giá"))
                      : Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            Expanded(child: _buildRadarChart(_skills!)),
                            const SizedBox(height: 20),
                            _buildChartNote(),
                          ],
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Radar Chart (Chuẩn 4 Kỹ năng)
  Widget _buildRadarChart(Map<String, double> skills) {
    final keys = skills.keys.toList();
    final values = skills.values.toList();

    if (keys.length < 3) {
      return const Center(
        child: Text("Cần ít nhất 3 loại dữ liệu để vẽ biểu đồ"),
      );
    }

    return RadarChart(
      RadarChartData(
        radarBackgroundColor: Colors.transparent,
        radarShape: RadarShape.polygon,
        radarBorderData: BorderSide(color: Colors.blue.shade100, width: 2),
        gridBorderData: BorderSide(color: Colors.blue.shade50, width: 1),
        tickBorderData: const BorderSide(color: Colors.transparent),
        tickCount: 4,
        ticksTextStyle: const TextStyle(color: Colors.transparent, fontSize: 0),

        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: Color(0xFF1E293B),
        ),

        getTitle: (index, angle) {
          if (index < keys.length) {
            // ✅ VIỆT HÓA CHUẨN 4 KỸ NĂNG
            String label = keys[index];
            if (label == 'Reading')
              label = 'Đọc';
            else if (label == 'Listening')
              label = 'Nghe';
            else if (label == 'Writing')
              label = 'Viết';
            else if (label == 'Speaking')
              label = 'Nói';
            // Grammar đã gộp vào Reading nên không cần care nữa

            return RadarChartTitle(
              text: "$label\n${values[index].toInt()}",
              angle: 0,
              positionPercentageOffset: 0.2,
            );
          }
          return const RadarChartTitle(text: '');
        },

        dataSets: [
          RadarDataSet(
            fillColor: Colors.blue.withOpacity(0.3),
            borderColor: Colors.blue.shade600,
            entryRadius: 4,
            borderWidth: 3,
            dataEntries: values.map((v) => RadarEntry(value: v)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildChartNote() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(width: 12, height: 12, color: Colors.blue.withOpacity(0.3)),
        const SizedBox(width: 8),
        const Text(
          "Điểm trung bình (0-100)",
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}
