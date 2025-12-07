import 'package:dio/dio.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/constants/api_config.dart';
import 'package:mobile/data/models/student_redemption_model.dart';

class AdminGiftRedemptionRepository {
  final ApiClient _apiClient;

  AdminGiftRedemptionRepository(this._apiClient);

  /// Lấy lịch sử đổi quà của 1 học viên
  Future<List<StudentRedemptionModel>> getUserRedemptions(String userId) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConfig.adminUserRedemptions(userId),
      );
      final List<dynamic> list = response.data;
      return list.map((e) => StudentRedemptionModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi tải lịch sử đổi quà');
    }
  }

  /// Xác nhận đã trao quà
  Future<void> confirmRedemption(String redemptionId) async {
    try {
      await _apiClient.dio.put(ApiConfig.adminConfirmRedemption(redemptionId));
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi xác nhận trao quà');
    }
  }
}
