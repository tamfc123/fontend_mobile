import 'package:flutter/material.dart';
import 'package:mobile/screens/admin/manage_account/manage_account_view_model.dart';
import 'package:provider/provider.dart';

class AccountFilter extends StatefulWidget {
  const AccountFilter({super.key});

  @override
  State<AccountFilter> createState() => _AccountFilterState();
}

class _AccountFilterState extends State<AccountFilter> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final viewModel = context.read<ManageAccountViewModel>();
    _searchController.text = viewModel.searchQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ManageAccountViewModel>();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD), // surfaceBlue
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: viewModel.onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm theo tên, email...',
                    hintStyle: TextStyle(color: Colors.grey.shade600),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Colors.blue, // primaryBlue
                    ),
                    suffixIcon:
                        _searchController.text.isNotEmpty
                            ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: Colors.grey.shade600,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                viewModel.onSearchChanged('');
                              },
                            )
                            : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            if (!viewModel.isLoading)
              Text(
                "Tìm thấy: ${viewModel.totalItems} T.khoản",
                style: const TextStyle(
                  color: Colors.blue, // primaryBlue
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
                value: viewModel.roleFilter,
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
                  DropdownMenuItem(
                    value: UserRole.staff,
                    child: Text('Nhân viên'),
                  ),
                ],
                onChanged:
                    (v) => v != null ? viewModel.updateRoleFilter(v) : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDropdown<UserStatus>(
                value: viewModel.statusFilter,
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
                    (v) => v != null ? viewModel.updateStatusFilter(v) : null,
              ),
            ),
          ],
        ),
      ],
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
        color: const Color(0xFFE3F2FD), // Blue theme
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButton<T>(
        value: value,
        items: items,
        isExpanded: true,
        underline: const SizedBox(),
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.blue),
        onChanged: onChanged,
      ),
    );
  }
}
