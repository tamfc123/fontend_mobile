import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/screens/auth/splash/splash_view_model.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SplashViewModel>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SplashViewModel>(
      builder: (context, viewModel, child) {
        // Khi khởi tạo hoàn tất, điều hướng đến route tiếp theo
        if (viewModel.isInitialized && viewModel.nextRoute != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              context.go(viewModel.nextRoute!);
            }
          });
        }

        return Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: AnimatedOpacity(
              opacity: viewModel.isVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeIn,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/Welcome.png',
                    width: 250,
                    height: 250,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 200,
                    child: LinearProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.blue.shade600),
                      backgroundColor: Colors.blue.shade100.withOpacity(0.5),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Đang tải dữ liệu...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
