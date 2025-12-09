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

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation1;
  late Animation<Offset> _slideAnimation2;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Fade animation cho logo
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    // Slide animations với stagger effect
    _slideAnimation1 = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.25, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation2 = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 0.75, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(context.read<AuthService>()),
      child: Consumer<LoginViewModel>(
        builder: (context, viewModel, child) {
          return Stack(
            children: [
              Scaffold(
                backgroundColor: Colors.white,
                body: SingleChildScrollView(
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 50),

                        // Animated logo with fade
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Image.asset(
                            'assets/images/Welcome.png',
                            width: double.infinity,
                            height: 300,
                            fit: BoxFit.cover,
                          ),
                        ),

                        // Animated title
                        SlideTransition(
                          position: _slideAnimation1,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: const Text(
                              'Đăng nhập',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                          ),
                        ),

                        // Animated form
                        SlideTransition(
                          position: _slideAnimation2,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Form(
                              key: _formKey,
                              child: LoginForm(
                                emailController: _emailController,
                                passwordController: _passwordController,
                                isLoading: viewModel.isLoading,
                                onLoginPressed: () async {
                                  if (!(_formKey.currentState?.validate() ??
                                      false)) {
                                    return;
                                  }

                                  final success = await viewModel.login(
                                    _emailController.text.trim(),
                                    _passwordController.text.trim(),
                                  );

                                  if (!mounted) return;

                                  if (success) {
                                    final authService =
                                        context.read<AuthService>();
                                    final userRole =
                                        authService.currentUser?.role
                                            .toLowerCase();

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
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Full-screen loading overlay
              if (viewModel.isLoading)
                Positioned.fill(
                  child: Material(
                    color: Colors.black.withValues(alpha: 0.7),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 70,
                            height: 70,
                            child: CircularProgressIndicator(
                              strokeWidth: 4,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Đang đăng nhập...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
