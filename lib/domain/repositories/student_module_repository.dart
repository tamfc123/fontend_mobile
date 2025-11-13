import 'package:dio/dio.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/constants/api_config.dart';
// ✅ 1. Import model MỚI (chứ không phải ClassModuleModel)
import 'package:mobile/data/models/module_model.dart';

class StudentModuleRepository {
  final ApiClient _apiClient;
  StudentModuleRepository(this._apiClient);

  // ✅ 2. Sửa kiểu trả về (return type)
  Future<List<ModuleModel>> getModulesByClass(int classId) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConfig.studentModules, // Route này đúng
        queryParameters: {'classId': classId.toString()}, // Param này đúng
      );
      print('Response data: ${response.data}');
      // ✅ 3. Dùng model MỚI để parse JSON
      return (response.data as List)
          .map((e) => ModuleModel.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Không thể tải danh sách chương học',
      );
    }
  }
}
