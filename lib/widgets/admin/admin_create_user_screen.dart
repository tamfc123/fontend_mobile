import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/services/admin/user_service.dart';
import 'package:mobile/utils/toast_helper.dart';
import 'package:provider/provider.dart';

class AdminCreateUserScreen extends StatefulWidget {
  const AdminCreateUserScreen({super.key});

  @override
  State<AdminCreateUserScreen> createState() => _AdminCreateUserScreenState();
}

class _AdminCreateUserScreenState extends State<AdminCreateUserScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers cho các trường
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  // Biến cho các trường đặc biệt
  DateTime? _selectedBirthday;
  String _selectedRole = 'student'; // Mặc định là student
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
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

    // 3. Tạo Map data để gửi đi
    final userData = {
      'name': _nameController.text,
      'email': _emailController.text,
      'password': _passwordController.text,
      'phone': _phoneController.text,
      'role': _selectedRole,
      // Gửi ngày sinh theo chuẩn ISO (Backend C# sẽ hiểu)
      'birthday': _selectedBirthday!.toIso8601String(),
    };

    try {
      // 4. Gọi Service
      final success = await context.read<UserService>().createUser(userData);

      if (success && mounted) {
        // 5. Nếu thành công, quay lại màn hình trước
        // Navigator.pop(context, true) sẽ gửi tín hiệu "true"
        // về cho hàm _goToAddAccount
        Navigator.pop(context, true);
      }
    } catch (e) {
      // (Lỗi đã được xử lý và hiển thị toast trong service)
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
      appBar: AppBar(title: const Text('Tạo tài khoản mới'), centerTitle: true),
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

              // Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Không được để trống';
                  if (!value.contains('@')) return 'Email không hợp lệ';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Mật khẩu
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Mật khẩu',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator:
                    (value) =>
                        (value == null || value.length < 6)
                            ? 'Mật khẩu phải từ 6 ký tự'
                            : null,
              ),
              const SizedBox(height: 16),

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
                        : const Icon(Icons.add_circle_outline_rounded),
                label: Text(_isLoading ? 'Đang tạo...' : 'Tạo tài khoản'),
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
