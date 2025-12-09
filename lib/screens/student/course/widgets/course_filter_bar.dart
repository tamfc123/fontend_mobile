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
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(
                  Icons.filter_list_rounded,
                  size: 18,
                  color: Color(0xFF64748B),
                ),
                SizedBox(width: 8),
                Text(
                  'Lọc theo cấp độ',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _ModernCourseFilterChip(
                  label: 'Tất cả',
                  count: totalCount,
                  isSelected: selectedFilter == 'all',
                  color: const Color(0xFF3B82F6), // Blue
                  onTap: () => onFilterChanged('all'),
                ),
                const SizedBox(width: 10),
                ...[1, 2, 3, 4, 5, 6].map((level) {
                  final colorHelper = ColorHelper();
                  final config = colorHelper.getLevelConfig(level);
                  final count = levelCounts[level] ?? 0;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _ModernCourseFilterChip(
                      label: config['name'],
                      count: count,
                      color: const Color(
                        0xFF3B82F6,
                      ), // Blue - same as quiz filter
                      icon: config['icon'],
                      isSelected: selectedFilter == level.toString(),
                      onTap: () => onFilterChanged(level.toString()),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ MODERN COURSE FILTER CHIP WIDGET
class _ModernCourseFilterChip extends StatefulWidget {
  final String label;
  final int count;
  final bool isSelected;
  final Color color;
  final IconData? icon;
  final VoidCallback onTap;

  const _ModernCourseFilterChip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.color,
    this.icon,
    required this.onTap,
  });

  @override
  State<_ModernCourseFilterChip> createState() =>
      _ModernCourseFilterChipState();
}

class _ModernCourseFilterChipState extends State<_ModernCourseFilterChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) {
        _scaleController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _scaleController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient:
                widget.isSelected
                    ? const LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                    : null,
            color: widget.isSelected ? null : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  widget.isSelected
                      ? Colors.transparent
                      : const Color(0xFFE2E8F0),
              width: 1.5,
            ),
            boxShadow:
                widget.isSelected
                    ? [
                      const BoxShadow(
                        color: Color(0x4D3B82F6), // 30% opacity
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ]
                    : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  size: 16,
                  color:
                      widget.isSelected
                          ? Colors.white
                          : const Color(0xFF64748B),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight:
                      widget.isSelected ? FontWeight.bold : FontWeight.w600,
                  color:
                      widget.isSelected
                          ? Colors.white
                          : const Color(0xFF64748B),
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color:
                      widget.isSelected
                          ? Colors.white.withValues(alpha: 0.25)
                          : const Color(0xFF3B82F6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${widget.count}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color:
                        widget.isSelected
                            ? Colors.white
                            : const Color(0xFF3B82F6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
