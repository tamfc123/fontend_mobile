import 'package:dio/dio.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/constants/api_config.dart';
import 'package:mobile/data/models/leaderboard_model.dart';

class LeaderboardRepository {
  final ApiClient _apiClient;
  LeaderboardRepository(this._apiClient);

  // Lấy bảng xếp hạng (theo 'xp' hoặc 'coins')
  Future<LeaderboardResponseModel> getLeaderboard(String sortBy) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConfig.studentLeaderboard, // <-- Dùng route mới (/leaderboard)
        queryParameters: {'sortBy': sortBy},
      );
      // API trả về 1 object, không phải list
      return LeaderboardResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi tải Bảng xếp hạng');
    }
  }
}
