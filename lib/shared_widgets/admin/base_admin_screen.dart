import 'package:flutter/material.dart';

class BaseAdminScreen extends StatelessWidget {
  // Màu sắc
  static const Color primaryBlue = Colors.blue;
  static const Color backgroundBlue = Color(0xFFF3F8FF);
  static const Color surfaceBlue = Color(0xFFE3F2FD);

  // --- Header ---
  final String title;
  final String? subtitle;
  final IconData headerIcon;
  final VoidCallback onAddPressed;
  final String addLabel;
  final VoidCallback? onBackPressed; // Null nếu không có nút back

  // --- Search ---
  final TextEditingController searchController;
  final String searchHint;
  final bool isLoading;
  final int totalCount;
  final String countLabel; // "chương", "bài", "từ"...

  // --- Content ---
  final Widget body; // Đây là cái bảng (Table)
  final Widget paginationControls; // Đây là PaginationControls ở trên

  const BaseAdminScreen({
    super.key,
    required this.title,
    this.subtitle,
    required this.headerIcon,
    required this.onAddPressed,
    required this.addLabel,
    this.onBackPressed,
    required this.searchController,
    required this.searchHint,
    required this.isLoading,
    required this.totalCount,
    required this.countLabel,
    required this.body,
    required this.paginationControls,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundBlue,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400), // Max width
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === HEADER + TÌM KIẾM ===
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
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
                            // NÚT QUAY LẠI (Nếu có)
                            if (onBackPressed != null)
                              ElevatedButton.icon(
                                onPressed: onBackPressed,
                                icon: const Icon(
                                  Icons.arrow_back_ios_new,
                                  size: 18,
                                ),
                                label: const Text(
                                  'Quay lại',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryBlue,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            if (onBackPressed != null)
                              const SizedBox(width: 16),

                            // ICON + TIÊU ĐỀ
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: surfaceBlue,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                headerIcon,
                                color: primaryBlue,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E3A8A),
                                    ),
                                  ),
                                  if (subtitle != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      subtitle!,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            // NÚT THÊM
                            ElevatedButton.icon(
                              onPressed: onAddPressed,
                              icon: const Icon(
                                Icons.add_circle_outline,
                                size: 20,
                              ),
                              label: Text(
                                addLabel,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryBlue,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 22,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // THANH TÌM KIẾM
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
                                    hintText: searchHint,
                                    hintStyle: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                    prefixIcon: Icon(
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
                                              onPressed: searchController.clear,
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
                            if (!isLoading)
                              Text(
                                "Tìm thấy: $totalCount $countLabel",
                                style: const TextStyle(
                                  color: primaryBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // === NỘI DUNG CHÍNH (BẢNG) ===
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Bảng
                        Expanded(child: body),
                        // Thanh phân trang
                        paginationControls,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
