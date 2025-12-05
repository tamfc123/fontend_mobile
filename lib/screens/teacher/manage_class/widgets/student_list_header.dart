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

  // Responsive helpers
  bool _isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;
  bool _isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1024;

  double _getHorizontalPadding(BuildContext context) {
    if (_isMobile(context)) return 16.0;
    if (_isTablet(context)) return 20.0;
    return 24.0;
  }

  double _getTitleFontSize(BuildContext context) {
    if (_isMobile(context)) return 18.0;
    if (_isTablet(context)) return 20.0;
    return 24.0;
  }

  double _getSubtitleFontSize(BuildContext context) {
    if (_isMobile(context)) return 13.0;
    if (_isTablet(context)) return 14.0;
    return 15.0;
  }

  double _getIconSize(BuildContext context) {
    if (_isMobile(context)) return 22.0;
    if (_isTablet(context)) return 24.0;
    return 28.0;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = _isMobile(context);
    final horizontalPadding = _getHorizontalPadding(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.06),
            blurRadius: isMobile ? 12 : 16,
            offset: Offset(0, isMobile ? 4 : 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // HEADER ROW
          Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              isMobile ? 16 : 24,
              horizontalPadding,
              isMobile ? 12 : 16,
            ),
            child: Row(
              children: [
                // NÚT BACK (Admin style with Container)
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    padding: EdgeInsets.all(isMobile ? 6 : 8),
                    decoration: BoxDecoration(
                      color: surfaceBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: primaryBlue,
                      size: _getIconSize(context),
                    ),
                  ),
                ),
                SizedBox(width: isMobile ? 12 : 16),

                // ICON + TIÊU ĐỀ
                Container(
                  padding: EdgeInsets.all(isMobile ? 10 : 12),
                  decoration: BoxDecoration(
                    color: surfaceBlue,
                    borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
                  ),
                  child: Icon(
                    Icons.people,
                    color: primaryBlue,
                    size: _getIconSize(context),
                  ),
                ),
                SizedBox(width: isMobile ? 12 : 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Danh sách sinh viên',
                        style: TextStyle(
                          fontSize: _getTitleFontSize(context),
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E3A8A),
                        ),
                      ),
                      Text(
                        'Lớp: $className',
                        style: TextStyle(
                          fontSize: _getSubtitleFontSize(context),
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
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              0,
              horizontalPadding,
              isMobile ? 16 : 20,
            ),
            child:
                isMobile
                    ? Column(
                      children: [
                        // Search bar full width on mobile
                        Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: surfaceBlue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: searchController,
                            decoration: InputDecoration(
                              hintText: 'Tìm kiếm sinh viên...',
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
                        const SizedBox(height: 12),
                        // Sort dropdown full width on mobile
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
                              isExpanded: true,
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
                    )
                    : Row(
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
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade600,
                                ),
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
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                isMobile ? 8 : 0,
                horizontalPadding,
                isMobile ? 12 : 16,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Hiển thị $studentCount sinh viên',
                  style: TextStyle(
                    color: primaryBlue,
                    fontWeight: FontWeight.w600,
                    fontSize: isMobile ? 14.0 : 15.0,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
