import 'package:dio/dio.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/constants/api_config.dart';
import 'package:mobile/data/models/user_model.dart';

class UserRepository {
  final ApiClient _apiClient;

  UserRepository(this._apiClient);

  // Lấy tất cả user (không phân trang)
  Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await _apiClient.dio.get(ApiConfig.users);
      // Dio tự động decode, response.data là một List
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
        queryParameters: queryParams, // Dio xử lý query params rất tốt
      );

      final data = response.data;
      // Trả về cấu trúc Map y hệt code cũ của bạn
      return {
        "data":
            (data["data"] as List).map((e) => UserModel.fromJson(e)).toList(),
        "totalItems": data["totalItems"],
        "page": data["page"],
        "totalPages": data["totalPages"],
      };
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Không thể tải danh sách người dùng',
      );
    }
  }

  // Xóa user
  Future<bool> deleteUser(String id) async {
    try {
      await _apiClient.dio.delete(ApiConfig.userById(id));
      // Dio ném lỗi nếu status != 2xx, nên nếu đến đây là thành công
      return true;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi khi xóa người dùng');
    }
  }

  // Thay đổi trạng thái (active/inactive)
  Future<bool> toggleUserStatus(String id) async {
    try {
      await _apiClient.dio.put(ApiConfig.userToggleStatus(id));
      return true;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Lỗi khi thay đổi trạng thái',
      );
    }
  }

  // Lấy user theo vai trò
  Future<List<UserModel>> getUsersByRole(String role) async {
    try {
      final response = await _apiClient.dio.get(ApiConfig.usersByRole(role));
      return (response.data as List).map((e) => UserModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Lỗi khi tải người dùng theo vai trò',
      );
    }
  }

  // Thêm user mới (dành cho Admin)
  Future<UserModel> createUser(Map<String, dynamic> userData) async {
    try {
      // API mới là /users/create-user
      final response = await _apiClient.dio.post(
        ApiConfig.adminCreateUser,
        data: userData, // Gửi Map dữ liệu (từ Form của Admin)
      );
      // API trả về 201 Created với user vừa tạo
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi khi tạo người dùng');
    }
  }

  Future<UserModel> updateUser(String id, Map<String, dynamic> userData) async {
    try {
      // Gọi PUT /api/users/{id}
      final response = await _apiClient.dio.put(
        ApiConfig.userById(id), // Dùng lại endpoint "userById"
        data: userData,
      );

      // API trả về object user đã cập nhật
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Lỗi khi cập nhật người dùng',
      );
    }
  }
}
