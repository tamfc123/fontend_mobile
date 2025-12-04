import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundBlue,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1600),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === HEADER + TÌM KIẾM + FILTER ===
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
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: surfaceBlue,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.people_alt,
                                color: primaryBlue,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Quản lý Tài khoản',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E3A8A),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Tất cả người dùng trong hệ thống',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Consumer<ManageAccountViewModel>(
                              builder: (context, viewModel, child) {
                                return ElevatedButton.icon(
                                  onPressed: () async {
                                    final res = await context.pushNamed<bool>(
                                      'adminCreateUser',
                                    );
                                    if (res == true && context.mounted) {
                                      viewModel.fetchUsers(page: 1);
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.person_add_rounded,
                                    size: 20,
                                  ),
                                  label: const Text(
                                    'Thêm Tài khoản',
                                    style: TextStyle(
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
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      // TÌM KIẾM + FILTER
                      const Padding(
                        padding: EdgeInsets.fromLTRB(24, 0, 24, 20),
                        child: AccountFilter(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // === BẢNG TÀI KHOẢN ===
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
          return AccountTable(
            users: viewModel.users,
            maxWidth: tableWidth,
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
}
