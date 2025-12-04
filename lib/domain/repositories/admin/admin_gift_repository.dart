import 'package:dio/dio.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/constants/api_config.dart';
import 'package:mobile/data/models/gift_model.dart';

class AdminGiftRepository {
  final ApiClient _apiClient;

  AdminGiftRepository(this._apiClient);

  Future<List<GiftModel>> getGifts({bool returnDeleted = false}) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConfig.adminGifts,
        queryParameters: {'returnDeleted': returnDeleted},
      );
      final List<dynamic> list = response.data;
      return list.map((e) => GiftModel.fromJson(e)).toList();
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
