import 'package:flutter/material.dart';

class ResetPasswWordForm extends StatefulWidget {
  final VoidCallback onResetPassword;
  final bool isLoading;
  final TextEditingController emailController;
  final TextEditingController codeController;
  final TextEditingController newPassController;
  final TextEditingController confirmPassController;
  const ResetPasswWordForm({
    super.key,
    required this.emailController,
    required this.codeController,
    required this.newPassController,
    required this.confirmPassController,
    required this.onResetPassword,
    this.isLoading = false,
  });
  @override
  State<ResetPasswWordForm> createState() => _ResetPasswWordFormState();
}

class _ResetPasswWordFormState extends State<ResetPasswWordForm> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();
  final FocusNode _codeFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() => setState(() {}));
    _passwordFocusNode.addListener(() => setState(() {}));
    _confirmPasswordFocusNode.addListener(() => setState(() {}));
    _codeFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _codeFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          TextFormField(
            controller: widget.emailController,
            focusNode: _emailFocusNode,
            decoration: InputDecoration(
              labelText: 'Email',
              floatingLabelStyle: const TextStyle(color: Colors.blue),
              prefixIcon: Icon(
                Icons.email,
                color: _emailFocusNode.hasFocus ? Colors.blue : Colors.grey,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.blue),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập Email';
              }
              if (!RegExp(
                r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$",
              ).hasMatch(value)) {
                return 'Email không hợp lệ';
              }
              return null;
            },
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: widget.codeController,
            focusNode: _codeFocusNode,
            decoration: InputDecoration(
              labelText: 'Mã xác thực',
              floatingLabelStyle: const TextStyle(color: Colors.blue),
              prefixIcon: Icon(
                Icons.vpn_key,
                color: _codeFocusNode.hasFocus ? Colors.blue : Colors.grey,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.blue),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập mã xác thực';
              }
              if (value.length != 6 || !RegExp(r'^[0-9]+$').hasMatch(value)) {
                return 'Mã xác thực phải là 6 chữ số';
              }
              return null;
            },
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: widget.newPassController,
            focusNode: _passwordFocusNode,
            decoration: InputDecoration(
              labelText: 'Mật khẩu mới',
              floatingLabelStyle: const TextStyle(color: Colors.blue),
              prefixIcon: Icon(
                Icons.lock,
                color: _passwordFocusNode.hasFocus ? Colors.blue : Colors.grey,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.blue),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập mật khẩu';
              }
              if (value.length < 6) {
                // Ví dụ: mật khẩu tối thiểu 6 ký tự
                return 'Mật khẩu phải có ít nhất 6 ký tự';
              }
              return null;
            },
            obscureText: _obscurePassword,
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: widget.confirmPassController,
            focusNode: _confirmPasswordFocusNode,
            decoration: InputDecoration(
              labelText: 'Nhập lại mật khẩu mới',
              floatingLabelStyle: const TextStyle(color: Colors.blue),
              prefixIcon: Icon(
                Icons.lock,
                color:
                    _confirmPasswordFocusNode.hasFocus
                        ? Colors.blue
                        : Colors.grey,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.blue),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng xác nhận mật khẩu';
              }
              // Quan trọng: So sánh với passwordController.text
              if (value != widget.newPassController.text) {
                return 'Mật khẩu không khớp';
              }
              return null;
            },
            obscureText: _obscureConfirmPassword,
          ),
          const SizedBox(height: 60),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.isLoading ? null : widget.onResetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 24,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
              ),
              child:
                  widget.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                        'Đặt lại mật khẩu',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }
}
