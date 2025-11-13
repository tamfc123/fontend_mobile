import 'package:dio/dio.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/constants/api_config.dart';
import 'package:mobile/data/models/student_class_model.dart';

class StudentClassRepository {
  final ApiClient _apiClient;
  StudentClassRepository(this._apiClient);

  // Lấy danh sách lớp đã tham gia
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

  // Rời lớp
  Future<void> leaveClass(int classId) async {
    try {
      await _apiClient.dio.delete(ApiConfig.studentLeaveClass(classId));
      // Dio tự ném lỗi nếu status != 200
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Không thể rời lớp');
    }
  }
}
