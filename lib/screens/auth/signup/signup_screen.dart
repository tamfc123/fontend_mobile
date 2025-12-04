import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/services/auth/auth_service.dart';
import 'package:mobile/screens/auth/signup/widgets/signupform.dart';
import 'package:mobile/screens/auth/signup/signup_view_model.dart';
import 'package:provider/provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  DateTime? _selectedDate;
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SignupViewModel(context.read<AuthService>()),
      child: Consumer<SignupViewModel>(
        builder: (context, viewModel, child) {
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
                'Đăng ký',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
            ),
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    //Form sign up
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: SignupForm(
                          nameController: _nameController,
                          dateController: _dateController,
                          emailController: _emailController,
                          phoneController: _phoneController,
                          passwordController: _passwordController,
                          confirmPasswordController: _confirmPasswordController,
                          onDatePicked: (pickedDate) {
                            final utcDate = DateTime.utc(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                            );

                            setState(() {
                              _selectedDate = utcDate;
                              _dateController.text =
                                  "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";
                            });
                          },
                          isLoading: viewModel.isLoading,
                          onSignupPressed: () async {
                            if (!(_formKey.currentState?.validate() ?? false)) {
                              return;
                            }

                            final success = await viewModel.register(
                              name: _nameController.text.trim(),
                              email: _emailController.text.trim(),
                              password: _passwordController.text.trim(),
                              phone: _phoneController.text.trim(),
                              birthday: _selectedDate!,
                            );

                            if (!mounted) return;

                            if (success) {
                              await Future.delayed(const Duration(seconds: 2));
                              if (!mounted) return;
                              context.go('/login');
                            }
                          },
                        ),
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
}
