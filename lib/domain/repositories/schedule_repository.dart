import 'package:dio/dio.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/constants/api_config.dart';
import 'package:mobile/data/models/class_schedule_model.dart';
import 'package:mobile/utils/extension_helper.dart';

class ScheduleRepository {
  final ApiClient _apiClient;
  ScheduleRepository(this._apiClient);

  // Lấy tất cả lịch học (có filter)
  Future<List<ClassScheduleModel>> getAllSchedules({
    int? classId,
    String? courseName,
    String? teacherName,
    int? dayOfWeek,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (classId != null) queryParams['classId'] = classId.toString();
      if (courseName != null && courseName.isNotEmpty) {
        queryParams['courseName'] = courseName;
      }
      if (teacherName != null && teacherName.isNotEmpty) {
        queryParams['teacherName'] = teacherName;
      }
      if (dayOfWeek != null) queryParams['dayOfWeek'] = dayOfWeek.toString();

      final response = await _apiClient.dio.get(
        ApiConfig.adminSchedules,
        queryParameters: queryParams,
      );

      return (response.data as List)
          .map((e) => ClassScheduleModel.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Lỗi khi tải danh sách lịch học',
      );
    }
  }

  // Tạo lịch học
  Future<void> createSchedule(ClassScheduleModel schedule) async {
    try {
      final body = {
        'classId': schedule.classId,
        'dayOfWeek': schedule.dayStringToInt(),
        'startTime': schedule.startTime,
        'endTime': schedule.endTime,
        'room': schedule.room,
        'startDate': schedule.startDate.toIso8601String(),
        'endDate': schedule.endDate.toIso8601String(),
        'teacherId': schedule.teacherId,
      };

      await _apiClient.dio.post(ApiConfig.adminSchedules, data: body);
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data?['message'] ?? "Tạo lịch học thất bại";
      throw Exception(errorMessage);
    }
  }

  // Cập nhật lịch học
  Future<void> updateSchedule(int id, ClassScheduleModel schedule) async {
    try {
      final body = {
        'classId': schedule.classId,
        'dayOfWeek': schedule.dayStringToInt(),
        'startTime': schedule.startTime,
        'endTime': schedule.endTime,
        'room': schedule.room,
        'startDate': schedule.startDate.toIso8601String(),
        'endDate': schedule.endDate.toIso8601String(),
        'teacherId': schedule.teacherId, // Bỏ .toString()
      };

      await _apiClient.dio.put(ApiConfig.adminScheduleById(id), data: body);
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data?['message'] ?? "Cập nhật lịch học thất bại";
      throw Exception(errorMessage);
    }
  }

  // Xóa lịch học
  Future<void> deleteSchedule(int id) async {
    try {
      await _apiClient.dio.delete(ApiConfig.adminScheduleById(id));
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data?['message'] ?? "Xóa lịch học thất bại";
      throw Exception(errorMessage);
    }
  }
}
