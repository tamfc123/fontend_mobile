import 'package:flutter/foundation.dart';
import 'package:mobile/services/auth/auth_service.dart';
import 'package:mobile/utils/toast_helper.dart';

class SplashViewModel extends ChangeNotifier {
  final AuthService _authService;

  SplashViewModel(this._authService);

  bool _isVisible = false;
  bool _isInitialized = false;
  String? _nextRoute;

  bool get isVisible => _isVisible;
  bool get isInitialized => _isInitialized;
  String? get nextRoute => _nextRoute;

  /// Khởi tạo ứng dụng: auto-login và xác định route tiếp theo
  Future<void> initialize() async {
    // Kích hoạt hiệu ứng fade-in sau 300ms
    await Future.delayed(const Duration(milliseconds: 300));
    _isVisible = true;
    notifyListeners();

    // Thực hiện auto-login
    try {
      await _authService.tryAutoLogin();
    } catch (_) {
      ToastHelper.showError('Lỗi đăng nhập tự động');
    }

    // Chờ 1.5s để splash hiển thị mượt hơn
    await Future.delayed(const Duration(milliseconds: 1500));

    // Xác định route tiếp theo dựa trên user role
    _determineNextRoute();
    _isInitialized = true;
    notifyListeners();
  }

  /// Xác định route tiếp theo dựa trên trạng thái user
  void _determineNextRoute() {
    final user = _authService.currentUser;

    if (user == null) {
      _nextRoute = kIsWeb ? '/login/web' : '/login';
      return;
    }

    final role = user.role.toLowerCase();
    switch (role) {
      case 'admin':
        _nextRoute = '/admin';
        if (kDebugMode) {
          print("Role: ${user.role}");
        }
        break;
      case 'teacher':
        _nextRoute = '/teacher';
        break;
      case 'student':
        _nextRoute = '/student';
        break;
      default:
        ToastHelper.showError('Vai trò không hợp lệ');
        _nextRoute = kIsWeb ? '/login/web' : '/login';
    }
  }
}
