import 'package:dio/dio.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/constants/api_config.dart';
// ✅ 1. Import model mới (hoặc tên file mới của bạn)
import 'package:mobile/data/models/module_model.dart';

// ✅ 2. Đổi tên class
class ModuleRepository {
  final ApiClient _apiClient;
  ModuleRepository(this._apiClient);

  // ✅ 3. Sửa hàm: Lấy module theo COURSE Id
  Future<List<ModuleModel>> getModulesByCourse(int courseId) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConfig.adminModules, // ⬅️ GỌI API ADMIN MỚI
        queryParameters: {'courseId': courseId.toString()}, // ⬅️ DÙNG courseId
      );
      return (response.data as List)
          .map((e) => ModuleModel.fromJson(e)) // ⬅️ DÙNG MODEL MỚI
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Không thể tải danh sách chương học',
      );
    }
  }

  // ✅ 4. Sửa hàm: Dùng ModuleCreateModel (an toàn hơn để tạo)
  // (Bạn nên tạo class ModuleCreateModel này trong file module_model.dart)
  Future<void> createModule(ModuleCreateModel module) async {
    try {
      await _apiClient.dio.post(
        ApiConfig.adminModules, // ⬅️ GỌI API ADMIN MỚI
        data: module.toJson(),
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Thêm chương học thất bại',
      );
    }
  }

  // ✅ 5. Sửa hàm: Dùng ModuleModel
  Future<void> updateModule(int id, ModuleModel module) async {
    try {
      await _apiClient.dio.put(
        ApiConfig.adminModuleById(id), // ⬅️ API ADMIN MỚI
        data: module.toJson(),
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Cập nhật chương học thất bại',
      );
    }
  }

  // ✅ 6. Sửa hàm: Gọi API Admin
  Future<void> deleteModule(int id) async {
    try {
      await _apiClient.dio.delete(
        ApiConfig.adminModuleById(id),
      ); // ⬅️ API ADMIN MỚI
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Xóa chương học thất bại');
    }
  }
}
