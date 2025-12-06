import 'package:flutter/material.dart';

class SignupForm extends StatefulWidget {
  final VoidCallback onSignupPressed;
  final TextEditingController nameController;
  final TextEditingController dateController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final Function(DateTime) onDatePicked;
  final bool isLoading;
  const SignupForm({
    super.key,
    required this.nameController,
    required this.dateController,
    required this.emailController,
    required this.phoneController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.onDatePicked,
    required this.onSignupPressed,
    this.isLoading = false,
  });

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _dateFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _nameFocusNode.addListener(() => setState(() {}));
    _dateFocusNode.addListener(() => setState(() {}));
    _emailFocusNode.addListener(() => setState(() {}));
    _phoneFocusNode.addListener(() => setState(() {}));
    _passwordFocusNode.addListener(() => setState(() {}));
    _confirmPasswordFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _dateFocusNode.dispose();
    _emailFocusNode.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        TextFormField(
          controller: widget.nameController,
          focusNode: _nameFocusNode,
          decoration: InputDecoration(
            labelText: 'Họ và tên',
            floatingLabelStyle: const TextStyle(color: Colors.blue),
            prefixIcon: Icon(
              Icons.person,
              color: _nameFocusNode.hasFocus ? Colors.blue : Colors.grey,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.blue),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập họ tên';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: widget.dateController,
          focusNode: _dateFocusNode,
          readOnly: true,
          onTap: () async {
            FocusScope.of(context).requestFocus(FocusNode());
            final DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime(2000),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              locale: const Locale('vi', 'VN'),
            );
            if (pickedDate != null) {
              widget.onDatePicked(pickedDate);
            }
          },
          decoration: InputDecoration(
            labelText: 'Ngày sinh',
            floatingLabelStyle: const TextStyle(color: Colors.blue),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.blue),
            ),
            prefixIcon: Icon(
              Icons.calendar_today,
              color: _dateFocusNode.hasFocus ? Colors.blue : Colors.grey,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng chọn ngày sinh';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
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
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.blue),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập Email';
            }
            if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(value)) {
              return 'Email không hợp lệ';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: widget.phoneController,
          focusNode: _phoneFocusNode,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'Số điện thoại',
            floatingLabelStyle: const TextStyle(color: Colors.blue),
            prefixIcon: Icon(
              Icons.phone,
              color: _phoneFocusNode.hasFocus ? Colors.blue : Colors.grey,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.blue),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập số điện thoại';
            }
            if (!RegExp(r'^\d{10,11}$').hasMatch(value)) {
              // Giả sử SĐT 10 hoặc 11 chữ số
              return 'Số điện thoại không hợp lệ';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: widget.passwordController,
          focusNode: _passwordFocusNode,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: 'Mật khẩu',
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
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: widget.confirmPasswordController,
          focusNode: _confirmPasswordFocusNode,
          obscureText: _obscureConfirmPassword,
          decoration: InputDecoration(
            labelText: 'Xác nhận Mật khẩu',
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
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
            if (value != widget.passwordController.text) {
              return 'Mật khẩu không khớp';
            }
            return null;
          },
        ),
        const SizedBox(height: 60),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: widget.onSignupPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 5,
            ),
            child:
                widget.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                      'Đăng ký',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
          ),
        ),
      ],
    );
  }
}
