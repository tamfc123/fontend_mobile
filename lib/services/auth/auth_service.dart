import 'package:flutter/material.dart';
import 'package:mobile/data/models/user_model.dart';
import 'package:mobile/domain/repositories/auth_repository.dart';
import 'package:mobile/utils/toast_helper.dart';
import 'package:mobile/utils/token_helper.dart';

class AuthService extends ChangeNotifier {
  final AuthRepository _authRepository;
  AuthService(this._authRepository);

  bool _isloading = false;
  String? _errorMessage;
  UserModel? _currentUser;
  String? _authToken; // lưu trữ token làm trong tương lai

  bool get isLoading => _isloading;
  String? get errorMessage => _errorMessage;
  UserModel? get currentUser => _currentUser;
  String? get authToken => _authToken;
  // kiểm tra trạng thái login
  bool get isLoggedIn => _currentUser != null;

  //hàm đăng kí sinh viên
  Future<bool> registerStudent({
    required String name,
    required String email,
    required String password,
    required String phone,
    required DateTime birthday,
  }) async {
    _isloading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authRepository.registerStudent(
        name: name,
        email: email,
        password: password,
        phone: phone,
        birthday: birthday,
      );

      _currentUser = user;
      _isloading = false;
      notifyListeners();
      ToastHelper.showSuccess('Đăng kí thành công');
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isloading = false;
      notifyListeners();
      ToastHelper.showError(_errorMessage!);
      return false;
    }
  }

  //hàm đăng nhập
  Future<bool> login({required String email, required String password}) async {
    _isloading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final responseData = await _authRepository.login(email, password);
      if (responseData.containsKey('user') &&
          responseData['user'] is Map<String, dynamic>) {
        _currentUser = UserModel.fromJson(responseData['user']);
      }
      // print('RESPONSE DATA: $responseData');
      // print('Current User: $_currentUser');
      // print('Token: $_authToken');

      // Lưu trữ token xác thực (backend hiện tại không trả về, nên _authToken sẽ là null)
      if (responseData.containsKey('token') &&
          responseData['token'] is String) {
        _authToken = responseData['token'];
        await TokenHelper.saveToken(_authToken!);
      }

      if (_currentUser != null) {
        _isloading = false;
        notifyListeners(); // Thông báo rằng đăng nhập thành công, UI sẽ được cập nhật
        ToastHelper.showSuccess('Đăng nhập thành công!');
        return true;
      } else {
        _errorMessage =
            'Đăng nhập thành công nhưng không nhận được thông tin tài khoản.';
        _isloading = false;
        notifyListeners();
        ToastHelper.showError(_errorMessage!);
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isloading = false;
      notifyListeners();
      ToastHelper.showError(_errorMessage!);
      return false;
    }
  }

  //hàm quên mật khẩu
  Future<bool> forgotpassword({required String email}) async {
    _isloading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final message = await _authRepository.forgotPassword(email: email);
      _isloading = false;
      ToastHelper.showSuccess(message);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isloading = false;
      notifyListeners();
      ToastHelper.showError(errorMessage!);
      return false;
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String code,
    required String newPassword,
    required String confirmPassword,
  }) async {
    _isloading = true;
    _errorMessage = null;
    notifyListeners();
    if (newPassword != confirmPassword) {
      _errorMessage = 'Mật khẩu xác nhận không khớp.';
      _isloading = false;
      notifyListeners();
      ToastHelper.showError(_errorMessage!);
      return false;
    }
    try {
      final message = await _authRepository.resetPassword(
        email: email,
        code: code,
        newPassword: newPassword,
      );

      _isloading = false;
      notifyListeners();
      ToastHelper.showSuccess(message);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isloading = false;
      notifyListeners();
      ToastHelper.showError(_errorMessage!);
      return false;
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
    _errorMessage = null;
    notifyListeners();
    await TokenHelper.clearToken(); // Xóa token khỏi bộ nhớ
    ToastHelper.showSuccess('Đã đăng xuất!');
  }
}
