// lib/domain/repositories/student_vocabulary_lesson_repository.dart
import 'package:dio/dio.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/constants/api_config.dart';
import 'package:mobile/data/models/module_details_model.dart';

class StudentVocabularyLessonRepository {
  final ApiClient _apiClient;
  StudentVocabularyLessonRepository(this._apiClient);

  Future<ModuleDetailsModel> getModuleLessons(String moduleId) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConfig.studentModuleLessons(moduleId),
      );

      return ModuleDetailsModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi tải bài học');
    }
  }
}
