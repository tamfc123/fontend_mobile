import 'package:flutter/material.dart';
import 'package:mobile/screens/auth/login/login_view_model.dart';
import 'package:mobile/screens/auth/login/widgets/loginform.dart';
import 'package:mobile/services/auth/auth_service.dart';
import 'package:mobile/utils/toast_helper.dart';
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

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(context.read<AuthService>()),
      child: Consumer<LoginViewModel>(
        builder: (context, viewModel, child) {
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
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    //form login
                    Form(
                      key: _formKey,
                      child: LoginForm(
                        emailController: _emailController,
                        passwordController: _passwordController,
                        isLoading: viewModel.isLoading,
                        onLoginPressed: () async {
                          if (!(_formKey.currentState?.validate() ?? false)) {
                            return;
                          }

                          final success = await viewModel.login(
                            _emailController.text.trim(),
                            _passwordController.text.trim(),
                          );

                          if (!mounted) return;

                          if (success) {
                            final authService = context.read<AuthService>();
                            final userRole =
                                authService.currentUser?.role.toLowerCase();

                            if (userRole == 'student') {
                              context.go('/student');
                            } else if (userRole == 'teacher' ||
                                userRole == 'admin') {
                              ToastHelper.showError(
                                'Tài khoản này chỉ sử dụng trên website. Vui lòng đăng nhập trên trình duyệt.',
                              );
                            } else {
                              ToastHelper.showError(
                                'Vai trò không hợp lệ. Vui lòng liên hệ quản trị viên.',
                              );
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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
