import 'package:dio/dio.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/constants/api_config.dart';
import 'package:mobile/data/models/teacher_dashboard_model.dart';

class TeaacherDashboardRepository {
  final ApiClient _apiClient;
  TeaacherDashboardRepository(this._apiClient);

  Future<TeacherDashboardModel> getTeacherDashboardSummary() async {
    try {
      final response = await _apiClient.dio.get(
        ApiConfig.teacherDashboardSummary,
      );
      return TeacherDashboardModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Không thể tải dữ liệu dashboard',
      );
    }
  }
}
