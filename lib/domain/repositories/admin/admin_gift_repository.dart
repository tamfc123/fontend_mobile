import 'package:dio/dio.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/constants/api_config.dart';
import 'package:mobile/data/models/gift_model.dart';
import 'package:mobile/data/models/paged_result_model.dart';

class AdminGiftRepository {
  final ApiClient _apiClient;

  AdminGiftRepository(this._apiClient);

  Future<PagedResultModel<GiftModel>> getGifts({
    int pageNumber = 1,
    int pageSize = 5,
    String searchQuery = '',
    bool returnDeleted = false,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConfig.adminGifts,
        queryParameters: {
          'pageNumber': pageNumber,
          'pageSize': pageSize,
          'searchQuery': searchQuery,
          'returnDeleted': returnDeleted,
        },
      );

      return PagedResultModel<GiftModel>.fromJson(
        response.data,
        (json) => GiftModel.fromJson(json),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi tải danh sách quà');
    }
  }

  Future<void> createGift(GiftModel gift) async {
    try {
      await _apiClient.dio.post(ApiConfig.adminGifts, data: gift.toJson());
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi tạo quà tặng');
    }
  }

  Future<void> updateGift(String id, GiftModel gift) async {
    try {
      await _apiClient.dio.put(
        ApiConfig.adminGiftById(id),
        data: gift.toJson(),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi cập nhật quà tặng');
    }
  }

  Future<void> deleteGift(String id) async {
    try {
      await _apiClient.dio.delete(ApiConfig.adminGiftById(id));
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi xóa quà tặng');
    }
  }

  Future<void> restoreGift(String id) async {
    try {
      await _apiClient.dio.put(ApiConfig.adminRestoreGift(id));
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi khôi phục quà tặng');
    }
  }
}
