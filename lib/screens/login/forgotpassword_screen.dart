import 'package:flutter/material.dart';
import 'package:mobile/screens/login/resetpassword_screen.dart';
import 'package:mobile/services/auth/auth_service.dart';
import 'package:mobile/widgets/login/forgotpasswordform.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  // hàm xử lý quên mật khẩu
  void _handleForgotPassWord() async {
    if (!(_formkey.currentState?.validate() ?? false)) {
      return;
    }
    final authService = context.read<AuthService>();
    bool success = await authService.forgotpassword(
      email: _emailController.text.trim(),
    );
    if (!mounted) return;
    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ResetpasswordScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          onPressed: () {
            context.go('/login');
          },
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: const Text(
          'Quên mật khẩu',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Form(
        key: _formkey,
        child: ForgotPassWordForm(
          emailController: _emailController,
          isLoading: authService.isLoading,
          onForgotPassWord: _handleForgotPassWord,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
