import 'dart:async';
import 'package:flutter/material.dart';

import 'package:mobile/screens/teacher/manage_class/teacher_class_view_model.dart';
import 'package:mobile/screens/teacher/manage_class/widgets/manage_class_content.dart';
import 'package:mobile/screens/teacher/manage_class/widgets/manage_class_header.dart';
import 'package:provider/provider.dart';

class ManageTeacherClassScreen extends StatefulWidget {
  const ManageTeacherClassScreen({super.key});

  @override
  State<ManageTeacherClassScreen> createState() =>
      _ManageTeacherClassScreenState();
}

class _ManageTeacherClassScreenState extends State<ManageTeacherClassScreen> {
  late TextEditingController _searchController;
  SortOption? _selectedSort;
  Timer? _debounce;

  // MÀU CHỦ ĐẠO
  static const Color backgroundBlue = Color(0xFFF3F8FF);

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<TeacherClassViewModel>();
      _selectedSort = _mapServiceSortToUiSort(viewModel.currentSortType);
      _searchController.text = viewModel.currentSearch ?? '';

      viewModel.fetchTeacherClasses();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.read<TeacherClassViewModel>().applySearch(
          _searchController.text,
        );
      }
    });
  }

  void _onSortChanged(SortOption? option) {
    setState(() => _selectedSort = option);
    final viewModel = context.read<TeacherClassViewModel>();
    if (option != null) {
      ClassSortType serviceSortType;
      switch (option) {
        case SortOption.courseNameAsc:
          serviceSortType = ClassSortType.courseNameAsc;
          break;
        case SortOption.courseNameDesc:
          serviceSortType = ClassSortType.courseNameDesc;
          break;
        case SortOption.studentCountAsc:
          serviceSortType = ClassSortType.studentCountAsc;
          break;
        case SortOption.studentCountDesc:
          serviceSortType = ClassSortType.studentCountDesc;
          break;
        // ✅ Thêm 2 case cho 'name'
        case SortOption.nameAsc:
          serviceSortType = ClassSortType.nameAsc;
          break;
        case SortOption.nameDesc:
          serviceSortType = ClassSortType.nameDesc;
          break;
      }
      viewModel.applySort(serviceSortType);
    }
  }

  SortOption? _mapServiceSortToUiSort(ClassSortType? serviceSort) {
    if (serviceSort == null) return null;
    switch (serviceSort) {
      case ClassSortType.courseNameAsc:
        return SortOption.courseNameAsc;
      case ClassSortType.courseNameDesc:
        return SortOption.courseNameDesc;
      case ClassSortType.studentCountAsc:
        return SortOption.studentCountAsc;
      case ClassSortType.studentCountDesc:
        return SortOption.studentCountDesc;
      // ✅ Thêm 2 case cho 'name'
      case ClassSortType.nameAsc:
        return SortOption.nameAsc;
      case ClassSortType.nameDesc:
        return SortOption.nameDesc;
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TeacherClassViewModel>();
    final classes = viewModel.classes;
    final isLoading = viewModel.isLoading;

    // Responsive padding
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding =
        screenWidth < 600 ? 12.0 : (screenWidth < 1024 ? 16.0 : 24.0);
    final verticalSpacing = screenWidth < 600 ? 16.0 : 24.0;

    return Scaffold(
      backgroundColor: backgroundBlue,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: screenWidth < 600 ? double.infinity : 1600,
          ),
          child: Padding(
            padding: EdgeInsets.all(horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === HEADER + TÌM KIẾM + FILTER ===
                ManageTeacherClassHeader(
                  searchController: _searchController,
                  selectedSort: _selectedSort,
                  onSortChanged: _onSortChanged,
                  isLoading: isLoading,
                  totalCount: viewModel.totalCount,
                ),
                SizedBox(height: verticalSpacing),

                // === BẢNG LỚP HỌC ===
                ManageTeacherClassContent(
                  classes: classes,
                  isLoading: isLoading,
                  currentSearchQuery: viewModel.currentSearchQuery,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
