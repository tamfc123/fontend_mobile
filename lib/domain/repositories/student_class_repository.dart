import 'package:dio/dio.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/constants/api_config.dart';
import 'package:mobile/data/models/student_class_model.dart';

class StudentClassRepository {
  final ApiClient _apiClient;
  StudentClassRepository(this._apiClient);

  // 1. Lấy danh sách lớp ĐÃ tham gia
  Future<List<StudentClassModel>> getJoinedClasses() async {
    try {
      final response = await _apiClient.dio.get(ApiConfig.studentJoinedClasses);
      final List data = response.data;
      return data.map((json) => StudentClassModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Không thể tải lớp đã tham gia',
      );
    }
  }

  Future<void> joinClass(String classId) async {
    try {
      await _apiClient.dio.post(ApiConfig.studentJoinClass(classId));
    } on DioException catch (e) {
      // Backend trả về lỗi 400 nếu chưa đủ Level hoặc đã tham gia
      throw Exception(e.response?.data['message'] ?? 'Không thể tham gia lớp');
    }
  }

  // 4. Rời lớp
  Future<void> leaveClass(String classId) async {
    try {
      await _apiClient.dio.delete(ApiConfig.studentLeaveClass(classId));
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Không thể rời lớp');
    }
  }
}
