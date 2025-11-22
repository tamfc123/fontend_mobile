import 'package:dio/dio.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/constants/api_config.dart';
import 'package:mobile/data/models/teacher_schedule_model.dart';

class TeacherScheduleRepository {
  final ApiClient _apiClient;
  TeacherScheduleRepository(this._apiClient);

  Future<List<TeacherScheduleModel>> getTeacherSchedules({
    int? dayOfWeek,
  }) async {
    try {
      final Map<String, String> queryParams = {};
      if (dayOfWeek != null) queryParams['dayOfWeek'] = dayOfWeek.toString();

      final response = await _apiClient.dio.get(
        ApiConfig.teacherSchedules,
        queryParameters: queryParams,
      );

      return (response.data as List)
          .map((e) => TeacherScheduleModel.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi khi tải lịch dạy');
    }
  }
}
