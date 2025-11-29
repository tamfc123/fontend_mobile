// file: screens/admin/manage_account_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile/data/models/user_model.dart';
import 'package:mobile/services/admin/admin_user_service.dart';
// ✅ 1. IMPORT CÁC WIDGET DÙNG CHUNG
import 'package:mobile/shared_widgets/admin/base_admin_table.dart';
import 'package:mobile/shared_widgets/admin/common_empty_state.dart';
import 'package:mobile/shared_widgets/admin/action_icon_button.dart';
import 'package:mobile/shared_widgets/admin/common_table_cell.dart';
import 'package:mobile/shared_widgets/admin/pagination_controls.dart'; // Import pagination mới
import 'package:mobile/shared_widgets/admin/comfirm_delete_dialog.dart';
// ✅ 2. (GỢI Ý) Di chuyển file này
import 'package:mobile/widgets/admin/comfirm_toggle_status.dart';
import 'package:provider/provider.dart';

class ManageAccountScreen extends StatefulWidget {
  const ManageAccountScreen({super.key});

  @override
  State<ManageAccountScreen> createState() => _ManageAccountScreenState();
}

class _ManageAccountScreenState extends State<ManageAccountScreen> {
  final TextEditingController _searchController = TextEditingController();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  Timer? _debounce; // ✅ Thêm debounce

  // MÀU CHỦ ĐẠO
  static const Color primaryBlue = Colors.blue;
  static const Color backgroundBlue = Color(0xFFF3F8FF);
  static const Color surfaceBlue = Color(0xFFE3F2FD);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userService = context.read<AdminUserService>();
      _searchController.text = userService.searchQuery ?? '';

