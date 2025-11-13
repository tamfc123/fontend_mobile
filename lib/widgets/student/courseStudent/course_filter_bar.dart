import 'package:flutter/material.dart';
import 'package:mobile/utils/color_helper.dart';

class CourseFilterBar extends StatelessWidget {
  final String selectedFilter;
  final int totalCount;
  final Map<int, int> levelCounts;
  final ValueChanged<String> onFilterChanged;

  const CourseFilterBar({
    super.key,
    required this.selectedFilter,
    required this.totalCount,
    required this.levelCounts,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(
              label: 'Tất cả',
              value: 'all',
              count: totalCount,
              isSelected: selectedFilter == 'all',
              color: Colors.blue,
              onTap: () => onFilterChanged('all'),
            ),
            const SizedBox(width: 8),
            ...[1, 2, 3, 4, 5, 6].map((level) {
              final colorHelper = ColorHelper();
              final config = colorHelper.getLevelConfig(level);
              final count = levelCounts[level] ?? 0;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildFilterChip(
                  label: config['name'],
                  value: level.toString(),
                  count: count,
                  color: config['color'],
                  icon: config['icon'],
                  isSelected: selectedFilter == level.toString(),
                  onTap: () => onFilterChanged(level.toString()),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required String value,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
    Color? color,
    IconData? icon,
  }) {
    final chipColor = color ?? Colors.blue;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: isSelected ? Colors.white : chipColor),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : chipColor,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? Colors.white.withValues(alpha: 0.3)
                      : chipColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                color: isSelected ? Colors.white : chipColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.white,
      selectedColor: chipColor,
      checkmarkColor: Colors.white,
      side: BorderSide(
        color: isSelected ? chipColor : chipColor.withValues(alpha: 0.3),
        width: 1.5,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}
