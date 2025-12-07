import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/constants/api_config.dart';
import 'package:mobile/data/models/user_model.dart';

class AdminUserRepository {
  final ApiClient _apiClient;

  AdminUserRepository(this._apiClient);

  // Lấy tất cả user (không phân trang)
  Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await _apiClient.dio.get(ApiConfig.users);
      return (response.data as List).map((e) => UserModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Không thể tải danh sách người dùng',
      );
    }
  }

  // Lấy user (có phân trang và filter)
  Future<Map<String, dynamic>> getUserPaged({
    required int page,
    required int pageSize,
    String? search,
    String? role,
    bool? isActive,
    String? sort,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'pageSize': pageSize.toString(),
        if (search != null && search.isNotEmpty) 'search': search,
        if (role != null && role.isNotEmpty) 'role': role,
        if (isActive != null) 'isActive': isActive.toString(),
        if (sort != null) 'sort': sort,
      };

      final response = await _apiClient.dio.get(
        ApiConfig.users,
        queryParameters: queryParams,
      );

      final data = response.data;
      return {
        "data":
            (data["data"] as List).map((e) => UserModel.fromJson(e)).toList(),
        "totalItems": data["totalItems"],
        "page": data["page"],
        "totalPages": data["totalPages"],
      };
    } on DioException catch (e) {
      debugPrint(e.response?.data['message']);
      throw Exception(
        e.response?.data['message'] ?? 'Không thể tải danh sách người dùng',
      );
    }
  }

  Future<bool> toggleUserStatus(String id) async {
    try {
      final response = await _apiClient.dio.put(ApiConfig.userToggleStatus(id));

      if (response.statusCode == 200) {
        return true;
      }

      throw Exception(response.data?['message'] ?? 'Máy chủ từ chối yêu cầu');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Lỗi khi thay đổi trạng thái',
      );
    }
  }

  // Thêm user mới (dành cho Admin)
  Future<UserModel> createUser(Map<String, dynamic> userData) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConfig.adminCreateUser,
        data: userData,
      );
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi khi tạo người dùng');
    }
  }

  Future<UserModel> updateUser(String id, Map<String, dynamic> userData) async {
    try {
      final response = await _apiClient.dio.put(
        ApiConfig.userById(id),
        data: userData,
      );

      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Lỗi khi cập nhật người dùng',
      );
    }
  }
}
