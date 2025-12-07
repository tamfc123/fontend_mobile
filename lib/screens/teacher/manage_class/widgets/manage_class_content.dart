import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/data/models/teacher_class_model.dart';
import 'package:mobile/screens/teacher/manage_class/teacher_class_view_model.dart';
import 'package:mobile/shared_widgets/admin/action_icon_button.dart';
import 'package:mobile/shared_widgets/admin/base_admin_table.dart';
import 'package:mobile/shared_widgets/admin/common_empty_state.dart';
import 'package:mobile/shared_widgets/admin/common_table_cell.dart';
import 'package:mobile/shared_widgets/admin/pagination_controls.dart';
import 'package:provider/provider.dart';

class ManageTeacherClassContent extends StatelessWidget {
  final List<TeacherClassModel> classes;
  final bool isLoading;
  final String? currentSearchQuery;
  static const Color primaryBlue = Colors.blue;

  const ManageTeacherClassContent({
    super.key,
    required this.classes,
    required this.isLoading,
    this.currentSearchQuery,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TeacherClassViewModel>();

    Widget bodyContent;
    if (isLoading && classes.isEmpty) {
      bodyContent = const Center(
        child: CircularProgressIndicator(color: primaryBlue),
      );
    } else if (classes.isEmpty) {
      bodyContent = _buildEmptyStateWidget(currentSearchQuery);
    } else {
      bodyContent = LayoutBuilder(
        builder: (context, constraints) {
          // Ensure minimum table width for horizontal scroll on small screens
          final double tableWidth =
              constraints.maxWidth < 1000 ? 1000 : constraints.maxWidth;
          return _buildResponsiveTableWidget(context, classes, tableWidth);
        },
      );
    }

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.05),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              Expanded(child: bodyContent),
              PaginationControls(
                currentPage: viewModel.currentPage,
                totalPages: viewModel.totalPages,
                totalCount: viewModel.totalCount,
                isLoading: isLoading,
                onPageChanged: (page) {
                  context.read<TeacherClassViewModel>().goToPage(page);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyStateWidget(String? searchQuery) {
    bool isSearching = searchQuery != null && searchQuery.isNotEmpty;
    return CommonEmptyState(
      icon: Icons.class_outlined,
      title: isSearching ? 'Không tìm thấy lớp học' : 'Bạn chưa có lớp học nào',
      subtitle:
          isSearching
              ? 'Thử tìm kiếm bằng từ khóa khác'
              : 'Các lớp học bạn phụ trách sẽ xuất hiện ở đây',
    );
  }

  Widget _buildResponsiveTableWidget(
    BuildContext context,
    List<TeacherClassModel> classes,
    double maxWidth,
  ) {
    // Adjust column widths to prevent action button overflow
    final colWidths = {
      0: maxWidth * 0.32, // Tên lớp (reduced from 0.35)
      1: maxWidth * 0.24, // Khóa học (reduced from 0.25)
      2: maxWidth * 0.14, // Số sinh viên (reduced from 0.15)
      3: maxWidth * 0.30, // Thao tác (increased from 0.25 for 2 buttons)
    };
    final colHeaders = ['Tên lớp', 'Khóa học', 'Số sinh viên', 'Thao tác'];

    final dataRows =
        classes.asMap().entries.map((entry) {
          final c = entry.value;
          return TableRow(
            children: [
              CommonTableCell(
                c.name,
                bold: true,
                color: const Color(0xFF1E3A8A),
                align: TextAlign.center,
              ),
              CommonTableCell(c.courseName ?? '—', align: TextAlign.center),
              CommonTableCell(
                c.studentCount.toString(),
                align: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ActionIconButton(
                      icon: Icons.quiz,
                      color: Colors.purple,
                      tooltip: 'Xem bài tập',
                      onPressed: () {
                        context.go(
                          '/teacher/teacherClasses/${c.id}/quizzes',
                          extra: c,
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    ActionIconButton(
                      icon: Icons.people,
                      color: Colors.teal,
                      tooltip: 'Xem danh sách sinh viên',
                      onPressed: () {
                        context.go(
                          '/teacher/teacherClasses/${c.id}/students',
                          extra: c.name,
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
