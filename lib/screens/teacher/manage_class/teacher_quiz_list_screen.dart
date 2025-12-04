import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile/data/models/class_model.dart';
import 'package:mobile/data/models/quiz_models.dart';
import 'package:mobile/screens/teacher/manage_class/teacher_quiz_view_model.dart';
import 'package:mobile/screens/teacher/manage_class/widgets/teacher_quiz_list_content.dart';
import 'package:mobile/shared_widgets/admin/base_admin_screen.dart';
import 'package:mobile/shared_widgets/admin/pagination_controls.dart';
import 'package:provider/provider.dart';

class TeacherQuizListScreen extends StatefulWidget {
  final ClassModel classModel;

  const TeacherQuizListScreen({super.key, required this.classModel});

  @override
  State<TeacherQuizListScreen> createState() => _TeacherQuizListScreenState();
}

class _TeacherQuizListScreenState extends State<TeacherQuizListScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  // State phân trang (Client-side pagination)
  int _currentPage = 1;
  final int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _fetchData());
    _searchController.addListener(_onSearchChanged);
  }

  void _fetchData({String? search}) {
    // Reset về trang 1 khi search
    if (search != null) setState(() => _currentPage = 1);

    context.read<TeacherQuizViewModel>().fetchQuizzes(
      widget.classModel.id,
      search: search,
    );
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        _fetchData(search: _searchController.text);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TeacherQuizViewModel>();
    final allQuizzes = viewModel.quizzes; // List đầy đủ từ API
    final isLoading = viewModel.isLoading;

    // --- LOGIC PHÂN TRANG CLIENT-SIDE ---
    final totalCount = allQuizzes.length;
    final totalPages = (totalCount / _pageSize).ceil();

    // Cắt list để hiển thị cho trang hiện tại
    final startIndex = (_currentPage - 1) * _pageSize;
    final endIndex =
        (startIndex + _pageSize < totalCount)
            ? startIndex + _pageSize
            : totalCount;

    final displayedQuizzes =
        (allQuizzes.isNotEmpty && startIndex < totalCount)
            ? allQuizzes.sublist(startIndex, endIndex)
            : <QuizListModel>[];

    return BaseAdminScreen(
      title: 'Danh sách Bài tập',
      subtitle: 'Lớp: ${widget.classModel.name}', // Hiển thị tên lớp
      headerIcon: Icons.quiz_rounded,

      addLabel: 'Làm mới',
      onAddPressed: () => _fetchData(search: _searchController.text),

      onBackPressed: () => Navigator.of(context).pop(),

      searchController: _searchController,
      searchHint: 'Tìm kiếm bài tập...',

      isLoading: isLoading,
      totalCount: totalCount,
      countLabel: 'bài tập',

      body: TeacherQuizListContent(
        quizzes: displayedQuizzes,
        isLoading: isLoading,
        currentPage: _currentPage,
        pageSize: _pageSize,
      ),

      paginationControls: PaginationControls(
        currentPage: _currentPage,
        totalPages: totalPages > 0 ? totalPages : 1,
        totalCount: totalCount,
        isLoading: isLoading,
        onPageChanged: (page) {
          setState(() => _currentPage = page);
        },
      ),
    );
  }
}
