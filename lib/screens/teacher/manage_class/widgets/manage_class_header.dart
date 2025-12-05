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
                Container(
                  padding: EdgeInsets.all(isMobile ? 10 : 12),
                  decoration: BoxDecoration(
                    color: surfaceBlue,
                    borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
                  ),
                  child: Icon(
                    Icons.class_,
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
                        'Lớp tôi phụ trách',
                        style: TextStyle(
                          fontSize: _getTitleFontSize(context),
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E3A8A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tất cả lớp học tôi phụ trách',
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

          // TÌM KIẾM + FILTER + STATS
          Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              0,
              horizontalPadding,
              isMobile ? 16 : 20,
            ),
            child: Column(
              children: [
                // Search bar and stats - stack on mobile
                if (isMobile) ...[
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: surfaceBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: widget.searchController,
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm lớp học...',
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
                  const SizedBox(height: 12),
                  if (!widget.isLoading)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "Tìm thấy: ${widget.totalCount} lớp",
                        style: const TextStyle(
                          color: primaryBlue,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                ] else
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
                SizedBox(height: isMobile ? 12 : 16),
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
