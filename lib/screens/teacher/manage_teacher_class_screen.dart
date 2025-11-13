import 'dart:async'; // 🔹 Thêm import này cho Timer (debouncer)
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/data/models/teacher_class_model.dart';
import 'package:mobile/services/teacher/teacher_class_service.dart';
import 'package:mobile/widgets/teacher/teacher_class_add_edit_dialog.dart';
import 'package:provider/provider.dart';

// Thêm enum để map với ClassSortType của service
enum SortOption {
  courseNameAsc,
  courseNameDesc,
  studentCountAsc,
  studentCountDesc,
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

  // 🔹 Thêm debouncer
  Timer? _debounce;

  // MÀU CHỦ ĐẠO (ĐỒNG NHẤT)
  static const Color primaryBlue = Colors.blue;
  static const Color backgroundBlue = Color(0xFFF3F8FF);
  static const Color surfaceBlue = Color(0xFFE3F2FD);

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();

    // 🔹 Lắng nghe sự kiện gõ phím để search
    _searchController.addListener(_onSearchChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final classService = context.read<TeacherClassService>();
      // 🔹 Lấy trạng thái sort/search hiện tại từ service
      _selectedSort = _mapServiceSortToUiSort(classService.currentSortType);
      _searchController.text = classService.currentSearch ?? '';

      // Gọi fetch lần đầu
      classService.fetchTeacherClasses();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel(); // Hủy timer
    _searchController.removeListener(_onSearchChanged); // Hủy listener
    _searchController.dispose();
    super.dispose();
  }

  // 🔹 Hàm xử lý search (debouncer)
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.read<TeacherClassService>().applySearch(_searchController.text);
      }
    });
  }

  // 🔹 Hàm xử lý dialog
  void _showFormDialog({TeacherClassModel? classModel}) {
    // Cập nhật kiểu
    final classService = context.read<TeacherClassService>();
    showDialog(
      context: context,
      builder:
          (_) => ChangeNotifierProvider.value(
            value: classService,
            child: TeacherClassFormDialog(classModel: classModel),
          ),
    );
  }

  // 🔹 [CẬP NHẬT] Hàm xử lý sort
  void _onSortChanged(SortOption? option) {
    setState(() => _selectedSort = option);
    final classService = context.read<TeacherClassService>();
    if (option != null) {
      // Ánh xạ từ UI Enum sang Service Enum
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
      }
      // Gọi hàm applySort mới của service
      classService.applySort(serviceSortType);
    }
  }

  // 🔹 Helper để map ngược từ Service Sort sang UI Sort (cho initState)
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final classService = context.watch<TeacherClassService>();

    // 🔹 [CẬP NHẬT] Dùng trực tiếp 'classes' từ service
    //    Vì nó đã được lọc và sắp xếp bởi backend
    final classes = classService.classes;
    final isLoading = classService.isLoading;

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
                // === HEADER + TÌM KIẾM + FILTER (KHÔNG CÓ BACK) ===
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
                      // HEADER ROW
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                        child: Row(
                          children: [
                            // ICON + TIÊU ĐỀ
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
                          ],
                        ),
                      ),

                      // TÌM KIẾM + FILTER + STATS
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                        child: Column(
                          children: [
                            // TÌM KIẾM
                            Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: surfaceBlue,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: 'Tìm kiếm theo tên lớp/khóa học...',
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
                                              // Gọi applySearch ngay lập tức
                                              // (Không cần qua debouncer)
                                              context
                                                  .read<TeacherClassService>()
                                                  .applySearch('');
                                            },
                                          )
                                          : null,
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // FILTERS (SORT)
                            Row(
                              children: [
                                Expanded(
                                  child: _buildDropdown<SortOption>(
                                    value: _selectedSort,
                                    items: const [
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
                            const SizedBox(height: 12),

                            // STATS
                            if (!isLoading && classes.isNotEmpty)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Tìm thấy ${classes.length} lớp học",
                                  style: TextStyle(
                                    color: primaryBlue,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // === BẢNG LỚP HỌC ===
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Container(
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
                          child:
                              isLoading
                                  ? const Center(
                                    child: CircularProgressIndicator(
                                      color: primaryBlue,
                                    ),
                                  )
                                  : classes.isEmpty
                                  ? _buildEmptyState()
                                  : SingleChildScrollView(
                                    child: _buildResponsiveTable(
                                      classes,
                                      constraints.maxWidth,
                                    ),
                                  ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.class_outlined, size: 72, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'Không tìm thấy lớp học nào',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Thử tìm kiếm bằng từ khóa khác',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveTable(
    List<TeacherClassModel> classes,
    double maxWidth,
  ) {
    final colWidths = {
      0: maxWidth * 0.35, // Tên lớp
      1: maxWidth * 0.25, // Khóa học
      2: maxWidth * 0.15, // Số SV
      3: maxWidth * 0.25, // Thao tác
    };

    return SingleChildScrollView(
      child: IntrinsicWidth(
        child: Table(
          columnWidths: colWidths.map(
            (k, v) => MapEntry(k, FixedColumnWidth(v)),
          ),
          border: TableBorder(
            bottom: BorderSide(color: surfaceBlue),
            horizontalInside: BorderSide(
              color: Colors.grey.shade200,
              width: 0.5,
            ),
          ),
          children: [
            // Header
            TableRow(
              decoration: BoxDecoration(color: surfaceBlue),
              children:
                  ['Tên lớp', 'Khóa học', 'Số sinh viên', 'Thao tác']
                      .map(
                        (t) => Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            t,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: primaryBlue,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                      .toList(),
            ),
            // Rows
            ...classes.map((c) {
              return TableRow(
                children: [
                  _buildCell(
                    c.name,
                    bold: true,
                    color: const Color(0xFF1E3A8A),
                    align: TextAlign.center,
                  ),
                  _buildCell(c.courseName ?? '—', align: TextAlign.center),
                  _buildCell(
                    c.studentCount.toString(),
                    align: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildActionButton(
                          Icons.quiz,
                          Colors.purple,
                          'Xem bài tập',
                          () {
                            context.go(
                              '/teacher/teacherClasses/${c.id}/quiz',
                              extra: c.name,
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        _buildActionButton(
                          Icons.edit,
                          Colors.blue,
                          'Đổi tên lớp',
                          () => _showFormDialog(classModel: c),
                        ),
                        const SizedBox(width: 12),
                        _buildActionButton(
                          Icons.people,
                          Colors.teal,
                          'Xem danh sách sinh viên',
                          () {
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
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCell(
    dynamic content, {
    TextAlign align = TextAlign.left,
    bool bold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child:
          content is Widget
              ? content
              : Text(
                content.toString(),
                style: TextStyle(
                  fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
                  color: color ?? Colors.black87,
                  fontSize: 14,
                ),
                textAlign: align,
                overflow: TextOverflow.ellipsis,
              ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    Color color,
    String tooltip,
    VoidCallback onPressed,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 22),
        tooltip: tooltip,
        onPressed: onPressed,
        padding: const EdgeInsets.all(10),
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      ),
    );
  }

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
}
