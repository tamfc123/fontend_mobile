import 'package:dio/dio.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/constants/api_config.dart';
import 'package:mobile/data/models/module_model.dart';
import 'package:mobile/data/models/paged_result_model.dart';

class AdminModuleRepository {
  final ApiClient _apiClient;
  AdminModuleRepository(this._apiClient);

  Future<PagedResultModel<ModuleModel>> getPaginatedModules({
    required String courseId,
    int pageNumber = 1,
    int pageSize = 5,
    String? searchQuery,
  }) async {
    try {
      final queryParameters = {
        'courseId': courseId.toString(),
        'pageNumber': pageNumber.toString(),
        'pageSize': pageSize.toString(),
      };

      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParameters['searchQuery'] = searchQuery;
      }

      final response = await _apiClient.dio.get(
        ApiConfig.adminModules,
        queryParameters: queryParameters,
      );

      return PagedResultModel.fromJson(
        response.data,
        (json) => ModuleModel.fromJson(json),
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Không thể tải danh sách chương học',
      );
    }
  }

  Future<void> createModule(ModuleCreateModel module) async {
    try {
      await _apiClient.dio.post(ApiConfig.adminModules, data: module.toJson());
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Thêm chương học thất bại',
      );
    }
  }

  Future<void> updateModule(String id, ModuleModel module) async {
    try {
      await _apiClient.dio.put(
        ApiConfig.adminModuleById(id),
        data: module.toJson(),
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Cập nhật chương học thất bại',
      );
    }
  }

  Future<void> deleteModule(String id) async {
    try {
      await _apiClient.dio.delete(ApiConfig.adminModuleById(id));
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Xóa chương học thất bại');
    }
  }
}
