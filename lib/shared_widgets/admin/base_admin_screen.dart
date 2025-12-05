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

  // === RESPONSIVE HELPER METHODS ===

  // Screen size breakpoints
  bool _isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  bool _isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1024;

  bool _isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  // Responsive padding
  double _getHorizontalPadding(BuildContext context) {
    if (_isMobile(context)) return 12.0;
    if (_isTablet(context)) return 16.0;
    return 24.0;
  }

  double _getVerticalPadding(BuildContext context) {
    if (_isMobile(context)) return 16.0;
    if (_isTablet(context)) return 20.0;
    return 24.0;
  }

  // Responsive font sizes
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

  double _getButtonFontSize(BuildContext context) {
    if (_isMobile(context)) return 14.0;
    return 15.0;
  }

  // Responsive icon sizes
  double _getHeaderIconSize(BuildContext context) {
    if (_isMobile(context)) return 22.0;
    if (_isTablet(context)) return 24.0;
    return 28.0;
  }

  double _getButtonIconSize(BuildContext context) {
    if (_isMobile(context)) return 18.0;
    return 20.0;
  }

  // Responsive button padding
  EdgeInsets _getButtonPadding(BuildContext context) {
    if (_isMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 12, vertical: 10);
    }
    if (_isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    }
    return const EdgeInsets.symmetric(horizontal: 22, vertical: 16);
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = _getHorizontalPadding(context);
    final verticalPadding = _getVerticalPadding(context);
    final isMobile = _isMobile(context);

    return Scaffold(
      backgroundColor: backgroundBlue,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: _isDesktop(context) ? 1400 : double.infinity,
          ),
          child: Padding(
            padding: EdgeInsets.all(horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === HEADER + TÌM KIẾM ===
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
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
                      // HEADER - Responsive Layout
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          verticalPadding,
                          horizontalPadding,
                          isMobile ? 12 : 16,
                        ),
                        child:
                            isMobile
                                ? _buildMobileHeader(context)
                                : _buildDesktopHeader(context),
                      ),

                      // THANH TÌM KIẾM - Responsive
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          0,
                          horizontalPadding,
                          isMobile ? 16 : 20,
                        ),
                        child:
                            isMobile
                                ? _buildMobileSearch(context)
                                : _buildDesktopSearch(context),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isMobile ? 16 : 24),

                // === NỘI DUNG CHÍNH (BẢNG) ===
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
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
                        Expanded(child: ClipRect(child: body)),
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

  // Mobile Header Layout (Stacked)
  Widget _buildMobileHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Back button + Icon + Title in same Row
        Row(
          children: [
            // Back button (if exists)
            if (onBackPressed != null) ...[
              GestureDetector(
                onTap: onBackPressed,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: surfaceBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_back,
                    color: primaryBlue,
                    size: _getHeaderIconSize(context),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            // Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: surfaceBlue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                headerIcon,
                color: primaryBlue,
                size: _getHeaderIconSize(context),
              ),
            ),
            const SizedBox(width: 12),
            // Title
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: _getTitleFontSize(context),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E3A8A),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: _getSubtitleFontSize(context),
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Add button
        ElevatedButton.icon(
          onPressed: onAddPressed,
          icon: Icon(
            Icons.add_circle_outline,
            size: _getButtonIconSize(context),
          ),
          label: Text(
            addLabel,
            style: TextStyle(
              fontSize: _getButtonFontSize(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: _getButtonPadding(context),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  // Desktop/Tablet Header Layout (Horizontal)
  Widget _buildDesktopHeader(BuildContext context) {
    final isTablet = _isTablet(context);

    return Row(
      children: [
        // NÚT QUAY LẠI (Nếu có)
        if (onBackPressed != null) ...[
          GestureDetector(
            onTap: onBackPressed,
            child: Container(
              padding: EdgeInsets.all(isTablet ? 6 : 8),
              decoration: BoxDecoration(
                color: surfaceBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.arrow_back,
                color: primaryBlue,
                size: _getHeaderIconSize(context),
              ),
            ),
          ),
          SizedBox(width: isTablet ? 12 : 16),
        ],

        // ICON + TIÊU ĐỀ
        Container(
          padding: EdgeInsets.all(isTablet ? 10 : 12),
          decoration: BoxDecoration(
            color: surfaceBlue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            headerIcon,
            color: primaryBlue,
            size: _getHeaderIconSize(context),
          ),
        ),
        SizedBox(width: isTablet ? 12 : 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: _getTitleFontSize(context),
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E3A8A),
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: _getSubtitleFontSize(context),
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
        SizedBox(width: isTablet ? 8 : 16),
        ElevatedButton.icon(
          onPressed: onAddPressed,
          icon: Icon(
            Icons.add_circle_outline,
            size: _getButtonIconSize(context),
          ),
          label: Text(
            addLabel,
            style: TextStyle(
              fontSize: _getButtonFontSize(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: _getButtonPadding(context),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  // Mobile Search (Stacked)
  Widget _buildMobileSearch(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: surfaceBlue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: searchHint,
              hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              prefixIcon: const Icon(
                Icons.search,
                color: primaryBlue,
                size: 20,
              ),
              suffixIcon:
                  searchController.text.isNotEmpty
                      ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: Colors.grey.shade600,
                          size: 20,
                        ),
                        onPressed: searchController.clear,
                      )
                      : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        if (!isLoading) ...[
          const SizedBox(height: 8),
          Text(
            "Tìm thấy: $totalCount $countLabel",
            style: const TextStyle(
              color: primaryBlue,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  // Desktop/Tablet Search (Horizontal)
  Widget _buildDesktopSearch(BuildContext context) {
    return Row(
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
                hintStyle: TextStyle(color: Colors.grey.shade600),
                prefixIcon: const Icon(Icons.search, color: primaryBlue),
                suffixIcon:
                    searchController.text.isNotEmpty
                        ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.grey.shade600),
                          onPressed: searchController.clear,
                        )
                        : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
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
    );
  }
}
