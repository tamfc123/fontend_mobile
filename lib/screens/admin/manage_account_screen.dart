import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile/data/models/user_model.dart';
import 'package:mobile/services/admin/user_service.dart';
import 'package:mobile/widgets/admin/comfirm_delete_dialog.dart';
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
  String _searchQuery = '';

  // MÀU CHỦ ĐẠO (ĐỒNG NHẤT)
  static const Color primaryBlue = Colors.blue;
  static const Color backgroundBlue = Color(0xFFF3F8FF);
  static const Color surfaceBlue = Color(0xFFE3F2FD);

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<UserService>().fetchUsers(page: 1));
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _confirmDelete(UserModel user) {
    showDialog(
      context: context,
      builder:
          (_) => ConfirmDeleteDialog(
            title: 'Xác nhận xóa',
            content: 'Bạn có chắc muốn xóa tài khoản "${user.name}"?',
            itemName: user.name,
            onConfirm: () async {
              await context.read<UserService>().deleteUser(user.id);
            },
          ),
    );
  }

  void _handleToggleUserStatus(UserModel user) async {
    final confirmed = await showToggleUserDialog(context: context, user: user);
    if (confirmed == true) {
      await context.read<UserService>().toggleUserStatus(user.id);
    }
  }

  void _goToAddAccount() async {
    final res = await context.pushNamed<bool>(
      'adminCreateUser', // Tên route bạn vừa đăng ký ở Bước 1
    );
    if (res == true && mounted) {
      context.read<UserService>().fetchUsers(page: 1);
    }
  }

  void _goToEditUser(UserModel userToEdit) async {
    // 1. Điều hướng sang màn hình Sửa, gửi 'userToEdit' qua 'extra'
    final res = await context.pushNamed<bool>(
      'adminUpdateUser', // Tên route bạn đã đăng ký ở Task 2
      extra: userToEdit, // Gửi object user
    );

    // 2. Kiểm tra kết quả trả về
    // (Service của bạn đã tự động refresh,
    // nhưng chúng ta vẫn có thể refresh lại trang hiện tại cho chắc)
    if (res == true && mounted) {
      final currentPage = context.read<UserService>().currentPage;
      context.read<UserService>().fetchUsers(page: currentPage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userService = context.watch<UserService>();
    final users = userService.users;

    final filteredUsers =
        users.where((u) {
          return u.name.toLowerCase().contains(_searchQuery) ||
              u.email.toLowerCase().contains(_searchQuery);
        }).toList();

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
                // === HEADER + TÌM KIẾM + FILTER (KHÔNG CÓ BACK) ===
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
                      // HEADER ROW
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                        child: Row(
                          children: [
                            // ICON + TIÊU ĐỀ
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

                            // NÚT THÊM
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

                      // TÌM KIẾM + FILTER + STATS
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                        child: Column(
                          children: [
                            // TÌM KIẾM
                            Container(
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
                                      _searchQuery.isNotEmpty
                                          ? IconButton(
                                            icon: Icon(
                                              Icons.clear,
                                              color: Colors.grey.shade600,
                                            ),
                                            onPressed:
                                                () => _searchController.clear(),
                                          )
                                          : null,
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // FILTERS
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
                                                    .read<UserService>()
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
                                                    .read<UserService>()
                                                    .updateStatusFilter(v)
                                                : null,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // STATS
                            if (filteredUsers.isNotEmpty)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Tìm thấy ${userService.totalItems} tài khoản (Trang ${userService.currentPage}/${userService.totalPages})',
                                  style: TextStyle(
                                    color: primaryBlue,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
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
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Container(
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
                          child:
                              userService.isLoading
                                  ? const Center(
                                    child: CircularProgressIndicator(
                                      color: primaryBlue,
                                    ),
                                  )
                                  : userService.errorMessage != null
                                  ? Center(
                                    child: Text(
                                      userService.errorMessage!,
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  )
                                  : filteredUsers.isEmpty
                                  ? _buildEmptyState()
                                  : Column(
                                    children: [
                                      Expanded(
                                        child: _buildResponsiveTable(
                                          filteredUsers,
                                          constraints.maxWidth,
                                        ),
                                      ),
                                      _buildPagination(userService),
                                    ],
                                  ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_off_outlined,
            size: 72,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? 'Chưa có tài khoản nào'
                : 'Không tìm thấy tài khoản',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'Nhấn "Thêm Tài khoản" để bắt đầu'
                : 'Thử tìm kiếm bằng từ khóa khác',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveTable(List<UserModel> users, double maxWidth) {
    final colWidths = {
      0: maxWidth * 0.16, // Tên
      1: maxWidth * 0.20, // Email
      2: maxWidth * 0.14, // SĐT
      3: maxWidth * 0.11, // Ngày sinh
      4: maxWidth * 0.10, // Vai trò
      5: maxWidth * 0.11, // Trạng thái
      6: maxWidth * 0.18, // Hành động
    };

    return SingleChildScrollView(
      child: IntrinsicWidth(
        child: Table(
          columnWidths: colWidths.map(
            (k, v) => MapEntry(k, FixedColumnWidth(v)),
          ),
          border: TableBorder(
            bottom: BorderSide(color: surfaceBlue),
            horizontalInside: BorderSide(
              color: Colors.grey.shade200,
              width: 0.5,
            ),
          ),
          children: [
            // Header
            TableRow(
              decoration: BoxDecoration(color: surfaceBlue),
              children:
                  [
                        'Tên',
                        'Email',
                        'SĐT',
                        'Ngày sinh',
                        'Vai trò',
                        'Trạng thái',
                        'Hành động',
                      ]
                      .map(
                        (t) => Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            t,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: primaryBlue,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                      .toList(),
            ),
            // Rows
            ...users.map((user) {
              return TableRow(
                children: [
                  _buildCell(
                    user.name,
                    bold: true,
                    color: const Color(0xFF1E3A8A),
                    align: TextAlign.center,
                  ),
                  _buildCell(user.email, align: TextAlign.center),
                  _buildCell(user.phone, align: TextAlign.center),
                  _buildCell(
                    user.birthday != null
                        ? _dateFormat.format(user.birthday!)
                        : '—',
                    align: TextAlign.center,
                  ),
                  _buildCell(
                    user.role,
                    color:
                        user.role == 'admin'
                            ? Colors.red.shade700
                            : user.role == 'teacher'
                            ? Colors.green.shade700
                            : Colors.blue.shade700,
                    align: TextAlign.center,
                  ),
                  _buildCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
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
                        _buildActionButton(
                          Icons.edit_note_rounded, // Icon Sửa
                          Colors.blue.shade600, // Màu xanh
                          'Sửa', // Tiêu đề
                          () => _goToEditUser(user), // Gọi hàm mới
                        ),
                        const SizedBox(width: 8),
                        _buildActionButton(
                          user.isActive ? Icons.lock_outline : Icons.lock_open,
                          Colors.orange.shade600,
                          user.isActive ? 'Khóa tài khoản' : 'Mở khóa',
                          () => _handleToggleUserStatus(user),
                        ),
                        const SizedBox(width: 8),
                        _buildActionButton(
                          Icons.delete,
                          Colors.redAccent,
                          'Xóa',
                          () => _confirmDelete(user),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPagination(UserService service) {
    if (service.totalPages <= 1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceBlue,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            onPressed:
                service.currentPage > 1
                    ? () => context.read<UserService>().fetchUsers(
                      page: service.currentPage - 1,
                    )
                    : null,
            color: primaryBlue,
          ),
          Text(
            'Trang ${service.currentPage} / ${service.totalPages}',
            style: TextStyle(fontWeight: FontWeight.w600, color: primaryBlue),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 18),
            onPressed:
                service.currentPage < service.totalPages
                    ? () => context.read<UserService>().fetchUsers(
                      page: service.currentPage + 1,
                    )
                    : null,
            color: primaryBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildCell(
    dynamic content, {
    TextAlign align = TextAlign.left,
    bool bold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child:
          content is Widget
              ? content
              : Text(
                content.toString(),
                style: TextStyle(
                  fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
                  color: color ?? Colors.black87,
                  fontSize: 14,
                ),
                textAlign: align,
                overflow: TextOverflow.ellipsis,
              ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    Color color,
    String tooltip,
    VoidCallback onPressed,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 22),
        tooltip: tooltip,
        onPressed: onPressed,
        padding: const EdgeInsets.all(10),
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      ),
    );
  }

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
}
