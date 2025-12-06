import 'package:dio/dio.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/constants/api_config.dart';
import 'package:mobile/data/models/class_schedule_model.dart';
import 'package:mobile/utils/extension_helper.dart';

// Class phụ để gửi dữ liệu slot lên
class WeeklySlotRequest {
  final int dayOfWeek;
  final String startTime;
  final String endTime;
  final String roomId;

  WeeklySlotRequest({
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.roomId,
  });

  Map<String, dynamic> toJson() => {
    "dayOfWeek": dayOfWeek,
    "startTime": startTime,
    "endTime": endTime,
    "roomId": roomId,
  };
}

class AdminScheduleRepository {
  final ApiClient _apiClient;
  AdminScheduleRepository(this._apiClient);

  // 1. Lấy tất cả lịch học (Đã thêm sort)
  Future<List<ClassScheduleModel>> getAllSchedules({
    String? teacherName,
    int? dayOfWeek,
    String? sortBy = 'time',
    String? sortOrder = 'asc',
  }) async {
    try {
      final queryParams = <String, String>{};
      if (teacherName != null && teacherName.isNotEmpty) {
        queryParams['teacherName'] = teacherName;
      }
      if (dayOfWeek != null) queryParams['dayOfWeek'] = dayOfWeek.toString();
      if (sortBy != null && sortBy.isNotEmpty) {
        queryParams['sortBy'] = sortBy;
      }
      if (sortOrder != null && sortOrder.isNotEmpty) {
        queryParams['sortOrder'] = sortOrder;
      }

      final response = await _apiClient.dio.get(
        ApiConfig.adminSchedules,
        queryParameters: queryParams,
      );

      return (response.data as List)
          .map((e) => ClassScheduleModel.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data is Map
            ? (e.response?.data['message'] ?? 'Lỗi khi tải danh sách lịch học')
            : 'Lỗi kết nối (${e.response?.statusCode})',
      );
    }
  }

  // 2. ✅ Create Bulk (ĐÃ SỬA LỖI CRASH KHI PARSE ERROR)
  Future<void> createBulkSchedule({
    required String classId,
    required String teacherId,
    required DateTime rangeStartDate,
    required DateTime rangeEndDate,
    required List<WeeklySlotRequest> slots,
  }) async {
    try {
      final body = {
        "classId": classId,
        "teacherId": teacherId,
        "rangeStartDate": rangeStartDate.toIso8601String(),
        "rangeEndDate": rangeEndDate.toIso8601String(),
        "slots": slots.map((e) => e.toJson()).toList(),
      };

      await _apiClient.dio.post("${ApiConfig.adminSchedules}/bulk", data: body);
    } on DioException catch (e) {
      // ✅ FIX: Kiểm tra kỹ kiểu dữ liệu trước khi truy cập
      if (e.response?.data != null && e.response!.data is Map) {
        final data = e.response!.data as Map;

        // Trường hợp 1: Backend trả về list lỗi chi tiết (custom logic của ta)
        if (data['details'] != null && data['details'] is List) {
          final details = (data['details'] as List).join('\n');
          throw Exception(details);
        }

        // Trường hợp 2: Backend trả về lỗi message chung
        if (data['message'] != null) {
          throw Exception(data['message']);
        }
      }

      // Trường hợp 3: Lỗi không phải JSON (vd: 404 HTML, 500 Server Error)
      final errorMessage =
          e.message ?? "Tạo lịch học thất bại (${e.response?.statusCode})";
      throw Exception(errorMessage);
    }
  }

  // 3. Update
  Future<void> updateSchedule(String id, ClassScheduleModel schedule) async {
    try {
      final body = {
        'classId': schedule.classId,
        'dayOfWeek': schedule.dayStringToInt(),
        'startTime': schedule.startTime,
        'endTime': schedule.endTime,
        'roomId': schedule.roomId,
        'startDate': schedule.startDate.toIso8601String(),
        'endDate': schedule.endDate.toIso8601String(),
        'teacherId': schedule.teacherId,
      };

      await _apiClient.dio.put(ApiConfig.adminScheduleById(id), data: body);
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data is Map
              ? (e.response?.data['message'] ?? "Cập nhật lịch học thất bại")
              : "Lỗi hệ thống (${e.response?.statusCode})";
      throw Exception(errorMessage);
    }
  }

  // 4. Delete
  Future<void> deleteSchedule(String id) async {
    try {
      await _apiClient.dio.delete(ApiConfig.adminScheduleById(id));
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data is Map
              ? (e.response?.data['message'] ?? "Xóa lịch học thất bại")
              : "Lỗi hệ thống (${e.response?.statusCode})";
      throw Exception(errorMessage);
    }
  }
}
