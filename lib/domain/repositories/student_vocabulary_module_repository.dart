// lib/domain/repositories/student_vocabulary_module_repository.dart
import 'package:dio/dio.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/constants/api_config.dart';
// Import model mới
import 'package:mobile/data/models/vocabulary_modules_model.dart';

class StudentVocabularyModuleRepository {
  final ApiClient _apiClient;
  StudentVocabularyModuleRepository(this._apiClient);

  // GET: Lấy danh sách Module (Chủ đề) của 1 Level
  Future<VocabularyModulesModel> getVocabularyModules(int levelId) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConfig.studentVocabularyModules(levelId), // Dùng config mới
      );
      return VocabularyModulesModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi tải chủ đề từ vựng');
    }
  }
}
