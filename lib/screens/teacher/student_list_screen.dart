import 'dart:async'; // Cho Timer debouncer
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/data/models/student_in_class_model.dart';
import 'package:mobile/services/teacher/teacher_class_service.dart';
import 'package:mobile/shared_widgets/avatar_widget.dart';
import 'package:provider/provider.dart';

// Enum cho sort sinh viên (tương tự ManageTeacherClassScreen)
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

  // MÀU CHỦ ĐẠO (ĐỒNG NHẤT VỚI MANAGE CLASS)
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

  // Debouncer cho search: trigger rebuild sau khi gõ
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {}); // Trigger rebuild để tính filtered mới
      }
    });
  }

  // Xử lý sort change: update sort và trigger rebuild
  void _onSortChanged(SortOptionStudent? option) {
    setState(() => _selectedSort = option);
  }

  // Clear search: clear text và trigger rebuild
  void _clearSearch() {
    _searchController.clear();
    setState(() {}); // Trigger rebuild
  }

  // Pure function: Lọc và sắp xếp data (gọi trong build)
  List<StudentInClassModel> _getFilteredStudents() {
    var students = _allStudents;
    final query = _searchController.text.toLowerCase();

    // Filter theo search (tên hoặc email)
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

    // Sort theo option
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
            return _buildEmptyState(
              isSearchActive: _searchController.text.isNotEmpty,
            );
          }

          // Có data: cập nhật _allStudents (không setState, vì FutureBuilder sẽ rebuild)
          _allStudents = snapshot.data!;

          // Tính filtered students (pure function)
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
                          // HEADER ROW VỚI BACK BUTTON
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                            child: Row(
                              children: [
                                // NÚT BACK BÊN TRÁI
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
                                      Text(
                                        'Danh sách sinh viên',
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1E3A8A),
                                        ),
                                      ),
                                      Text(
                                        'Lớp: ${widget.className}',
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

                          // SEARCH + FILTER + STATS
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                            child: Column(
                              children: [
                                // SEARCH
                                Container(
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
                                const SizedBox(height: 16),

                                // FILTER (SORT)
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildDropdown<SortOptionStudent>(
                                        value: _selectedSort,
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
                                            value: SortOptionStudent.expAsc,
                                            child: Text('EXP tăng dần'),
                                          ),
                                          DropdownMenuItem(
                                            value: SortOptionStudent.expDesc,
                                            child: Text('EXP giảm dần'),
                                          ),
                                        ],
                                        onChanged: _onSortChanged,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // STATS
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Tìm thấy ${filteredStudents.length} sinh viên',
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

                    // === DANH SÁCH SINH VIÊN ===
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
                          child:
                              filteredStudents.isEmpty
                                  ? _buildEmptyState(
                                    isSearchActive:
                                        _searchController.text.isNotEmpty,
                                  )
                                  : ListView.builder(
                                    padding: const EdgeInsets.all(16),
                                    itemCount: filteredStudents.length,
                                    itemBuilder: (context, index) {
                                      final student = filteredStudents[index];
                                      return Card(
                                        margin: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        elevation: 1,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: ListTile(
                                          leading: AvatarWidget(
                                            avatarUrl: student.avatarUrl,
                                            name: student.studentName,
                                          ),
                                          title: Text(
                                            student.studentName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          subtitle: Text(student.email),
                                          trailing: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                'EXP: ${student.experiencePoints}',
                                                style: TextStyle(
                                                  color: primaryBlue,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              if (student.level != null)
                                                Text('Level: ${student.level}'),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                        ),
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

  Widget _buildEmptyState({required bool isSearchActive}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 72, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            isSearchActive
                ? 'Không tìm thấy sinh viên nào'
                : 'Lớp này chưa có sinh viên',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isSearchActive ? 'Thử từ khóa khác' : '',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
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
