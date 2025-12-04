import 'package:flutter/material.dart';
import 'package:mobile/data/models/student_in_class_model.dart';
import 'package:mobile/screens/teacher/manage_class/widgets/student_info_dialog.dart';
import 'package:mobile/screens/teacher/manage_class/widgets/student_skill_dialog.dart';
import 'package:mobile/shared_widgets/admin/action_icon_button.dart';
import 'package:mobile/shared_widgets/admin/base_admin_table.dart';
import 'package:mobile/shared_widgets/admin/common_empty_state.dart';
import 'package:mobile/shared_widgets/admin/common_table_cell.dart';
import 'package:mobile/shared_widgets/avatar_widget.dart';

class StudentListContent extends StatelessWidget {
  final List<StudentInClassModel> students;
  final String classId;
  static const Color primaryBlue = Colors.blue;

  const StudentListContent({
    super.key,
    required this.students,
    required this.classId,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (students.isEmpty) {
            return CommonEmptyState(
              title: "Không tìm thấy kết quả",
              subtitle: "Thử tìm kiếm với từ khóa khác",
              icon: Icons.search_off,
            );
          }
          return _buildStudentTable(context, students, constraints.maxWidth);
        },
      ),
    );
  }

  Widget _buildStudentTable(
    BuildContext context,
    List<StudentInClassModel> students,
    double maxWidth,
  ) {
    // Cấu hình độ rộng cột
    final colWidths = {
      0: maxWidth * 0.05, // STT
      1: maxWidth * 0.30, // Sinh viên (Avatar + Tên)
      2: maxWidth * 0.25, // Email
      3: maxWidth * 0.10, // Level
      4: maxWidth * 0.10, // EXP
      5: maxWidth * 0.20, // Hành động (Nút mới ở đây)
    };

    final colHeaders = ['#', 'Sinh viên', 'Email', 'Level', 'EXP', 'Hành động'];

    final dataRows =
        students.asMap().entries.map((entry) {
          final index = entry.key + 1;
          final student = entry.value;

          return TableRow(
            children: [
              // 1. STT
              CommonTableCell('$index', align: TextAlign.center, bold: true),

              // 2. Sinh viên (Avatar + Tên)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    AvatarWidget(
                      avatarUrl: student.avatarUrl,
                      name: student.studentName,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        student.studentName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E3A8A), // Màu xanh Admin
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Email
              CommonTableCell(student.email),

              // 4. Level
              CommonTableCell(
                'Lv.${student.level}',
                align: TextAlign.center,
                color: Colors.orange.shade800,
                bold: true,
              ),

              // 5. EXP
              CommonTableCell(
                '${student.experiencePoints}',
                align: TextAlign.center,
              ),

              // 6. Hành động (Thêm nút Analytics)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Nút xem chi tiết (Info)
                    ActionIconButton(
                      icon: Icons.info_outline_rounded,
                      color: Colors.grey,
                      tooltip: 'Thông tin cá nhân',
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder:
                              (_) => StudentInfoDialog(
                                classId: classId,
                                studentId: student.studentId,
                              ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    ActionIconButton(
                      icon: Icons.analytics_rounded,
                      color: primaryBlue,
                      tooltip: 'Đánh giá năng lực',
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder:
                              (_) => StudentSkillDialog(
                                classId: classId,
                                studentId: student.studentId,
                                studentName: student.studentName,
                                avatarUrl: student.avatarUrl,
                              ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList();

    return BaseAdminTable(
      columnWidths: colWidths.map((k, v) => MapEntry(k, FixedColumnWidth(v))),
      columnHeaders: colHeaders,
      dataRows: dataRows,
    );
  }
}
