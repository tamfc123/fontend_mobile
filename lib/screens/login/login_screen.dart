import 'package:flutter/material.dart';
import 'package:mobile/services/auth/auth_service.dart';
import 'package:mobile/utils/toast_helper.dart';
import 'package:mobile/widgets/login/loginform.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  //function handlelogin
  void _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final authService = context.read<AuthService>();
    bool success = await authService.login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      final userRole = authService.currentUser?.role.toLowerCase();

      if (userRole == 'student') {
        // Chỉ học viên mới được vào app mobile
        context.go('/student');
      } else if (userRole == 'teacher' || userRole == 'admin') {
        // Thông báo cho giảng viên và admin
        ToastHelper.showError(
          'Tài khoản này chỉ sử dụng trên website. Vui lòng đăng nhập trên trình duyệt.',
        );
      } else {
        // Vai trò không xác định
        ToastHelper.showError(
          'Vai trò không hợp lệ. Vui lòng liên hệ quản trị viên.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authSerice = context.watch<AuthService>();
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              //image welcome
              Image.asset(
                'assets/images/Welcome.png',
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
              ),
              const Text(
                'Đăng nhập',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),
              //form login
              Form(
                key: _formKey,
                child: LoginForm(
                  emailController: _emailController,
                  passwordController: _passwordController,
                  isLoading: authSerice.isLoading,
                  onLoginPressed: _handleLogin,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
