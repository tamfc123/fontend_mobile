import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/data/models/student_in_class_model.dart';
import 'package:mobile/services/teacher/teacher_class_service.dart';
import 'package:mobile/shared_widgets/avatar_widget.dart';
import 'package:mobile/shared_widgets/admin/base_admin_table.dart'; // ✅ Import bảng chuẩn
import 'package:mobile/shared_widgets/admin/common_table_cell.dart'; // ✅ Import cell chuẩn
import 'package:mobile/shared_widgets/admin/action_icon_button.dart'; // ✅ Import nút chuẩn
import 'package:mobile/shared_widgets/admin/common_empty_state.dart'; // ✅ Import Empty State chuẩn
import 'package:mobile/widgets/teacher/student_info_dialog.dart';
import 'package:mobile/widgets/teacher/student_skill_dialog.dart';
import 'package:provider/provider.dart';

// Enum cho sort sinh viên
enum SortOptionStudent { nameAsc, nameDesc, expAsc, expDesc }

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
  static const Color surfaceBlue = Color(0xFFE3F2FD);

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
    final service = context.read<TeacherAdminClassService>();

    return Scaffold(
      backgroundColor: backgroundBlue,
      body: FutureBuilder<List<StudentInClassModel>>(
        future: service.getStudentsInClass(widget.classId),
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
                                // NÚT BACK
                                IconButton(
                                  onPressed: () => context.pop(),
                                  icon: const Icon(
                                    Icons.arrow_back_ios,
                                    color: primaryBlue,
                                    size: 20,
                                  ),
                                  tooltip: 'Quay lại',
                                  style: IconButton.styleFrom(
                                    backgroundColor: surfaceBlue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // ICON + TIÊU ĐỀ
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: surfaceBlue,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.people,
                                    color: primaryBlue,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Danh sách sinh viên',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1E3A8A),
                                        ),
                                      ),
                                      Text(
                                        'Lớp: ${widget.className}',
                                        style: const TextStyle(
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

                          // SEARCH + SORT
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: surfaceBlue,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: TextField(
                                      controller: _searchController,
                                      decoration: InputDecoration(
                                        hintText: 'Tìm kiếm theo tên/email...',
                                        hintStyle: TextStyle(
                                          color: Colors.grey.shade600,
                                        ),
                                        prefixIcon: const Icon(
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
                                                  onPressed: _clearSearch,
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
                                const SizedBox(width: 16),

                                // SORT DROPDOWN
                                Container(
                                  height: 48,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: surfaceBlue,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<SortOptionStudent>(
                                      value: _selectedSort,
                                      icon: const Icon(
                                        Icons.sort,
                                        color: primaryBlue,
                                      ),
                                      hint: const Text("Sắp xếp"),
                                      items: const [
                                        DropdownMenuItem(
                                          value: SortOptionStudent.nameAsc,
                                          child: Text('Tên A→Z'),
                                        ),
                                        DropdownMenuItem(
                                          value: SortOptionStudent.nameDesc,
                                          child: Text('Tên Z→A'),
                                        ),
                                        DropdownMenuItem(
                                          value: SortOptionStudent.expDesc,
                                          child: Text('EXP Cao nhất'),
                                        ),
                                        DropdownMenuItem(
                                          value: SortOptionStudent.expAsc,
                                          child: Text('EXP Thấp nhất'),
                                        ),
                                      ],
                                      onChanged: _onSortChanged,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // STATS TEXT
                          if (filteredStudents.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Hiển thị ${filteredStudents.length} sinh viên',
                                  style: const TextStyle(
                                    color: primaryBlue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // === DANH SÁCH SINH VIÊN (DẠNG BẢNG) ===
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          if (filteredStudents.isEmpty) {
                            return CommonEmptyState(
                              title: "Không tìm thấy kết quả",
                              subtitle: "Thử tìm kiếm với từ khóa khác",
                              icon: Icons.search_off,
                            );
                          }
                          // ✅ Gọi hàm xây dựng bảng
                          return _buildStudentTable(
                            filteredStudents,
                            constraints.maxWidth,
                          );
                        },
                      ),
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

  // ✅ HÀM XÂY DỰNG BẢNG CHUẨN ADMIN
  Widget _buildStudentTable(
    List<StudentInClassModel> students,
    double maxWidth,
  ) {
    // Cấu hình độ rộng cột
    final colWidths = {
      0: maxWidth * 0.05, // STT
      1: maxWidth * 0.30, // Sinh viên (Avatar + Tên)
      2: maxWidth * 0.25, // Email
      3: maxWidth * 0.10, // Level
      4: maxWidth * 0.10, // EXP
      5: maxWidth * 0.20, // Hành động (Nút mới ở đây)
    };

    final colHeaders = ['#', 'Sinh viên', 'Email', 'Level', 'EXP', 'Hành động'];

    final dataRows =
        students.asMap().entries.map((entry) {
          final index = entry.key + 1;
          final student = entry.value;

          return TableRow(
            children: [
              // 1. STT
              CommonTableCell('$index', align: TextAlign.center, bold: true),

              // 2. Sinh viên (Avatar + Tên)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    AvatarWidget(
                      avatarUrl: student.avatarUrl,
                      name: student.studentName,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        student.studentName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E3A8A), // Màu xanh Admin
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Email
              CommonTableCell(student.email),

              // 4. Level
              CommonTableCell(
                'Lv.${student.level}',
                align: TextAlign.center,
                color: Colors.orange.shade800,
                bold: true,
              ),

              // 5. EXP
              CommonTableCell(
                '${student.experiencePoints}',
                align: TextAlign.center,
              ),

              // 6. Hành động (Thêm nút Analytics)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Nút xem chi tiết (Info)
                    ActionIconButton(
                      icon: Icons.info_outline_rounded,
                      color: Colors.grey,
                      tooltip: 'Thông tin cá nhân',
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder:
                              (_) => StudentInfoDialog(
                                classId: widget.classId,
                                studentId: student.studentId,
                              ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    ActionIconButton(
                      icon: Icons.analytics_rounded,
                      color: primaryBlue,
                      tooltip: 'Đánh giá năng lực',
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder:
                              (_) => StudentSkillDialog(
                                classId: widget.classId,
                                studentId: student.studentId,
                                studentName: student.studentName,
                                avatarUrl: student.avatarUrl,
                              ),
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
