import 'package:dio/dio.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/constants/api_config.dart';
import 'package:mobile/data/models/teacher_schedule_model.dart';

class TeacherScheduleRepository {
  final ApiClient _apiClient;
  TeacherScheduleRepository(this._apiClient);

  // Lấy lịch dạy của giáo viên (có filter)
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

  // Tạo lịch giảng dạy
  Future<void> createTeacherSchedule(Map<String, dynamic> json) async {
    try {
      await _apiClient.dio.post(ApiConfig.teacherSchedules, data: json);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Tạo lịch thất bại');
    }
  }

  // Cập nhật lịch giảng dạy
  Future<void> updateTeacherSchedule(int id, Map<String, dynamic> json) async {
    try {
      await _apiClient.dio.put(ApiConfig.teacherScheduleById(id), data: json);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Cập nhật thất bại');
    }
  }

  // Xoá lịch giảng dạy
  Future<void> deleteTeacherSchedule(int id) async {
    try {
      await _apiClient.dio.delete(ApiConfig.teacherScheduleById(id));
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Xoá lịch thất bại');
    }
  }
}
