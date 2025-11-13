// file: domain/repositories/admin_vocabulary_repository.dart
import 'package:dio/dio.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/constants/api_config.dart';
// 1. Import model (đã tạo)
import 'package:mobile/data/models/vocabulary_model.dart';

class AdminVocabularyRepository {
  final ApiClient _apiClient;
  AdminVocabularyRepository(this._apiClient);

  // GET: Lấy tất cả Từ vựng của 1 Lesson
  Future<List<VocabularyModel>> getVocabulariesByLesson(int lessonId) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConfig.adminVocabularies, // Gọi API đã tạo
        queryParameters: {'lessonId': lessonId.toString()},
      );
      return (response.data as List)
          .map((e) => VocabularyModel.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi tải từ vựng');
    }
  }

  // POST: Tạo Từ vựng mới
  Future<void> createVocabulary(VocabularyModifyModel vocab) async {
    try {
      await _apiClient.dio.post(
        ApiConfig.adminVocabularies,
        data: vocab.toJson(),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi tạo từ vựng');
    }
  }

  // PUT: Cập nhật Từ vựng
  Future<void> updateVocabulary(int id, VocabularyModifyModel vocab) async {
    try {
      await _apiClient.dio.put(
        ApiConfig.adminVocabularyById(id),
        data: vocab.toJson(),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi cập nhật từ vựng');
    }
  }

  // DELETE: Xóa Từ vựng
  Future<void> deleteVocabulary(int id) async {
    try {
      await _apiClient.dio.delete(ApiConfig.adminVocabularyById(id));
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi xóa từ vựng');
    }
  }
}
