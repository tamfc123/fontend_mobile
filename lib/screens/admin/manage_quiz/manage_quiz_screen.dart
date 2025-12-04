import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/data/models/course_model.dart';
import 'package:mobile/data/models/quiz_models.dart';

import 'package:mobile/screens/admin/manage_quiz/manage_quiz_view_model.dart';
import 'package:mobile/screens/admin/manage_quiz/widgets/manage_quiz_content.dart';
import 'package:mobile/screens/admin/manage_quiz/widgets/quiz_form_dialog.dart';
import 'package:mobile/shared_widgets/admin/base_admin_screen.dart';
import 'package:mobile/shared_widgets/admin/pagination_controls.dart';
import 'package:provider/provider.dart';

class ManageQuizScreen extends StatefulWidget {
  final CourseModel course;

  const ManageQuizScreen({super.key, required this.course});

  @override
  State<ManageQuizScreen> createState() => _ManageQuizScreenState();
}

class _ManageQuizScreenState extends State<ManageQuizScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ManageQuizViewModel>().fetchQuizzes(widget.course.id!);
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
        context.read<ManageQuizViewModel>().applySearch(
          widget.course.id!,
          _searchController.text,
        );
      }
    });
  }

  void _showQuizForm() async {
    await showDialog(
      context: context,
      builder: (_) => AdminQuizFormDialog(courseId: widget.course.id!),
    );
    if (mounted) {
      // Refresh list after dialog closes (handled inside dialog or here?)
    }
  }

  void _confirmDelete(BuildContext context, QuizListModel quiz) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Chuyển vào thùng rác?'),
          content: Text('Bạn có chắc muốn xóa bài tập "${quiz.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await context.read<ManageQuizViewModel>().deleteQuiz(
                  widget.course.id!,
                  quiz.id,
                );
              },
              child: const Text(
                'Đồng ý',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _confirmRestore(BuildContext context, QuizListModel quiz) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Khôi phục bài tập'),
          content: Text(
            'Bạn muốn khôi phục "${quiz.title}" trở lại danh sách khóa học?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await context.read<ManageQuizViewModel>().restoreQuiz(
                  widget.course.id!,
                  quiz.id,
                );
              },
              child: const Text(
                'Khôi phục',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _goToDetail(String quizId) {
    final location = GoRouterState.of(context).uri.toString();
    context.push('$location/$quizId', extra: {'course': widget.course});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ManageQuizViewModel>(
      builder: (context, viewModel, child) {
        return BaseAdminScreen(
          title: 'Quản lý Bài tập',
          subtitle: viewModel.showDeleted ? 'THÙNG RÁC' : 'Danh sách bài tập',
          headerIcon: viewModel.showDeleted ? Icons.delete_outline : Icons.quiz,
          addLabel: 'Thêm Bài tập',
          onAddPressed: () {
            if (viewModel.showDeleted) {
              viewModel.toggleShowDeleted(widget.course.id!);
            }
            _showQuizForm();
          },
          onBackPressed: () => Navigator.of(context).pop(),
          searchController: _searchController,
          searchHint: 'Tìm kiếm bài tập...',
          isLoading: viewModel.isLoading,
          totalCount: viewModel.totalCount,
          countLabel: 'bài tập',
          body: LayoutBuilder(
            builder: (context, constraints) {
              final double tableWidth =
                  constraints.maxWidth < 1000 ? 1000 : constraints.maxWidth;
              return ManageQuizContent(
                viewModel: viewModel,
                courseId: widget.course.id!,
                maxWidth: tableWidth,
                onShowForm: () {
                  if (viewModel.showDeleted) {
                    viewModel.toggleShowDeleted(widget.course.id!);
                  }
                  _showQuizForm();
                },
                onConfirmDelete: (quiz) => _confirmDelete(context, quiz),
                onConfirmRestore: (quiz) => _confirmRestore(context, quiz),
                onGoToDetail: _goToDetail,
              );
            },
          ),
          paginationControls: PaginationControls(
            currentPage: viewModel.currentPage,
            totalPages: viewModel.totalPages,
            totalCount: viewModel.totalCount,
            isLoading: viewModel.isLoading,
            onPageChanged:
                (page) => viewModel.goToPage(widget.course.id!, page),
          ),
        );
      },
    );
  }
}
