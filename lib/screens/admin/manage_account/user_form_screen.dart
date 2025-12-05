import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/data/models/user_model.dart';
import 'package:mobile/domain/repositories/admin/admin_user_repository.dart';
import 'package:mobile/utils/toast_helper.dart';
import 'package:provider/provider.dart';

// Định nghĩa màu sắc
class AppColors {
  // MÀU CHỦ ĐẠO
  static const Color primaryBlue = Colors.blue;
  static const Color backgroundBlue = Color(0xFFF3F8FF);
  static const Color surfaceBlue = Color(0xFFE3F2FD);
}

class UserFormScreen extends StatefulWidget {
  final UserModel? user; // null = create mode, non-null = edit mode

  const UserFormScreen({super.key, this.user});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _phoneController;

  DateTime? _selectedBirthday;
  String _selectedRole = 'student';
  bool _isLoading = false;

  // Helper getters
  bool get isEditMode => widget.user != null;
  bool get isCreateMode => widget.user == null;

  @override
  void initState() {
    super.initState();
    // Initialize controllers
    _nameController = TextEditingController(text: widget.user?.name ?? '');
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _passwordController = TextEditingController();
    _phoneController = TextEditingController(text: widget.user?.phone ?? '');

    // Pre-fill data in edit mode
    if (isEditMode) {
      _selectedBirthday = widget.user!.birthday;
      _selectedRole = widget.user!.role.toLowerCase();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedBirthday == null) {
      ToastHelper.showError('Vui lòng chọn ngày sinh');
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (isCreateMode) {
        // Create mode - include password and email
        final userData = {
          'name': _nameController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
          'phone': _phoneController.text,
          'role': _selectedRole,
          'birthday': _selectedBirthday!.toIso8601String(),
        };
        await context.read<AdminUserRepository>().createUser(userData);
        ToastHelper.showSuccess('Tạo tài khoản thành công');
      } else {
        // Edit mode - exclude password and email
        final userData = {
          'name': _nameController.text,
          'phone': _phoneController.text,
          'role': _selectedRole,
          'birthday': _selectedBirthday!.toIso8601String(),
        };
        await context.read<AdminUserRepository>().updateUser(
          widget.user!.id,
          userData,
        );
        ToastHelper.showSuccess('Cập nhật tài khoản thành công');
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      ToastHelper.showError(
        '${isCreateMode ? "Tạo" : "Cập nhật"} tài khoản thất bại: ${e.toString().replaceFirst('Exception: ', '')}',
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthday ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedBirthday) {
      setState(() {
        _selectedBirthday = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final maxWidth = isMobile ? double.infinity : 600.0;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                children: [
                  // Nút quay lại
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundBlue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: AppColors.primaryBlue,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Icon và thông tin
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isEditMode ? Icons.edit : Icons.person_add_outlined,
                      color: AppColors.primaryBlue,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isEditMode
                              ? 'Cập nhật tài khoản'
                              : 'Tạo tài khoản mới',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isEditMode
                              ? 'Chỉnh sửa thông tin người dùng'
                              : 'Thêm người dùng mới vào hệ thống',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.backgroundBlue, Colors.white],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Form(
                key: _formKey,
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Tiêu đề
                        Text(
                          'Thông tin cơ bản',
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Họ và tên
                        _buildTextField(
                          controller: _nameController,
                          label: 'Họ và tên',
                          icon: Icons.person_outline,
                          hint: 'Nhập họ và tên',
                          validator:
                              (value) =>
                                  (value == null || value.isEmpty)
                                      ? 'Không được để trống'
                                      : null,
                        ),
                        const SizedBox(height: 20),

                        // Email
                        _buildTextField(
                          controller: _emailController,
                          label:
                              isEditMode
                                  ? 'Email (Không thể thay đổi)'
                                  : 'Email',
                          icon: Icons.email_outlined,
                          hint: 'Nhập email',
                          keyboardType: TextInputType.emailAddress,
                          readOnly: isEditMode,
                          validator:
                              isCreateMode
                                  ? (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Không được để trống';
                                    }
                                    if (!value.contains('@')) {
                                      return 'Email không hợp lệ';
                                    }
                                    return null;
                                  }
                                  : null,
                        ),
                        const SizedBox(height: 20),

                        // Mật khẩu (only in create mode)
                        if (isCreateMode) ...[
                          _buildTextField(
                            controller: _passwordController,
                            label: 'Mật khẩu',
                            icon: Icons.lock_outline,
                            hint: 'Nhập mật khẩu (tối thiểu 6 ký tự)',
                            obscureText: true,
                            validator:
                                (value) =>
                                    (value == null || value.length < 6)
                                        ? 'Mật khẩu phải từ 6 ký tự'
                                        : null,
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Số điện thoại
                        _buildTextField(
                          controller: _phoneController,
                          label: 'Số điện thoại',
                          icon: Icons.phone_outlined,
                          hint: 'Nhập số điện thoại',
                          keyboardType: TextInputType.phone,
                          validator:
                              (value) =>
                                  (value == null || value.isEmpty)
                                      ? 'Không được để trống'
                                      : null,
                        ),
                        const SizedBox(height: 20),

                        // Ngày sinh
                        _buildDateField(),
                        const SizedBox(height: 32),

                        // Tiêu đề Vai trò
                        Text(
                          'Vai trò người dùng',
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Role Selection
                        _buildRoleSelector(),
                        const SizedBox(height: 40),

                        // Nút Submit
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _submitForm,
                          icon:
                              _isLoading
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                  : Icon(
                                    isEditMode
                                        ? Icons.save_outlined
                                        : Icons.add_circle_outline_rounded,
                                  ),
                          label: Text(
                            _isLoading
                                ? (isEditMode ? 'Đang lưu...' : 'Đang tạo...')
                                : (isEditMode
                                    ? 'Lưu thay đổi'
                                    : 'Tạo tài khoản'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    bool readOnly = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primaryBlue),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFBBDEFB), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFBBDEFB), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
        filled: true,
        fillColor: readOnly ? Colors.grey.shade200 : AppColors.backgroundBlue,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 16,
        ),
        labelStyle: const TextStyle(color: Color(0xFF1976D2)),
        hintStyle: const TextStyle(color: Colors.grey),
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFBBDEFB), width: 2),
          borderRadius: BorderRadius.circular(8),
          color: AppColors.backgroundBlue,
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined, color: AppColors.primaryBlue),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedBirthday == null
                    ? 'Chọn ngày sinh'
                    : 'Ngày sinh: ${DateFormat('dd/MM/yyyy').format(_selectedBirthday!)}',
                style: TextStyle(
                  color: _selectedBirthday == null ? Colors.grey : Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Row(
      children: [
        Expanded(
          child: _buildRoleOption(
            value: 'student',
            label: 'Học viên',
            subtitle: 'Student',
            icon: Icons.school_outlined,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildRoleOption(
            value: 'teacher',
            label: 'Giảng viên',
            subtitle: 'Teacher',
            icon: Icons.person_4_outlined,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildRoleOption(
            value: 'staff',
            label: 'Nhân viên',
            subtitle: 'Staff',
            icon: Icons.person_4_outlined,
          ),
        ),
        // Admin option - only show in edit mode
        if (isEditMode) ...[
          const SizedBox(width: 16),
          Expanded(
            child: _buildRoleOption(
              value: 'admin',
              label: 'Quản trị',
              subtitle: 'Admin',
              icon: Icons.admin_panel_settings_outlined,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRoleOption({
    required String value,
    required String label,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedRole == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : const Color(0xFFBBDEFB),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? AppColors.surfaceBlue : AppColors.backgroundBlue,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primaryBlue : Colors.grey[400],
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.primaryBlue : Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
