import 'package:dio/dio.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/constants/api_config.dart';
import 'package:mobile/data/models/gift_model.dart';
import 'package:mobile/data/models/student_redemption_model.dart';

class StudentGiftRepository {
  final ApiClient _apiClient;

  StudentGiftRepository(this._apiClient);

  // 1. Lấy danh sách quà đang bán
  Future<List<GiftModel>> getAvailableGifts() async {
    try {
      final response = await _apiClient.dio.get(ApiConfig.studentGifts);
      final List<dynamic> list = response.data;
      return list.map((e) => GiftModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi tải cửa hàng');
    }
  }

  // 2. Lấy lịch sử đổi quà
  Future<List<StudentRedemptionModel>> getMyRedemptions() async {
    try {
      final response = await _apiClient.dio.get(ApiConfig.studentMyRedemptions);
      final List<dynamic> list = response.data;
      return list.map((e) => StudentRedemptionModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi tải lịch sử');
    }
  }

  // 3. Đổi quà (Redeem)
  Future<int> redeemGift(String giftId) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConfig.studentRedeemGift(giftId),
      );
      // Backend trả về: { "message": "...", "newCoinBalance": 1000 }
      return response.data['newCoinBalance'] ?? 0;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Đổi quà thất bại');
    }
  }
}
