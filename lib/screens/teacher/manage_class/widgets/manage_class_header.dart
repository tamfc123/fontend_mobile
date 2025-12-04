import 'package:flutter/material.dart';
import 'package:mobile/screens/teacher/manage_class/teacher_class_view_model.dart';
import 'package:provider/provider.dart';

enum SortOption {
  courseNameAsc,
  courseNameDesc,
  studentCountAsc,
  studentCountDesc,
  nameAsc,
  nameDesc,
}

class ManageTeacherClassHeader extends StatefulWidget {
  final TextEditingController searchController;
  final SortOption? selectedSort;
  final Function(SortOption?) onSortChanged;
  final bool isLoading;
  final int totalCount;

  const ManageTeacherClassHeader({
    super.key,
    required this.searchController,
    required this.selectedSort,
    required this.onSortChanged,
    required this.isLoading,
    required this.totalCount,
  });

  @override
  State<ManageTeacherClassHeader> createState() =>
      _ManageTeacherClassHeaderState();
}

class _ManageTeacherClassHeaderState extends State<ManageTeacherClassHeader> {
  static const Color primaryBlue = Colors.blue;
  static const Color surfaceBlue = Color(0xFFE3F2FD);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.06),
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
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: surfaceBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.class_, color: primaryBlue, size: 28),
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
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: surfaceBlue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: widget.searchController,
                          decoration: InputDecoration(
                            hintText: 'Tìm kiếm theo tên lớp/khóa học...',
                            hintStyle: TextStyle(color: Colors.grey.shade600),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: primaryBlue,
                            ),
                            suffixIcon:
                                widget.searchController.text.isNotEmpty
                                    ? IconButton(
                                      icon: Icon(
                                        Icons.clear,
                                        color: Colors.grey.shade600,
                                      ),
                                      onPressed: () {
                                        widget.searchController.clear();
                                        context
                                            .read<TeacherClassViewModel>()
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
                    ),
                    const SizedBox(width: 16),
                    if (!widget.isLoading)
                      Text(
                        "Tìm thấy: ${widget.totalCount} lớp",
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
                        value: widget.selectedSort,
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
                        onChanged: widget.onSortChanged,
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: primaryBlue),
        onChanged: onChanged,
      ),
    );
  }
}
