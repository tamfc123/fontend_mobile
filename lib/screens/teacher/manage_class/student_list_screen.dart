import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile/data/models/student_in_class_model.dart';
import 'package:mobile/screens/teacher/manage_class/teacher_class_view_model.dart';
import 'package:mobile/screens/teacher/manage_class/widgets/student_list_content.dart';
import 'package:mobile/screens/teacher/manage_class/widgets/student_list_header.dart';
import 'package:mobile/shared_widgets/admin/common_empty_state.dart';
import 'package:provider/provider.dart';

class StudentListScreen extends StatefulWidget {
  final String classId;
  final String className;

  const StudentListScreen({
    super.key,
    required this.classId,
    required this.className,
  });

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  late TextEditingController _searchController;
  SortOptionStudent? _selectedSort;
  Timer? _debounce;
  List<StudentInClassModel> _allStudents = []; // Lưu data gốc để filter/sort

  // MÀU CHỦ ĐẠO
  static const Color primaryBlue = Colors.blue;
  static const Color backgroundBlue = Color(0xFFF3F8FF);

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // Debouncer
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _onSortChanged(SortOptionStudent? option) {
    setState(() => _selectedSort = option);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {});
  }

  // Lọc và sắp xếp data
  List<StudentInClassModel> _getFilteredStudents() {
    var students = List<StudentInClassModel>.from(
      _allStudents,
    ); // Clone list để sort không ảnh hưởng gốc
    final query = _searchController.text.toLowerCase();

    // Filter
    if (query.isNotEmpty) {
      students =
          students
              .where(
                (s) =>
                    s.studentName.toLowerCase().contains(query) ||
                    s.email.toLowerCase().contains(query),
              )
              .toList();
    }

    // Sort
    if (_selectedSort != null) {
      switch (_selectedSort!) {
        case SortOptionStudent.nameAsc:
          students.sort((a, b) => a.studentName.compareTo(b.studentName));
          break;
        case SortOptionStudent.nameDesc:
          students.sort((a, b) => b.studentName.compareTo(a.studentName));
          break;
        case SortOptionStudent.expAsc:
          students.sort(
            (a, b) => a.experiencePoints.compareTo(b.experiencePoints),
          );
          break;
        case SortOptionStudent.expDesc:
          students.sort(
            (a, b) => b.experiencePoints.compareTo(a.experiencePoints),
          );
          break;
      }
    }
    return students;
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<TeacherClassViewModel>();

    return Scaffold(
      backgroundColor: backgroundBlue,
      body: FutureBuilder<List<StudentInClassModel>>(
        future: viewModel.getStudentsInClass(widget.classId),
        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: primaryBlue),
            );
          }

          // Error
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Đã xảy ra lỗi: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          // No data
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: CommonEmptyState(
                title: 'Chưa có sinh viên',
                subtitle: 'Lớp học này hiện chưa có sinh viên nào.',
                icon: Icons.people_outline,
              ),
            );
          }

          // Có data
          _allStudents = snapshot.data!;
          final filteredStudents = _getFilteredStudents();

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1600),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // === HEADER + SEARCH + FILTER ===
                    StudentListHeader(
                      className: widget.className,
                      searchController: _searchController,
                      selectedSort: _selectedSort,
                      onSortChanged: _onSortChanged,
                      onClearSearch: _clearSearch,
                      studentCount: filteredStudents.length,
                    ),
                    const SizedBox(height: 24),

                    // === DANH SÁCH SINH VIÊN (DẠNG BẢNG) ===
                    StudentListContent(
                      students: filteredStudents,
                      classId: widget.classId,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
