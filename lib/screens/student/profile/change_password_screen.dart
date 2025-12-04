import 'package:flutter/material.dart';
import 'package:mobile/screens/student/profile/student_profile_view_model.dart';
import 'package:mobile/utils/toast_helper.dart';
import 'package:provider/provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  // Password strength indicator
  double _passwordStrength = 0.0;
  String _passwordStrengthText = '';
  Color _passwordStrengthColor = Colors.grey;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Calculate password strength
  void _checkPasswordStrength(String password) {
    if (password.isEmpty) {
      setState(() {
        _passwordStrength = 0.0;
        _passwordStrengthText = '';
        _passwordStrengthColor = Colors.grey;
      });
      return;
    }

    double strength = 0.0;

    // Length check
    if (password.length >= 8) strength += 0.25;
    if (password.length >= 12) strength += 0.25;

    // Contains lowercase
    if (password.contains(RegExp(r'[a-z]'))) strength += 0.15;

    // Contains uppercase
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.15;

    // Contains number
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.1;

    // Contains special character
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.1;

    setState(() {
      _passwordStrength = strength;

      if (strength < 0.3) {
        _passwordStrengthText = 'Yếu';
        _passwordStrengthColor = Colors.red;
      } else if (strength < 0.6) {
        _passwordStrengthText = 'Trung bình';
        _passwordStrengthColor = Colors.orange;
      } else if (strength < 0.8) {
        _passwordStrengthText = 'Tốt';
        _passwordStrengthColor = Colors.blue;
      } else {
        _passwordStrengthText = 'Mạnh';
        _passwordStrengthColor = Colors.green;
      }
    });
  }

  Future<void> _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) return;

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ToastHelper.showError("Mật khẩu xác nhận không khớp");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final profileService = context.read<StudentProfileViewModel>();

      await profileService.changePassword(
        currentPassword: _oldPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      if (profileService.error == null) {
        ToastHelper.showSuccess("Đổi mật khẩu thành công");
        Navigator.pop(context);
      } else {
        ToastHelper.showError("Lỗi: ${profileService.error}");
      }
    } catch (e) {
      ToastHelper.showError("Đổi mật khẩu thất bại: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      // Modern AppBar
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F2937),
        centerTitle: true,
        title: const Text(
          "Đổi mật khẩu",
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Header illustration
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_reset_rounded,
                      size: 64,
                      color: Colors.blue.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Cập nhật mật khẩu của bạn',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hãy chọn một mật khẩu mạnh để bảo vệ tài khoản',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Form card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Old password field
                    _buildPasswordField(
                      controller: _oldPasswordController,
                      label: "Mật khẩu cũ",
                      hint: "Nhập mật khẩu hiện tại",
                      icon: Icons.lock_outline_rounded,
                      obscureText: _obscureOldPassword,
                      onToggleVisibility: () {
                        setState(() {
                          _obscureOldPassword = !_obscureOldPassword;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Vui lòng nhập mật khẩu cũ";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // New password field
                    _buildPasswordField(
                      controller: _newPasswordController,
                      label: "Mật khẩu mới",
                      hint: "Tối thiểu 6 ký tự",
                      icon: Icons.lock_open_rounded,
                      obscureText: _obscureNewPassword,
                      onToggleVisibility: () {
                        setState(() {
                          _obscureNewPassword = !_obscureNewPassword;
                        });
                      },
                      onChanged: (value) => _checkPasswordStrength(value),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Vui lòng nhập mật khẩu mới";
                        }
                        if (value.length < 6) {
                          return "Mật khẩu phải có ít nhất 6 ký tự";
                        }
                        if (value == _oldPasswordController.text) {
                          return "Mật khẩu mới phải khác mật khẩu cũ";
                        }
                        return null;
                      },
                    ),

                    // Password strength indicator
                    if (_newPasswordController.text.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: _passwordStrength,
                                    backgroundColor: Colors.grey.shade200,
                                    color: _passwordStrengthColor,
                                    minHeight: 6,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _passwordStrengthText,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _passwordStrengthColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _buildPasswordTip(),
                        ],
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Confirm password field
                    _buildPasswordField(
                      controller: _confirmPasswordController,
                      label: "Xác nhận mật khẩu mới",
                      hint: "Nhập lại mật khẩu mới",
                      icon: Icons.check_circle_outline_rounded,
                      obscureText: _obscureConfirmPassword,
                      onToggleVisibility: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Vui lòng xác nhận mật khẩu mới";
                        }
                        if (value != _newPasswordController.text) {
                          return "Mật khẩu xác nhận không khớp";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 32),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleChangePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          disabledBackgroundColor: Colors.grey.shade300,
                        ),
                        child:
                            _isLoading
                                ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                                : const Text(
                                  "Xác nhận đổi mật khẩu",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Security tips card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade100, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.security_rounded,
                        color: Colors.blue.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Mẹo bảo mật',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildSecurityTip('Sử dụng ít nhất 8 ký tự'),
                  _buildSecurityTip('Kết hợp chữ hoa, chữ thường và số'),
                  _buildSecurityTip('Thêm ký tự đặc biệt (!@#\$%^&*)'),
                  _buildSecurityTip('Không sử dụng thông tin cá nhân'),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Password field builder
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          onChanged: onChanged,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: Icon(icon, color: Colors.blue.shade600, size: 22),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: Colors.grey.shade600,
                size: 22,
              ),
              onPressed: onToggleVisibility,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  // Password strength tip
  Widget _buildPasswordTip() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Mật khẩu mạnh nên có chữ hoa, chữ thường, số và ký tự đặc biệt',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }

  // Security tip item
  Widget _buildSecurityTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.blue.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }
}
