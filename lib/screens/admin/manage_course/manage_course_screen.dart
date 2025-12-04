import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/data/models/course_model.dart';
import 'package:mobile/screens/admin/manage_course/manage_course_view_model.dart';
import 'package:mobile/screens/admin/manage_course/widgets/course_form_dialog.dart';
import 'package:mobile/screens/admin/manage_course/widgets/manage_course_content.dart';
import 'package:mobile/shared_widgets/admin/base_admin_screen.dart';
import 'package:mobile/shared_widgets/admin/pagination_controls.dart';
import 'package:mobile/shared_widgets/admin/comfirm_delete_dialog.dart';
import 'package:provider/provider.dart';

class ManageCourseScreen extends StatefulWidget {
  const ManageCourseScreen({super.key});

  @override
  State<ManageCourseScreen> createState() => _ManageCourseScreenState();
}

class _ManageCourseScreenState extends State<ManageCourseScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ManageCourseViewModel>().fetchCourses();
    });
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
        context.read<ManageCourseViewModel>().applySearch(
          _searchController.text,
        );
      }
    });
  }

  void _showCourseForm(BuildContext context, {CourseModel? course}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => CourseFormDialog(course: course),
    );
    if (result == true && mounted) {
      await context.read<ManageCourseViewModel>().fetchCourses();
    }
  }

  void _confirmDelete(BuildContext context, CourseModel course) {
    showDialog(
      context: context,
      builder:
          (_) => ConfirmDeleteDialog(
            title: 'Xác nhận xóa',
            content: 'Bạn có chắc muốn xóa khóa học "${course.name}"?',
            itemName: course.name,
            onConfirm: () async {
              await context.read<ManageCourseViewModel>().deleteCourse(
                course.id!,
              );
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
    return Consumer<ManageCourseViewModel>(
      builder: (context, viewModel, child) {
        final isLoading = viewModel.isLoading;

        return BaseAdminScreen(
          title: 'Quản lý Khóa học',
          subtitle: 'Tất cả khóa học trong hệ thống',
          headerIcon: Icons.school_rounded,
          addLabel: 'Thêm Khóa học',
          onAddPressed: () => _showCourseForm(context),
          onBackPressed: null,
          searchController: _searchController,
          searchHint: 'Tìm kiếm theo tên, mô tả...',
          isLoading: isLoading,
          totalCount: viewModel.totalCount,
          countLabel: 'K.học',
          body: LayoutBuilder(
            builder: (context, constraints) {
              final double tableWidth =
                  constraints.maxWidth < 1000 ? 1000 : constraints.maxWidth;
              return ManageCourseContent(
                viewModel: viewModel,
                searchController: _searchController,
                maxWidth: tableWidth,
                onEdit: (course) => _showCourseForm(context, course: course),
                onDelete: (course) => _confirmDelete(context, course),
                onManageModules: (course) => _goToModules(course),
                onManageQuizzes: (course) => _goToQuizzes(course),
              );
            },
          ),
          paginationControls: PaginationControls(
            currentPage: viewModel.currentPage,
            totalPages: viewModel.totalPages,
            totalCount: viewModel.totalCount,
            isLoading: isLoading,
            onPageChanged: (page) {
              viewModel.goToPage(page);
            },
          ),
        );
      },
    );
  }
}
