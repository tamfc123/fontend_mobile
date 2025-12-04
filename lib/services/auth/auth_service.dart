import 'package:flutter/material.dart';
import 'package:mobile/data/models/user_model.dart';
import 'package:mobile/domain/repositories/auth/auth_repository.dart';
import 'package:mobile/utils/toast_helper.dart';
import 'package:mobile/utils/token_helper.dart';

class AuthService extends ChangeNotifier {
  final AuthRepository _authRepository;
  AuthService(this._authRepository);

  UserModel? _currentUser;
  String? _authToken; // lưu trữ token làm trong tương lai

  UserModel? get currentUser => _currentUser;
  String? get authToken => _authToken;

  bool get isLoggedIn => _currentUser != null;

  Future<void> fetchCurrentUser() async {
    try {
      final user = await _authRepository.getProfile();
      _currentUser = user;
      notifyListeners(); // Báo UI cập nhật lại số dư
    } catch (e) {
      debugPrint('Lỗi cập nhật profile: $e');
      // Không clear token ở đây để tránh logout oan khi mạng lag
    }
  }

  //hàm đăng kí sinh viên
  Future<UserModel> registerStudent({
    required String name,
    required String email,
    required String password,
    required String phone,
    required DateTime birthday,
  }) async {
    try {
      final user = await _authRepository.registerStudent(
        name: name,
        email: email,
        password: password,
        phone: phone,
        birthday: birthday,
      );

      _currentUser = user;
      notifyListeners();
      return user;
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  //hàm đăng nhập
  Future<void> login({required String email, required String password}) async {
    try {
      final responseData = await _authRepository.login(email, password);
      if (responseData.containsKey('user') &&
          responseData['user'] is Map<String, dynamic>) {
        _currentUser = UserModel.fromJson(responseData['user']);
      }

      // Lưu trữ token xác thực (backend hiện tại không trả về, nên _authToken sẽ là null)
      if (responseData.containsKey('token') &&
          responseData['token'] is String) {
        _authToken = responseData['token'];
        await TokenHelper.saveToken(_authToken!);
      }

      if (_currentUser != null) {
        notifyListeners(); // Thông báo rằng đăng nhập thành công, UI sẽ được cập nhật
      } else {
        throw Exception(
          'Đăng nhập thành công nhưng không nhận được thông tin tài khoản.',
        );
      }
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  //hàm quên mật khẩu
  Future<String> forgotpassword({required String email}) async {
    try {
      final message = await _authRepository.forgotPassword(email: email);
      return message;
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<String> resetPassword({
    required String email,
    required String code,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (newPassword != confirmPassword) {
      throw Exception('Mật khẩu xác nhận không khớp.');
    }
    try {
      final message = await _authRepository.resetPassword(
        email: email,
        code: code,
        newPassword: newPassword,
      );
      return message;
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> tryAutoLogin() async {
    final token = await TokenHelper.getToken();

    if (token == null) return;

    try {
      final user = await _authRepository.getProfile();
      _currentUser = user;
      _authToken = token;
      notifyListeners();
      //print('AutoLogin token: $token');
    } catch (e) {
      await TokenHelper.clearToken();
      //print('AutoLogin failed: $e');
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    _authToken = null;
    notifyListeners();
    await TokenHelper.clearToken(); // Xóa token khỏi bộ nhớ
    ToastHelper.showSuccess('Đã đăng xuất!');
  }
}
