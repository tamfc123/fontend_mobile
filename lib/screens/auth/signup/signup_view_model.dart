import 'package:flutter/material.dart';
import 'package:mobile/services/auth/auth_service.dart';
import 'package:mobile/utils/toast_helper.dart';

class SignupViewModel extends ChangeNotifier {
  final AuthService _authService;

  SignupViewModel(this._authService);

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required DateTime birthday,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.registerStudent(
        name: name,
        email: email,
        password: password,
        phone: phone,
        birthday: birthday,
      );
      _isLoading = false;
      notifyListeners();
      ToastHelper.showSuccess('Đăng kí thành công');
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      ToastHelper.showError(_errorMessage!);
      return false;
    }
  }
}
