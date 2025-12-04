import 'package:flutter/material.dart';
import 'package:mobile/data/models/course_model.dart';
import 'package:mobile/screens/admin/manage_course/manage_course_view_model.dart';
import 'package:mobile/shared_widgets/admin/action_icon_button.dart';
import 'package:mobile/shared_widgets/admin/base_admin_table.dart';
import 'package:mobile/shared_widgets/admin/common_empty_state.dart';
import 'package:mobile/shared_widgets/admin/common_table_cell.dart';

class ManageCourseContent extends StatefulWidget {
  final ManageCourseViewModel viewModel;
  final TextEditingController searchController;
  final Function(CourseModel) onEdit;
  final Function(CourseModel) onDelete;
  final Function(CourseModel) onManageModules;
  final Function(CourseModel) onManageQuizzes;

  const ManageCourseContent({
    super.key,
    required this.viewModel,
    required this.searchController,
    required this.onEdit,
    required this.onDelete,
    required this.onManageModules,
    required this.onManageQuizzes,
    this.maxWidth = double.infinity,
  });

  final double maxWidth;

  @override
  State<ManageCourseContent> createState() => _ManageCourseContentState();
}

class _ManageCourseContentState extends State<ManageCourseContent> {
  static const Color primaryBlue = Colors.blue;

  @override
  Widget build(BuildContext context) {
    final courses = widget.viewModel.courses;
    final isLoading = widget.viewModel.isLoading;

    if (isLoading && courses.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: primaryBlue));
    } else if (courses.isEmpty) {
      return _buildEmptyState(widget.viewModel.searchQuery);
    } else {
      return _buildResponsiveTable(context, courses, widget.maxWidth);
    }
  }

  Widget _buildEmptyState(String? searchQuery) {
    bool isSearching = searchQuery != null && searchQuery.isNotEmpty;
    return CommonEmptyState(
      icon: Icons.school_outlined,
      title: isSearching ? 'Không tìm thấy khóa học' : 'Chưa có khóa học nào',
      subtitle:
          isSearching
              ? 'Thử tìm kiếm bằng từ khóa khác'
              : 'Nhấn "Thêm Khóa học" để bắt đầu',
    );
  }

  Widget _buildResponsiveTable(
    BuildContext context,
    List<CourseModel> courses,
    double maxWidth,
  ) {
    final colWidths = {
      0: maxWidth * 0.18,
      1: maxWidth * 0.20,
      2: maxWidth * 0.09,
      3: maxWidth * 0.09,
      4: maxWidth * 0.09,
      5: maxWidth * 0.09,
      6: maxWidth * 0.26,
    };
    final colHeaders = [
      'Tên khóa học',
      'Mô tả',
      'Tuần',
      'Cấp độ',
      'Kinh nghiệm',
      'Xu',
      'Hành động',
    ];

    final dataRows =
        courses.map((course) {
          return TableRow(
            children: [
              CommonTableCell(
                course.name,
                bold: true,
                color: const Color(0xFF1E3A8A),
                align: TextAlign.center,
              ),
              CommonTableCell(course.description ?? '-'),
              CommonTableCell(
                course.durationInWeeks.toString(),
                align: TextAlign.center,
              ),
              CommonTableCell(
                course.requiredLevel.toString(),
                align: TextAlign.center,
              ),
              CommonTableCell(
                course.rewardExp?.toString() ?? 'Tự tính',
                align: TextAlign.center,
              ),
              CommonTableCell(
                course.rewardCoins.toString(),
                align: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ActionIconButton(
                      icon: Icons.topic_rounded,
                      color: Colors.blueAccent,
                      tooltip: 'Quản lý chương',
                      onPressed: () => widget.onManageModules(course),
                    ),
                    const SizedBox(width: 8),
                    ActionIconButton(
                      icon: Icons.quiz_rounded,
                      color: Colors.purpleAccent,
                      tooltip: 'Quản lý Bài tập',
                      onPressed: () => widget.onManageQuizzes(course),
                    ),
                    const SizedBox(width: 8),
                    ActionIconButton(
                      icon: Icons.edit,
                      color: Colors.orange.shade600,
                      tooltip: 'Sửa',
                      onPressed: () => widget.onEdit(course),
                    ),
                    const SizedBox(width: 8),
                    ActionIconButton(
                      icon: Icons.delete,
                      color: Colors.redAccent,
                      tooltip: 'Xóa',
                      onPressed: () => widget.onDelete(course),
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
