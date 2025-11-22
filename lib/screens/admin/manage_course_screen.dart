import 'dart:async';
import 'package:mobile/shared_widgets/comfirm_delete_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/data/models/course_model.dart';
import 'package:mobile/services/admin/admin_course_service.dart';
import 'package:mobile/shared_widgets/admin/base_admin_screen.dart';
import 'package:mobile/shared_widgets/admin/base_admin_table.dart';
import 'package:mobile/shared_widgets/admin/pagination_controls.dart';
import 'package:mobile/shared_widgets/admin/common_empty_state.dart';
import 'package:mobile/shared_widgets/admin/action_icon_button.dart';
import 'package:mobile/shared_widgets/admin/common_table_cell.dart';
import 'package:mobile/widgets/admin/course_form_dialog.dart';
import 'package:provider/provider.dart';

class ManageCourseScreen extends StatefulWidget {
  const ManageCourseScreen({super.key});

  @override
  State<ManageCourseScreen> createState() => _ManageCourseScreenState();
}

class _ManageCourseScreenState extends State<ManageCourseScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  // MÀU CHỦ ĐẠO
  static const Color primaryBlue = Colors.blue;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final courseService = context.read<AdminCourseService>();
      _searchController.text = courseService.searchQuery ?? '';
      courseService.fetchCourses();
    });
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.read<AdminCourseService>().applySearch(_searchController.text);
      }
    });
  }

  // (Các hàm _showCourseForm, _confirmDelete, _goToModules giữ nguyên)
  void _showCourseForm({CourseModel? course}) async {
    final result = await showDialog<CourseModel>(
      context: context,
      builder: (_) => CourseFormDialog(course: course),
    );
    if (result != null) {
      final service = context.read<AdminCourseService>();
      if (course == null) {
        await service.addCourse(result);
      } else {
        await service.updateCourse(course.id!, result);
      }
    }
  }

  void _confirmDelete(CourseModel course) {
    showDialog(
      context: context,
      builder:
          (_) => ConfirmDeleteDialog(
            title: 'Xác nhận xóa',
            content: 'Bạn có chắc muốn xóa khóa học "${course.name}"?',
            itemName: course.name,
            onConfirm: () async {
              await context.read<AdminCourseService>().deleteCourse(course.id!);
            },
          ),
    );
  }

  void _goToModules(CourseModel course) {
    final router = GoRouter.of(context);
    final currentLocation = GoRouterState.of(context).uri.toString();
    router.push('$currentLocation/${course.id}/modules', extra: course);
  }

  void _goToQuizzes(CourseModel course) {
    final router = GoRouter.of(context);
    final currentLocation = GoRouterState.of(context).uri.toString();
    router.push('$currentLocation/${course.id}/quizzes', extra: course);
  }

  @override
  Widget build(BuildContext context) {
    final courseService = context.watch<AdminCourseService>();
    final courses = courseService.courses;
    final isLoading = courseService.isLoading;

    // ✅ 3. XÂY DỰNG BODYCONTENT
    Widget bodyContent;
    if (isLoading && courses.isEmpty) {
      bodyContent = const Center(
        child: CircularProgressIndicator(color: primaryBlue),
      );
    } else if (courses.isEmpty) {
      bodyContent = _buildEmptyState(courseService.searchQuery);
    } else {
      bodyContent = LayoutBuilder(
        builder:
            (context, constraints) =>
                _buildResponsiveTable(courses, constraints.maxWidth),
      );
    }

    // ✅ 4. SỬ DỤNG BaseAdminScreen
    return BaseAdminScreen(
      title: 'Quản lý Khóa học',
      subtitle: 'Tất cả khóa học trong hệ thống',
      headerIcon: Icons.school_rounded,
      addLabel: 'Thêm Khóa học',
      onAddPressed: () => _showCourseForm(),
      onBackPressed: null, // 👈 Không có nút Back

      searchController: _searchController,
      searchHint: 'Tìm kiếm theo tên, mô tả...',
      isLoading: isLoading,
      totalCount: courseService.totalCount,
      countLabel: 'K.học', // 👈 Sửa label

      body: bodyContent,

      paginationControls: PaginationControls(
        currentPage: courseService.currentPage,
        totalPages: courseService.totalPages,
        totalCount: courseService.totalCount,
        isLoading: isLoading,
        onPageChanged: (page) {
          // 👈 Service này dùng hàm goToPage
          context.read<AdminCourseService>().goToPage(page);
        },
      ),
    );
  }

  // ✅ 5. SỬ DỤNG CommonEmptyState
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

  // ✅ 6. SỬ DỤNG BaseAdminTable
  Widget _buildResponsiveTable(List<CourseModel> courses, double maxWidth) {
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

    // Tạo các dòng dữ liệu
    final dataRows =
        courses.map((course) {
          return TableRow(
            children: [
              // ✅ 7. SỬ DỤNG CommonTableCell
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
                      onPressed: () => _goToModules(course),
                    ),
                    const SizedBox(width: 8),
                    ActionIconButton(
                      icon: Icons.quiz_rounded,
                      color: Colors.purpleAccent, // Màu tím cho khác biệt
                      tooltip: 'Quản lý Bài tập',
                      onPressed: () => _goToQuizzes(course),
                    ),
                    const SizedBox(width: 8),
                    ActionIconButton(
                      icon: Icons.edit,
                      color: Colors.orange.shade600,
                      tooltip: 'Sửa',
                      onPressed: () => _showCourseForm(course: course),
                    ),
                    const SizedBox(width: 8),
                    ActionIconButton(
                      icon: Icons.delete,
                      color: Colors.redAccent,
                      tooltip: 'Xóa',
                      onPressed: () => _confirmDelete(course),
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
