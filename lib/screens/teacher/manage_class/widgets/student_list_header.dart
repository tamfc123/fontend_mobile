import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum SortOptionStudent { nameAsc, nameDesc, expAsc, expDesc }

class StudentListHeader extends StatelessWidget {
  final String className;
  final TextEditingController searchController;
  final SortOptionStudent? selectedSort;
  final Function(SortOptionStudent?) onSortChanged;
  final VoidCallback onClearSearch;
  final int studentCount;

  const StudentListHeader({
    super.key,
    required this.className,
    required this.searchController,
    required this.selectedSort,
    required this.onSortChanged,
    required this.onClearSearch,
    required this.studentCount,
  });

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
                  child: const Icon(Icons.people, color: primaryBlue, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                        'Lớp: $className',
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
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm theo tên/email...',
                        hintStyle: TextStyle(color: Colors.grey.shade600),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: primaryBlue,
                        ),
                        suffixIcon:
                            searchController.text.isNotEmpty
                                ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: Colors.grey.shade600,
                                  ),
                                  onPressed: onClearSearch,
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

                // SORT DROPDOWN
                Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: surfaceBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<SortOptionStudent>(
                      value: selectedSort,
                      icon: const Icon(Icons.sort, color: primaryBlue),
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
                      onChanged: onSortChanged,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // STATS TEXT
          if (studentCount > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Hiển thị $studentCount sinh viên',
                  style: const TextStyle(
                    color: primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
