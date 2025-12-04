import 'package:dio/dio.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/constants/api_config.dart';
import 'package:mobile/data/models/admin_redemption_model.dart';

class AdminRedemptionRepository {
  final ApiClient _apiClient;

  AdminRedemptionRepository(this._apiClient);

  Future<List<AdminRedemptionModel>> getUserRedemptions(String userId) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConfig.adminUserRedemptions(userId),
      );
      final List<dynamic> list = response.data;
      return list.map((e) => AdminRedemptionModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi tải lịch sử');
    }
  }

  Future<void> confirmRedemption(String redemptionId) async {
    try {
      await _apiClient.dio.put(ApiConfig.adminConfirmRedemption(redemptionId));
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Xác nhận thất bại');
    }
  }
}
