// file: shared_widgets/pagination_controls.dart
import 'package:flutter/material.dart';

class PaginationControls extends StatelessWidget {
  static const Color primaryBlue = Colors.blue;
  static const Color surfaceBlue = Color(0xFFE3F2FD);

  final int currentPage;
  final int totalPages;
  final int totalCount;
  final bool isLoading;
  final Function(int) onPageChanged;

  const PaginationControls({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    required this.isLoading,
    required this.onPageChanged,
  });

  // Responsive helpers
  bool _isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) {
      return const SizedBox(height: 60); // Giữ chiều cao layout
    }

    final isMobile = _isMobile(context);

    return Container(
      height: isMobile ? null : 60, // Auto height on mobile
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 16,
        vertical: isMobile ? 12 : 8,
      ),
      decoration: BoxDecoration(
        color: surfaceBlue,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 0.5),
        ),
      ),
      child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
    );
  }

  // Mobile Layout - Compact & Stacked
  Widget _buildMobileLayout() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Page info - more compact
        Text(
          'Trang $currentPage/$totalPages',
          style: const TextStyle(
            color: primaryBlue,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Tổng: $totalCount',
          style: TextStyle(
            color: primaryBlue.withValues(alpha: 0.7),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        // Navigation buttons - compact
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // First page
            _buildCompactIconButton(
              icon: Icons.first_page_rounded,
              onPressed:
                  (currentPage > 1 && !isLoading)
                      ? () => onPageChanged(1)
                      : null,
            ),
            const SizedBox(width: 4),
            // Previous page
            _buildCompactIconButton(
              icon: Icons.chevron_left_rounded,
              onPressed:
                  (currentPage > 1 && !isLoading)
                      ? () => onPageChanged(currentPage - 1)
                      : null,
            ),
            const SizedBox(width: 12),
            // Next page
            _buildCompactIconButton(
              icon: Icons.chevron_right_rounded,
              onPressed:
                  (currentPage < totalPages && !isLoading)
                      ? () => onPageChanged(currentPage + 1)
                      : null,
            ),
            const SizedBox(width: 4),
            // Last page
            _buildCompactIconButton(
              icon: Icons.last_page_rounded,
              onPressed:
                  (currentPage < totalPages && !isLoading)
                      ? () => onPageChanged(totalPages)
                      : null,
            ),
          ],
        ),
      ],
    );
  }

  // Desktop Layout - Original horizontal layout
  Widget _buildDesktopLayout() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Text hiển thị Tổng
        Text(
          'Trang $currentPage / $totalPages (Tổng: $totalCount)',
          style: const TextStyle(
            color: primaryBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
        Row(
          children: [
            // Nút Về Trang Đầu
            IconButton(
              icon: const Icon(Icons.first_page_rounded),
              color: primaryBlue,
              onPressed:
                  (currentPage > 1 && !isLoading)
                      ? () => onPageChanged(1)
                      : null,
            ),
            // Nút Lùi 1 Trang
            IconButton(
              icon: const Icon(Icons.chevron_left_rounded),
              color: primaryBlue,
              onPressed:
                  (currentPage > 1 && !isLoading)
                      ? () => onPageChanged(currentPage - 1)
                      : null,
            ),
            const SizedBox(width: 16),
            // Nút Tới 1 Trang
            IconButton(
              icon: const Icon(Icons.chevron_right_rounded),
              color: primaryBlue,
              onPressed:
                  (currentPage < totalPages && !isLoading)
                      ? () => onPageChanged(currentPage + 1)
                      : null,
            ),
            // Nút Tới Trang Cuối
            IconButton(
              icon: const Icon(Icons.last_page_rounded),
              color: primaryBlue,
              onPressed:
                  (currentPage < totalPages && !isLoading)
                      ? () => onPageChanged(totalPages)
                      : null,
            ),
          ],
        ),
      ],
    );
  }

  // Compact icon button for mobile
  Widget _buildCompactIconButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color:
            onPressed != null
                ? primaryBlue.withValues(alpha: 0.1)
                : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon),
        color: onPressed != null ? primaryBlue : Colors.grey.shade400,
        onPressed: onPressed,
        iconSize: 20,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      ),
    );
  }
}
