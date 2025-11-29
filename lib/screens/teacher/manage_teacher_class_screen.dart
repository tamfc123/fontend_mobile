import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/data/models/teacher_class_model.dart';
import 'package:mobile/services/teacher/teacher_class_service.dart';
import 'package:mobile/shared_widgets/admin/base_admin_table.dart';
import 'package:mobile/shared_widgets/admin/common_empty_state.dart';
import 'package:mobile/shared_widgets/admin/action_icon_button.dart';
import 'package:mobile/shared_widgets/admin/common_table_cell.dart';
import 'package:mobile/shared_widgets/admin/pagination_controls.dart';
import 'package:provider/provider.dart';

enum SortOption {
  courseNameAsc,
  courseNameDesc,
  studentCountAsc,
  studentCountDesc,
  nameAsc,
  nameDesc,
}

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
  static const Color primaryBlue = Colors.blue;
  static const Color backgroundBlue = Color(0xFFF3F8FF);
  static const Color surfaceBlue = Color(0xFFE3F2FD);

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final AdminClassService = context.read<TeacherAdminClassService>();
      _selectedSort = _mapServiceSortToUiSort(
        AdminClassService.currentSortType,
      );
      _searchController.text = AdminClassService.currentSearch ?? '';

      AdminClassService.fetchTeacherClasses();
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
        context.read<TeacherAdminClassService>().applySearch(
          _searchController.text,
        );
      }
    });
  }

  void _onSortChanged(SortOption? option) {
    setState(() => _selectedSort = option);
    final AdminClassService = context.read<TeacherAdminClassService>();
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
      AdminClassService.applySort(serviceSortType);
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
    final AdminClassService = context.watch<TeacherAdminClassService>();
    final classes = AdminClassService.classes;
    final isLoading = AdminClassService.isLoading;

    // ✅ 3. XÂY DỰNG BODYCONTENT
    Widget bodyContent;
    if (isLoading && classes.isEmpty) {
      bodyContent = const Center(
        child: CircularProgressIndicator(color: primaryBlue),
      );
    } else if (classes.isEmpty) {
      bodyContent = _buildEmptyStateWidget(
        AdminClassService.currentSearchQuery,
      ); // 👈 Sửa
    } else {
      bodyContent = LayoutBuilder(
        builder:
            (context, constraints) => _buildResponsiveTableWidget(
              context,
              classes,
              constraints.maxWidth,
            ), // 👈 Sửa
      );
    }

    return Scaffold(
      backgroundColor: backgroundBlue,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1600),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === HEADER + TÌM KIẾM + FILTER (Giữ nguyên) ===
                // (Phần này là unique, không dùng BaseAdminScreen)
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // HEADER ROW (Giữ nguyên)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: surfaceBlue,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.class_,
                                color: primaryBlue,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Lớp tôi phụ trách',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E3A8A),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Tất cả lớp học tôi phụ trách',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // ❌ Xóa Nút Thêm (vì màn này không có)
                          ],
                        ),
                      ),

                      // TÌM KIẾM + FILTER + STATS (Giữ nguyên)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                        child: Column(
                          children: [
                            Row(
                              // ✅ Bọc Row
                              children: [
                                Expanded(
                                  // ✅ Bọc TextField
                                  child: Container(
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: surfaceBlue,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: TextField(
                                      controller: _searchController,
                                      decoration: InputDecoration(
                                        hintText:
                                            'Tìm kiếm theo tên lớp/khóa học...',
                                        hintStyle: TextStyle(
                                          color: Colors.grey.shade600,
                                        ),
                                        prefixIcon: Icon(
                                          Icons.search,
                                          color: primaryBlue,
                                        ),
                                        suffixIcon:
                                            _searchController.text.isNotEmpty
                                                ? IconButton(
                                                  icon: Icon(
                                                    Icons.clear,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                  onPressed: () {
                                                    _searchController.clear();
                                                    context
                                                        .read<
                                                          TeacherAdminClassService
                                                        >()
                                                        .applySearch('');
                                                  },
                                                )
                                                : null,
                                        border: InputBorder.none,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              vertical: 14,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16), // ✅ Thêm
                                if (!isLoading) // ✅ Thêm
                                  Text(
                                    "Tìm thấy: ${AdminClassService.totalCount} lớp",
                                    style: const TextStyle(
                                      color: primaryBlue,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // FILTERS (SORT)
                            Row(
                              children: [
                                Expanded(
                                  child: _buildDropdown<SortOption>(
                                    // 👈 Hàm này giữ lại
                                    value: _selectedSort,
                                    items: const [
                                      DropdownMenuItem(
                                        value: SortOption.nameAsc,
                                        child: Text('Tên lớp A→Z'),
                                      ),
                                      DropdownMenuItem(
                                        value: SortOption.nameDesc,
                                        child: Text('Tên lớp Z→A'),
                                      ),
                                      DropdownMenuItem(
                                        value: SortOption.courseNameAsc,
                                        child: Text('Khóa học A→Z'),
                                      ),
                                      DropdownMenuItem(
                                        value: SortOption.courseNameDesc,
                                        child: Text('Khóa học Z→A'),
                                      ),
                                      DropdownMenuItem(
                                        value: SortOption.studentCountAsc,
                                        child: Text('SV tăng dần'),
                                      ),
                                      DropdownMenuItem(
                                        value: SortOption.studentCountDesc,
                                        child: Text('SV giảm dần'),
                                      ),
                                    ],
                                    onChanged: _onSortChanged,
                                  ),
                                ),
                              ],
                            ),
                            // ❌ Xóa Text "Tìm thấy..." ở đây
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // === BẢNG LỚP HỌC ===
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Column(
                        // 👈 Bọc Column
                        children: [
                          Expanded(
                            child: bodyContent, // 👈 Đẩy body vào
                          ),
                          // ✅ SỬ DỤNG PaginationControls
                          PaginationControls(
                            currentPage: AdminClassService.currentPage,
                            totalPages: AdminClassService.totalPages,
                            totalCount: AdminClassService.totalCount,
                            isLoading: isLoading,
                            onPageChanged: (page) {
                              // 👈 Service này dùng hàm goToPage
                              context.read<TeacherAdminClassService>().goToPage(
                                page,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ 5. SỬ DỤNG CommonEmptyState
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

  // ✅ 6. SỬ DỤNG BaseAdminTable
  Widget _buildResponsiveTableWidget(
    BuildContext context, // Thêm context
    List<TeacherClassModel> classes,
    double maxWidth,
  ) {
    final colWidths = {
      0: maxWidth * 0.35,
      1: maxWidth * 0.25,
      2: maxWidth * 0.15,
      3: maxWidth * 0.25,
    };
    final colHeaders = ['Tên lớp', 'Khóa học', 'Số sinh viên', 'Thao tác'];

    final int startingIndex =
        (context.read<TeacherAdminClassService>().currentPage - 1) * 5;

    final dataRows =
        classes.asMap().entries.map((entry) {
          final index = entry.key + startingIndex + 1; // Tính STT
          final c = entry.value;
          return TableRow(
            children: [
              // ✅ 7. SỬ DỤNG CommonTableCell
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
                    // ✅ 8. SỬ DỤNG ActionIconButton
                    ActionIconButton(
                      icon: Icons.quiz,
                      color: Colors.purple,
                      tooltip: 'Xem bài tập',
                      onPressed: () {
                        // Dùng context.push để giữ nút Back
                        context.push(
                          '/teacher/teacherClasses/${c.id}/quizzes', // 1. Sửa 'quiz' thành 'quizzes'
                          extra:
                              c, // 2. Truyền cả object ClassModel (biến c), không truyền c.name
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

  // (Hàm _buildDropdown giữ nguyên, vì nó là unique)
  Widget _buildDropdown<T>({
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required Function(T?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButton<T>(
        value: value,
        items: items,
        isExpanded: true,
        underline: const SizedBox(),
        icon: Icon(Icons.keyboard_arrow_down_rounded, color: primaryBlue),
        onChanged: onChanged,
      ),
    );
  }

  // ❌ 9. XÓA _buildCell, _buildActionButton, _buildEmptyState, _buildResponsiveTable, VÀ _buildPaginationControls
}