      // Tải dữ liệu lần đầu (Không cần fetchTeachers/Courses ở đây)
      userService.fetchUsers(page: 1);
    });

    _searchController.addListener(_onSearchChanged); // ✅ Dùng debounce
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // ✅ Hàm debounce
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        // Gọi service (service sẽ tự fetch trang 1)
        context.read<AdminUserService>().applySearch(_searchController.text);
      }
    });
  }

  void _handleToggleUserStatus(UserModel user) async {
    final confirmed = await showToggleUserDialog(context: context, user: user);
    if (confirmed == true) {
      await context.read<AdminUserService>().toggleUserStatus(user.id);
    }
  }

  void _goToAddAccount() async {
    final res = await context.pushNamed<bool>('adminCreateUser');
    if (res == true && mounted) {
      context.read<AdminUserService>().fetchUsers(page: 1);
    }
  }

  void _goToEditUser(UserModel userToEdit) async {
    final res = await context.pushNamed<bool>(
      'adminUpdateUser',
      extra: userToEdit,
    );
    if (res == true && mounted) {
      final currentPage = context.read<AdminUserService>().currentPage;
      context.read<AdminUserService>().fetchUsers(page: currentPage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userService = context.watch<AdminUserService>();
    final users = userService.users;
    final isLoading = userService.isLoading;

    // ❌ BỎ LỌC CLIENT-SIDE
    // final filteredUsers = ...

    // ✅ XÂY DỰNG BODYCONTENT
    Widget bodyContent;
    if (isLoading && users.isEmpty) {
      // Dùng `users`
      bodyContent = const Center(
        child: CircularProgressIndicator(color: primaryBlue),
      );
    } else if (userService.errorMessage != null) {
      bodyContent = Center(
        child: Text(
          userService.errorMessage!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    } else if (users.isEmpty) {
      // Dùng `users`
      bodyContent = _buildEmptyStateWidget(userService.searchQuery);
    } else {
      bodyContent = LayoutBuilder(
        builder:
            (context, constraints) => _buildResponsiveTableWidget(
              users,
              constraints.maxWidth,
            ), // Dùng `users`
      );
    }

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
                // === HEADER + TÌM KIẾM + FILTER (Giữ nguyên) ===
                // (Phần này là unique, không dùng BaseAdminScreen)
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // HEADER ROW (Giữ nguyên)
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
                            ElevatedButton.icon(
                              onPressed: _goToAddAccount,
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
                            ),
                          ],
                        ),
                      ),

                      // TÌM KIẾM + FILTER (Giữ nguyên)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                        child: Column(
                          children: [
                            Row(
                              // ✅ Bọc Row
                              children: [
                                Expanded(
                                  // ✅ Bọc TextField
                                  child: Container(
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: surfaceBlue,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: TextField(
                                      controller: _searchController,
                                      decoration: InputDecoration(
                                        hintText: 'Tìm kiếm theo tên, email...',
                                        hintStyle: TextStyle(
                                          color: Colors.grey.shade600,
                                        ),
                                        prefixIcon: Icon(
                                          Icons.search,
                                          color: primaryBlue,
                                        ),
                                        suffixIcon:
                                            _searchController.text.isNotEmpty
                                                ? IconButton(
                                                  icon: Icon(
                                                    Icons.clear,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                  onPressed:
                                                      () =>
                                                          _searchController
                                                              .clear(),
                                                )
                                                : null,
                                        border: InputBorder.none,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              vertical: 14,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16), // ✅ Thêm
                                if (!isLoading) // ✅ Thêm
                                  Text(
                                    "Tìm thấy: ${userService.totalItems} T.khoản",
                                    style: const TextStyle(
                                      color: primaryBlue,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildDropdown<UserRole>(
                                    value: userService.roleFilter,
                                    items: const [
                                      DropdownMenuItem(
                                        value: UserRole.all,
                                        child: Text('Tất cả vai trò'),
                                      ),
                                      DropdownMenuItem(
                                        value: UserRole.admin,
                                        child: Text('Quản trị viên'),
                                      ),
                                      DropdownMenuItem(
                                        value: UserRole.teacher,
                                        child: Text('Giảng viên'),
                                      ),
                                      DropdownMenuItem(
                                        value: UserRole.student,
                                        child: Text('Học viên'),
                                      ),
                                    ],
                                    onChanged:
                                        (v) =>
                                            v != null
                                                ? context
                                                    .read<AdminUserService>()
                                                    .updateRoleFilter(v)
                                                : null,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildDropdown<UserStatus>(
                                    value: userService.statusFilter,
                                    items: const [
                                      DropdownMenuItem(
                                        value: UserStatus.all,
                                        child: Text('Tất cả trạng thái'),
                                      ),
                                      DropdownMenuItem(
                                        value: UserStatus.active,
                                        child: Text('Hoạt động'),
                                      ),
                                      DropdownMenuItem(
                                        value: UserStatus.blocked,
                                        child: Text('Bị khóa'),
                                      ),
                                    ],
                                    onChanged:
                                        (v) =>
                                            v != null
                                                ? context
                                                    .read<AdminUserService>()
                                                    .updateStatusFilter(v)
                                                : null,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
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
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Column(
                        children: [
                          Expanded(
                            child: bodyContent, // 👈 Đẩy body vào
                          ),
                          // ✅ SỬ DỤNG PaginationControls
                          PaginationControls(
                            currentPage: userService.currentPage,
                            totalPages: userService.totalPages,
                            totalCount: userService.totalItems, // Sửa tên biến
                            isLoading: isLoading,
                            onPageChanged: (page) {
                              context.read<AdminUserService>().fetchUsers(
                                page: page,
                              );
                            },
                          ),
                        ],
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

  // ✅ SỬ DỤNG CommonEmptyState
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

  // ✅ SỬ DỤNG BaseAdminTable
  Widget _buildResponsiveTableWidget(List<UserModel> users, double maxWidth) {
    final colWidths = {
      0: maxWidth * 0.16,
      1: maxWidth * 0.20,
      2: maxWidth * 0.14,
      3: maxWidth * 0.11,
      4: maxWidth * 0.10,
      5: maxWidth * 0.11,
      6: maxWidth * 0.18,
    };
    final colHeaders = [
      'Tên',
      'Email',
      'SĐT',
      'Ngày sinh',
      'Vai trò',
      'Trạng thái',
      'Hành động',
    ];

    final dataRows =
        users.map((user) {
          return TableRow(
            children: [
              // ✅ SỬ DỤNG CommonTableCell
              CommonTableCell(
                user.name,
                bold: true,
                color: const Color(0xFF1E3A8A),
                align: TextAlign.center,
              ),
              CommonTableCell(user.email, align: TextAlign.center),
              CommonTableCell(user.phone, align: TextAlign.center),
              CommonTableCell(
                user.birthday != null
                    ? _dateFormat.format(user.birthday!)
                    : '—',
                align: TextAlign.center,
              ),
              CommonTableCell(
                user.role,
                color:
                    user.role == 'admin'
                        ? Colors.red.shade700
                        : user.role == 'teacher'
                        ? Colors.green.shade700
                        : Colors.blue.shade700,
                align: TextAlign.center,
              ),
              CommonTableCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      user.isActive ? Icons.check_circle : Icons.block,
                      size: 16,
                      color: user.isActive ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      user.isActive ? 'Hoạt động' : 'Bị khóa',
                      style: TextStyle(
                        color:
                            user.isActive
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
                align: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ✅ SỬ DỤNG ActionIconButton
                    ActionIconButton(
                      icon: Icons.edit_note_rounded,
                      color: Colors.blue.shade600,
                      tooltip: 'Sửa',
                      onPressed: () => _goToEditUser(user),
                    ),
                    const SizedBox(width: 8),
                    ActionIconButton(
                      icon:
                          user.isActive ? Icons.lock_outline : Icons.lock_open,
                      color: Colors.orange.shade600,
                      tooltip: user.isActive ? 'Khóa tài khoản' : 'Mở khóa',
                      onPressed: () => _handleToggleUserStatus(user),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList();

    return BaseAdminTable(
      columnWidths: colWidths.map((k, v) => MapEntry(k, FixedColumnWidth(v))),
      columnHeaders: colHeaders,
      dataRows: dataRows,
    );
  }

  // (Hàm _buildDropdown giữ nguyên, vì nó là unique)
  Widget _buildDropdown<T>({
    required T value,
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
        icon: Icon(Icons.keyboard_arrow_down_rounded, color: primaryBlue),
        onChanged: onChanged,
      ),
    );
  }

  // ❌ XÓA _buildCell, _buildActionButton, VÀ _buildPagination
}
