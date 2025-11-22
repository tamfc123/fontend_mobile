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

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) {
      return const SizedBox(height: 60); // Giữ chiều cao layout
    }

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      child: Row(
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
      ),
    );
  }
}
