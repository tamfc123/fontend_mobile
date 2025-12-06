import 'package:flutter/material.dart';
import 'package:mobile/screens/auth/loginweb/web_login_view_model.dart';
import 'package:mobile/services/auth/auth_service.dart';
import 'package:mobile/utils/toast_helper.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class WebLoginScreen extends StatefulWidget {
  const WebLoginScreen({super.key});

  @override
  State<WebLoginScreen> createState() => _WebLoginScreenState();
}

class _WebLoginScreenState extends State<WebLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() => setState(() {}));
    _passwordFocusNode.addListener(() => setState(() {}));
  }

  // Responsive helpers
  bool _isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  double _getContainerPadding(BuildContext context) {
    return _isMobile(context) ? 20 : 32;
  }

  double _getMaxWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return width * 0.9; // Mobile: 90% width
    return 420; // Desktop: fixed 420px
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = _isMobile(context);

    return ChangeNotifierProvider(
      create: (_) => WebLoginViewModel(context.read<AuthService>()),
      child: Consumer<WebLoginViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: Colors.blueGrey[50],
            body: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 0,
                  vertical: isMobile ? 24 : 0,
                ),
                child: Container(
                  constraints: BoxConstraints(maxWidth: _getMaxWidth(context)),
                  padding: EdgeInsets.all(_getContainerPadding(context)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: isMobile ? 12 : 20,
                        offset: Offset(0, isMobile ? 4 : 8),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo hoặc icon admin
                        CircleAvatar(
                          radius: isMobile ? 32 : 36,
                          backgroundColor: Colors.blue.shade100,
                          child: Icon(
                            Icons.admin_panel_settings,
                            size: isMobile ? 36 : 40,
                            color: Colors.blue,
                          ),
                        ),
                        SizedBox(height: isMobile ? 12 : 16),

                        Text(
                          "Hệ thống Quản trị",
                          style: TextStyle(
                            fontSize: isMobile ? 20 : 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Đăng nhập để tiếp tục",
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 15,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: isMobile ? 20 : 28),

                        // Email input
                        TextFormField(
                          controller: _emailController,
                          focusNode: _emailFocusNode,
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color:
                                  _emailFocusNode.hasFocus
                                      ? Colors.blue
                                      : Colors.grey,
                            ),
                            labelText: "Email",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.blue),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: isMobile ? 14 : 16,
                              horizontal: 12,
                            ),
                          ),
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? "Vui lòng nhập email"
                                      : null,
                        ),
                        SizedBox(height: isMobile ? 12 : 16),

                        // Password input
                        TextFormField(
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color:
                                  _passwordFocusNode.hasFocus
                                      ? Colors.blue
                                      : Colors.grey,
                            ),
                            labelText: "Mật khẩu",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: isMobile ? 14 : 16,
                              horizontal: 12,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.blue),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? "Vui lòng nhập mật khẩu"
                                      : null,
                        ),

                        SizedBox(height: isMobile ? 20 : 24),

                        // Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                viewModel.isLoading
                                    ? null
                                    : () async {
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

                                        if (userRole == 'admin' ||
                                            userRole == 'staff') {
                                          context.go('/admin');
                                        } else if (userRole == 'teacher') {
                                          context.go('/teacher');
                                        } else {
                                          ToastHelper.showError(
                                            'Tài khoản này không được phép đăng nhập website.',
                                          );
                                        }
                                      }
                                    },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                vertical: isMobile ? 14 : 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: Colors.blue,
                            ),
                            child:
                                viewModel.isLoading
                                    ? SizedBox(
                                      width: isMobile ? 20 : 22,
                                      height: isMobile ? 20 : 22,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                    : Text(
                                      "Đăng nhập",
                                      style: TextStyle(
                                        fontSize: isMobile ? 15 : 16,
                                        color: Colors.white,
                                      ),
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
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
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
