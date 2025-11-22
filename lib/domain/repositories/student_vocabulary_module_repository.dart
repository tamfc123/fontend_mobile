import 'package:dio/dio.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/constants/api_config.dart';
import 'package:mobile/data/models/vocabulary_modules_model.dart';

class StudentVocabularyModuleRepository {
  final ApiClient _apiClient;
  StudentVocabularyModuleRepository(this._apiClient);

  Future<VocabularyModulesModel> getVocabularyModules(String levelId) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConfig.studentVocabularyModules(levelId),
      );
      return VocabularyModulesModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi tải chủ đề từ vựng');
    }
  }
}
