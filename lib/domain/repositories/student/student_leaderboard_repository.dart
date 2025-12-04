import 'package:dio/dio.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/constants/api_config.dart';
import 'package:mobile/data/models/leaderboard_model.dart';

class StudentLeaderboardRepository {
  final ApiClient _apiClient;
  StudentLeaderboardRepository(this._apiClient);

  Future<LeaderboardResponseModel> getLeaderboard(String sortBy) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConfig.studentLeaderboard,
        queryParameters: {'sortBy': sortBy},
      );
      return LeaderboardResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi tải Bảng xếp hạng');
    }
  }
}
