import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/data/models/lesson_model.dart';
import 'package:mobile/data/models/module_model.dart';

import 'package:mobile/screens/admin/manage_lesson/manage_lesson_view_model.dart';
import 'package:mobile/screens/admin/manage_lesson/widgets/lesson_form_dialog.dart';
import 'package:mobile/screens/admin/manage_lesson/widgets/manage_lesson_content.dart';
import 'package:mobile/shared_widgets/admin/base_admin_screen.dart';
import 'package:mobile/shared_widgets/admin/pagination_controls.dart';
import 'package:mobile/shared_widgets/admin/comfirm_delete_dialog.dart';
import 'package:provider/provider.dart';

class ManageLessonScreen extends StatefulWidget {
  final ModuleModel module;
  const ManageLessonScreen({super.key, required this.module});

  @override
  State<ManageLessonScreen> createState() => _ManageLessonScreenState();
}

class _ManageLessonScreenState extends State<ManageLessonScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ManageLessonViewModel>().fetchLessons(
        moduleId: widget.module.id,
      );
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
        context.read<ManageLessonViewModel>().applySearch(
          widget.module.id,
          _searchController.text,
        );
      }
    });
  }

  void _showLessonForm(BuildContext context, {LessonModel? lesson}) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => LessonFormDialog(
            lessonId: lesson?.id,
            moduleId: widget.module.id,
          ),
    );

    if (result == true && mounted) {
      await context.read<ManageLessonViewModel>().fetchLessons(
        moduleId: widget.module.id,
      );
    }
  }

  void _confirmDelete(BuildContext context, LessonModel lesson) {
    showDialog(
      context: context,
      builder:
          (_) => ConfirmDeleteDialog(
            title: 'Xác nhận xóa',
            content: 'Bạn có chắc muốn xóa bài học "${lesson.title}"?',
            itemName: lesson.title,
            onConfirm: () async {
              await context.read<ManageLessonViewModel>().deleteLesson(
                lesson.id,
                lesson.moduleId,
              );
            },
          ),
    );
  }

  void _goToVocabulary(LessonModel lesson) {
    final router = GoRouter.of(context);
    final currentLocation = GoRouterState.of(context).uri.toString();
    router.push('$currentLocation/${lesson.id}/vocabularies', extra: lesson);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ManageLessonViewModel>(
      builder: (context, viewModel, child) {
        final isLoading = viewModel.isLoading;

        return BaseAdminScreen(
          title: 'Quản lý Bài học',
          subtitle: 'Module: ${widget.module.title}',
          headerIcon: Icons.class_,
          addLabel: 'Thêm Bài học',
          onAddPressed: () => _showLessonForm(context),
          onBackPressed: () => Navigator.of(context).pop(),
          searchController: _searchController,
          searchHint: 'Tìm kiếm bài học...',
          isLoading: isLoading,
          totalCount: viewModel.totalCount,
          countLabel: 'bài học',
          body: LayoutBuilder(
            builder: (context, constraints) {
              final double tableWidth =
                  constraints.maxWidth < 1000 ? 1000 : constraints.maxWidth;
              return ManageLessonContent(
                viewModel: viewModel,
                maxWidth: tableWidth,
                onEdit: (lesson) => _showLessonForm(context, lesson: lesson),
                onDelete: (lesson) => _confirmDelete(context, lesson),
                onManageVocabulary: (lesson) => _goToVocabulary(lesson),
              );
            },
          ),
          paginationControls: PaginationControls(
            currentPage: viewModel.currentPage,
            totalPages: viewModel.totalPages,
            totalCount: viewModel.totalCount,
            isLoading: isLoading,
            onPageChanged: (page) => viewModel.goToPage(widget.module.id, page),
          ),
        );
      },
    );
  }
}
