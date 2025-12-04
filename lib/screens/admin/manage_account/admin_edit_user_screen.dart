import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/data/models/user_model.dart'; // Import UserModel
import 'package:mobile/domain/repositories/admin/admin_user_repository.dart';
import 'package:mobile/utils/toast_helper.dart';
import 'package:provider/provider.dart';

class EditUserScreen extends StatefulWidget {
  // 1. Nhận UserModel
  final UserModel user;
  const EditUserScreen({super.key, required this.user});

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers cho các trường
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  // Biến cho các trường đặc biệt
  DateTime? _selectedBirthday;
  String _selectedRole = 'student';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 2. Điền sẵn thông tin từ widget.user vào controller
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phone);
    _selectedBirthday = widget.user.birthday;
    _selectedRole = widget.user.role.toLowerCase();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Hàm xử lý việc gửi form
  Future<void> _submitForm() async {
    // 1. Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }
    // 2. Kiểm tra ngày sinh
    if (_selectedBirthday == null) {
      ToastHelper.showError('Vui lòng chọn ngày sinh');
      return;
    }

    setState(() => _isLoading = true);

    // 3. Tạo Map data để gửi đi (Khớp với AdminUpdateUserRequest DTO)
    final userData = {
      'name': _nameController.text,
      'phone': _phoneController.text,
      'role': _selectedRole,
      'birthday': _selectedBirthday!.toIso8601String(),
    };

    try {
      // 4. Gọi Repository Update
      await context.read<AdminUserRepository>().updateUser(
        widget.user.id,
        userData,
      );

      ToastHelper.showSuccess('Cập nhật tài khoản thành công');

      if (mounted) {
        // 5. Nếu thành công, quay lại màn hình trước
        Navigator.pop(context, true); // Gửi true để báo refresh
      }
    } catch (e) {
      ToastHelper.showError(
        'Cập nhật thất bại: ${e.toString().replaceFirst('Exception: ', '')}',
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Hàm chọn ngày
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthday ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedBirthday) {
      setState(() {
        _selectedBirthday = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cập nhật tài khoản'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tên
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Họ và tên',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        (value == null || value.isEmpty)
                            ? 'Không được để trống'
                            : null,
              ),
              const SizedBox(height: 16),

              // Email (Bị khóa)
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email (Không thể thay đổi)',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey.shade200, // Màu nền xám
                ),
                readOnly: true, // Không cho sửa
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // (Không có trường mật khẩu, vì chúng ta đã tách logic)

              // Số điện thoại
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại',
                  prefixIcon: Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator:
                    (value) =>
                        (value == null || value.isEmpty)
                            ? 'Không được để trống'
                            : null,
              ),
              const SizedBox(height: 16),

              // Ngày sinh
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(4),
                ),
                leading: const Icon(Icons.calendar_today_outlined),
                title: Text(
                  _selectedBirthday == null
                      ? 'Chọn ngày sinh'
                      : 'Ngày sinh: ${DateFormat('dd/MM/yyyy').format(_selectedBirthday!)}',
                ),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 16),

              // Dropdown chọn Vai trò (Role)
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Vai trò',
                  prefixIcon: Icon(Icons.admin_panel_settings_outlined),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'student',
                    child: Text('Học viên (Student)'),
                  ),
                  DropdownMenuItem(
                    value: 'teacher',
                    child: Text('Giảng viên (Teacher)'),
                  ),
                  DropdownMenuItem(
                    value: 'admin',
                    child: Text('Quản trị viên (Admin)'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedRole = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 32),

              // Nút Submit
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _submitForm,
                icon:
                    _isLoading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.save_outlined), // Icon Lưu
                label: Text(_isLoading ? 'Đang lưu...' : 'Lưu thay đổi'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
