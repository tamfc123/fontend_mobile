import 'package:dio/dio.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/constants/api_config.dart';
import 'package:mobile/data/models/student_schedule_model.dart';

class StudentScheduleRepository {
  final ApiClient _apiClient;
  StudentScheduleRepository(this._apiClient);

  // Lấy lịch học của sinh viên (có filter)
  Future<List<StudentScheduleModel>> getStudentSchedules({
    int? dayOfWeek,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (dayOfWeek != null) queryParams['dayOfWeek'] = dayOfWeek.toString();

      final response = await _apiClient.dio.get(
        ApiConfig.studentSchedules,
        queryParameters: queryParams, // Dio tự xử lý query
      );

      return (response.data as List)
          .map((e) => StudentScheduleModel.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to load schedules',
      );
    }
  }
}
