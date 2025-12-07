import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/services/auth/auth_service.dart';

import 'package:mobile/screens/admin/manage_account/manage_account_view_model.dart';
import 'package:mobile/screens/admin/manage_account/widgets/account_filter.dart';
import 'package:mobile/screens/admin/manage_account/widgets/account_table.dart';
import 'package:mobile/shared_widgets/admin/common_empty_state.dart';
import 'package:mobile/shared_widgets/admin/pagination_controls.dart';
import 'package:provider/provider.dart';

class ManageAccountScreen extends StatefulWidget {
  const ManageAccountScreen({super.key});

  @override
  State<ManageAccountScreen> createState() => _ManageAccountScreenState();
}

class _ManageAccountScreenState extends State<ManageAccountScreen> {
  static const Color primaryBlue = Colors.blue;
  static const Color backgroundBlue = Color(0xFFF3F8FF);
  static const Color surfaceBlue = Color(0xFFE3F2FD);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ManageAccountViewModel>().init();
    });
  }

  // Responsive helpers
  bool _isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;
  bool _isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1024;

  double _getHorizontalPadding(BuildContext context) {
    if (_isMobile(context)) return 12.0;
    if (_isTablet(context)) return 16.0;
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

  double _getButtonFontSize(BuildContext context) {
    if (_isMobile(context)) return 14.0;
    return 15.0;
  }

  double _getIconSize(BuildContext context) {
    if (_isMobile(context)) return 22.0;
    if (_isTablet(context)) return 24.0;
    return 28.0;
  }

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
    final isMobile = _isMobile(context);
    final horizontalPadding = _getHorizontalPadding(context);
    return Scaffold(
      backgroundColor: backgroundBlue,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isMobile ? double.infinity : 1600,
          ),
          child: Padding(
            padding: EdgeInsets.all(horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === HEADER + TÌM KIẾM + FILTER ===
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
                      // HEADER ROW
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          horizontalPadding,
                          horizontalPadding,
                          isMobile ? 12 : 16,
                        ),
                        child:
                            isMobile
                                ? _buildMobileHeader(context)
                                : _buildDesktopHeader(context),
                      ),

                      // TÌM KIẾM + FILTER
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          0,
                          horizontalPadding,
                          isMobile ? 16 : 20,
                        ),
                        child: const AccountFilter(),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isMobile ? 16 : 24),

                // === BẢNG TÀI KHOẢN ===
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
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Consumer<ManageAccountViewModel>(
                        builder: (context, viewModel, child) {
                          return Column(
                            children: [
                              Expanded(
                                child: _buildBodyContent(context, viewModel),
                              ),
                              PaginationControls(
                                currentPage: viewModel.currentPage,
                                totalPages: viewModel.totalPages,
                                totalCount: viewModel.totalItems,
                                isLoading: viewModel.isLoading,
                                onPageChanged: (page) {
                                  viewModel.fetchUsers(page: page);
                                },
                              ),
                            ],
                          );
                        },
                      ),
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

  Widget _buildBodyContent(
    BuildContext context,
    ManageAccountViewModel viewModel,
  ) {
    if (viewModel.isLoading && viewModel.users.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: primaryBlue));
    } else if (viewModel.errorMessage != null) {
      return Center(
        child: Text(
          viewModel.errorMessage!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    } else if (viewModel.users.isEmpty) {
      return _buildEmptyStateWidget(viewModel.searchQuery);
    } else {
      return LayoutBuilder(
        builder: (context, constraints) {
          final double tableWidth =
              constraints.maxWidth < 1000 ? 1000 : constraints.maxWidth;
          final currentUserRole =
              context.watch<AuthService>().currentUser?.role;
          return AccountTable(
            users: viewModel.users,
            maxWidth: tableWidth,
            currentUserRole: currentUserRole,
            onEdit: (user) async {
              final res = await context.pushNamed<bool>(
                'adminUpdateUser',
                extra: user,
              );
              if (res == true && context.mounted) {
                viewModel.fetchUsers();
              }
            },
            onToggleStatus: (user) {
              viewModel.toggleUserStatus(user.id);
            },
          );
        },
      );
    }
  }

  Widget _buildEmptyStateWidget(String? searchQuery) {
    bool isSearching = searchQuery != null && searchQuery.isNotEmpty;
    return CommonEmptyState(
      icon: Icons.person_off_outlined,
      title: isSearching ? 'Không tìm thấy tài khoản' : 'Chưa có tài khoản nào',
      subtitle:
          isSearching
              ? 'Thử tìm kiếm bằng từ khóa khác'
              : 'Nhấn "Thêm Tài khoản" để bắt đầu',
    );
  }

  Widget _buildMobileHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: surfaceBlue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.people_alt,
                color: primaryBlue,
                size: _getIconSize(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quản lý Tài khoản',
                    style: TextStyle(
                      fontSize: _getTitleFontSize(context),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tất cả người dùng trong hệ thống',
                    style: TextStyle(
                      fontSize: _getSubtitleFontSize(context),
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Consumer<ManageAccountViewModel>(
          builder: (context, viewModel, child) {
            final currentUserRole =
                context.watch<AuthService>().currentUser?.role;
            // Only show Add Account button for admin
            if (currentUserRole != 'admin') {
              return const SizedBox.shrink();
            }
            return ElevatedButton.icon(
              onPressed: () async {
                final res = await context.pushNamed<bool>('adminCreateUser');
                if (res == true && context.mounted) {
                  viewModel.fetchUsers(page: 1);
                }
              },
              icon: Icon(
                Icons.person_add_rounded,
                size: _isMobile(context) ? 18 : 20,
              ),
              label: Text(
                'Thêm Tài khoản',
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
            );
          },
        ),
      ],
    );
  }

  Widget _buildDesktopHeader(BuildContext context) {
    final isTablet = _isTablet(context);
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(isTablet ? 10 : 12),
          decoration: BoxDecoration(
            color: surfaceBlue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.people_alt,
            color: primaryBlue,
            size: _getIconSize(context),
          ),
        ),
        SizedBox(width: isTablet ? 12 : 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quản lý Tài khoản',
                style: TextStyle(
                  fontSize: _getTitleFontSize(context),
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E3A8A),
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'Tất cả người dùng trong hệ thống',
                style: TextStyle(
                  fontSize: _getSubtitleFontSize(context),
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        SizedBox(width: isTablet ? 8 : 16),
        Consumer<ManageAccountViewModel>(
          builder: (context, viewModel, child) {
            final currentUserRole =
                context.watch<AuthService>().currentUser?.role;
            // Only show Add Account button for admin
            if (currentUserRole != 'admin') {
              return const SizedBox.shrink();
            }
            return ElevatedButton.icon(
              onPressed: () async {
                final res = await context.pushNamed<bool>('adminCreateUser');
                if (res == true && context.mounted) {
                  viewModel.fetchUsers(page: 1);
                }
              },
              icon: Icon(Icons.person_add_rounded, size: isTablet ? 18 : 20),
              label: Text(
                'Thêm Tài khoản',
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
            );
          },
        ),
      ],
    );
  }
}
