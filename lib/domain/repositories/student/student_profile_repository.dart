import 'dart:io';
import 'package:dio/dio.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/constants/api_config.dart';
import 'package:mobile/data/models/user_model.dart';

class StudentProfileRepository {
  final ApiClient _apiClient;
  StudentProfileRepository(this._apiClient);

  Future<UserModel> getProfile() async {
    try {
      final response = await _apiClient.dio.get(ApiConfig.profileMe);
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lấy profile thất bại');
    }
  }

  Future<UserModel> updateProfile({
    String? name,
    String? phone,
    DateTime? birthday,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body["name"] = name;
      if (phone != null) body["phone"] = phone;
      if (birthday != null) body["birthday"] = birthday.toIso8601String();

      final response = await _apiClient.dio.put(ApiConfig.profile, data: body);

      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Cập nhật profile thất bại',
      );
    }
  }

  Future<String?> updateAvatar(File file) async {
    try {
      String fileName = file.path.split('/').last;
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(file.path, filename: fileName),
      });

      final response = await _apiClient.dio.post(
        ApiConfig.profileAvatar,
        data: formData,
      );

      return response.data["avatarUrl"];
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Cập nhật avatar thất bại',
      );
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final body = {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      };
      await _apiClient.dio.post(ApiConfig.profileChangePassword, data: body);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Đổi mật khẩu thất bại');
    }
  }
}
