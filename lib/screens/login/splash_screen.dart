import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/services/auth/auth_service.dart';
import 'package:mobile/utils/toast_helper.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isVisible = false;
  @override
  void initState() {
    super.initState();
    // 1. Kích hoạt hiệu ứng fade-in sau 1 khoảng trễ ngắn
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isVisible = true;
        });
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _initApp());
  }

  Future<void> _initApp() async {
    final auth = context.read<AuthService>();

    try {
      await auth.tryAutoLogin(); // chỉ gán user nếu token hợp lệ
    } catch (_) {
      ToastHelper.showError('Lỗi đăng nhập tự động');
    }

    if (!mounted) return;

    // (tuỳ chọn) cho splash hiển thị mượt hơn
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    final user = auth.currentUser;
    if (user == null) {
      context.go(kIsWeb ? '/login/web' : '/login');
      return;
    }

    final role = user.role.toLowerCase(); // phòng khi trả về 'Admin'/'ADMIN'
    switch (role) {
      case 'admin':
        context.go('/admin');
        print("Role: ${user.role}");
        break;
      case 'teacher':
        context.go('/teacher');
        break;
      case 'student':
        context.go('/student');
        break;
      default:
        ToastHelper.showError('Vai trò không hợp lệ');
        context.go(kIsWeb ? '/login/web' : '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. Đặt màu nền trắng (hoặc màu thương hiệu của bạn)
      backgroundColor: Colors.white,
      body: Center(
        // 2. Thêm hiệu ứng mờ dần
        child: AnimatedOpacity(
          opacity: _isVisible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 1200), // Tốc độ mờ
          curve: Curves.easeIn,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 3. Thay thế bằng Logo của bạn
              // 👇✅ ĐÃ THAY THẾ ICON BẰNG HÌNH ẢNH CỦA BẠN
              Image.asset(
                'assets/images/Welcome.png',
                width: 250, // Bạn có thể điều chỉnh kích thước
                height: 250,
                fit: BoxFit.contain,
              ),

              // 👆✅ KẾT THÚC SỬA
              const SizedBox(height: 24),

              // 4. (Tùy chọn) Vẫn giữ thanh tải
              SizedBox(
                width: 200, // Giới hạn chiều rộng
                child: LinearProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.blue.shade600),
                  backgroundColor: Colors.blue.shade100.withOpacity(0.5),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 16),

              // 5. (Tùy chọn) Thêm tên app hoặc tagline
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
  }
}
