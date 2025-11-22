import 'package:dio/dio.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/constants/api_config.dart';
import 'package:mobile/data/models/vocabulary_model.dart';
import 'package:mobile/data/models/paged_result_model.dart';

class AdminVocabularyRepository {
  final ApiClient _apiClient;
  AdminVocabularyRepository(this._apiClient);

  // ✅ 2. SỬA HÀM GET: Lấy Từ vựng phân trang
  Future<PagedResultModel<VocabularyModel>> getPaginatedVocabularies({
    required String lessonId,
    int pageNumber = 1,
    int pageSize = 5,
    String? searchQuery,
  }) async {
    try {
      final queryParameters = {
        'lessonId': lessonId.toString(),
        'pageNumber': pageNumber.toString(),
        'pageSize': pageSize.toString(),
      };

      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParameters['searchQuery'] = searchQuery;
      }

      final response = await _apiClient.dio.get(
        ApiConfig.adminVocabularies,
        queryParameters: queryParameters,
      );

      return PagedResultModel.fromJson(
        response.data,
        (json) => VocabularyModel.fromJson(json),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi tải từ vựng');
    }
  }

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

  Future<void> updateVocabulary(String id, VocabularyModifyModel vocab) async {
    try {
      await _apiClient.dio.put(
        ApiConfig.adminVocabularyById(id),
        data: vocab.toJson(),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi cập nhật từ vựng');
    }
  }

  Future<void> deleteVocabulary(String id) async {
    try {
      final response = await _apiClient.dio.delete(
        ApiConfig.adminVocabularyById(id),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(response.data?['message'] ?? 'Lỗi không xác định');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi xóa từ vựng');
    }
  }
}
