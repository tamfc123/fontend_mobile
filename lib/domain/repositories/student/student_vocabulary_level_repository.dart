import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/constants/api_config.dart';
import 'package:mobile/data/models/vocabulary_levels_model.dart';

class StudentVocabularyLevelRepository {
  final ApiClient _apiClient;
  StudentVocabularyLevelRepository(this._apiClient);

  Future<VocabularyLevelsModel> getVocabularyLevels() async {
    try {
      final response = await _apiClient.dio.get(
        ApiConfig.studentVocabularyLevels,
      );
      debugPrint('Response Data: ${response.data}'); // In dữ liệu nhận được
      return VocabularyLevelsModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi tải cấp độ từ vựng');
    }
  }
}
