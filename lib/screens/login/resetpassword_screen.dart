import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/services/auth/auth_service.dart';
import 'package:mobile/widgets/login/resetpasswordform.dart';
import 'package:provider/provider.dart';

class ResetpasswordScreen extends StatefulWidget {
  const ResetpasswordScreen({super.key});

  @override
  State<ResetpasswordScreen> createState() => _ResetpasswordScreenState();
}

class _ResetpasswordScreenState extends State<ResetpasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  void _handleResetPassword() async {
    if (!(_formkey.currentState?.validate() ?? false)) return;

    final authService = context.read<AuthService>();
    bool success = await authService.resetPassword(
      email: _emailController.text.trim(),
      code: _codeController.text.trim(),
      newPassword: _newPassController.text.trim(),
      confirmPassword: _confirmPassController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      // Toast đã được hiển thị trong AuthService, không cần hiển thị lại
      // Chỉ cần điều hướng về login
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Đặt lại mật khẩu',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      backgroundColor: Colors.white,
      body: Form(
        key: _formkey,
        child: SingleChildScrollView(
          child: ResetPasswWordForm(
            emailController: _emailController,
            codeController: _codeController,
            newPassController: _newPassController,
            confirmPassController: _confirmPassController,
            onResetPassword: _handleResetPassword,
            isLoading: authService.isLoading,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }
}
