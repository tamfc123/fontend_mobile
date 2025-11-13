import 'package:dio/dio.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/constants/api_config.dart';
import 'package:mobile/data/models/user_model.dart';

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConfig.authLogin,
        data: {'email': email, 'password': password},
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi không xác định');
    }
  }

  Future<UserModel> registerStudent({
    required String name,
    required String email,
    required String password,
    required String phone,
    required DateTime birthday,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConfig.authRegister,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
          'birthday': birthday.toIso8601String(),
        },
      );
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Đăng ký thất bại');
    }
  }

  Future<String> forgotPassword({required String email}) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConfig.authForgotPassword,
        data: {'email': email},
      );
      return response.data['message'];
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi gửi mã');
    }
  }

  Future<String> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConfig.authResetPassword,
        data: {'email': email, 'code': code, 'newPassword': newPassword},
      );
      return response.data['message'] as String;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi đặt lại mật khẩu');
    }
  }

  Future<UserModel> getProfile() async {
    try {
      final response = await _apiClient.dio.get(ApiConfig.profileMe);
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Token không hợp lệ');
    }
  }
}
