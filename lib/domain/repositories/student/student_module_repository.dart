import 'package:dio/dio.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/constants/api_config.dart';
import 'package:mobile/data/models/module_model.dart';

class StudentModuleRepository {
  final ApiClient _apiClient;
  StudentModuleRepository(this._apiClient);

  Future<List<ModuleModel>> getModulesByClass(String classId) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConfig.studentModules,
        queryParameters: {'classId': classId.toString()},
      );

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
