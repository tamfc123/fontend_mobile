import 'package:flutter/material.dart';

class ForgotPassWordForm extends StatefulWidget {
  final VoidCallback onForgotPassWord;
  final TextEditingController emailController;
  final bool isLoading;
  const ForgotPassWordForm({
    super.key,
    required this.emailController,
    required this.onForgotPassWord,
    this.isLoading = false,
  });

  @override
  State<ForgotPassWordForm> createState() => _ForgotPassWordFormState();
}

class _ForgotPassWordFormState extends State<ForgotPassWordForm> {
  final FocusNode _emailFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //Form sign up
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'Nhập địa chỉ email của bạn để nhận liên kết đặt lại mật khẩu.',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                  TextFormField(
                    controller: widget.emailController,
                    focusNode: _emailFocusNode,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      floatingLabelStyle: const TextStyle(color: Colors.blue),
                      prefixIcon: Icon(
                        Icons.email,
                        color:
                            _emailFocusNode.hasFocus
                                ? Colors.blue
                                : Colors.grey,
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
                        return 'Vui lòng nhập địa chỉ Email';
                      }
                      if (!RegExp(
                        r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$",
                      ).hasMatch(value)) {
                        return 'Email không hợp lệ';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
            //Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.isLoading ? null : widget.onForgotPassWord,
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
                            'Gửi mã',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
