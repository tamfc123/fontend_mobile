import 'package:dio/dio.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/constants/api_config.dart';
import 'package:mobile/data/models/course_model.dart';
import 'package:mobile/data/models/student_class_model.dart';

class StudentCourseRepository {
  final ApiClient _apiClient;
  StudentCourseRepository(this._apiClient);

  // Lấy danh sách khóa học khả dụng
  Future<List<CourseModel>> getAvailableCourses() async {
    try {
      final response = await _apiClient.dio.get(
        ApiConfig.studentAvailableCourses,
      );

      final data = response.data;

      // Giữ nguyên logic xử lý 2 kiểu trả về của backend
      if (data is List) {
        return data.map((e) => CourseModel.fromJson(e)).toList();
      }
      if (data is Map && data['data'] != null) {
        return (data['data'] as List)
            .map((e) => CourseModel.fromJson(e))
            .toList();
      }
      throw ("Dữ liệu không đúng định dạng");
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Không thể tải khóa học');
    }
  }

  Future<List<StudentClassModel>> getClassesByCourse(int courseId) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConfig.studentClassesByCourse(courseId),
      );

      final data = response.data as List;
      // Code ApiService cũ của bạn đã map sang StudentClassModel
      return data.map((e) => StudentClassModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Không thể tải lớp học');
    }
  }

  // --- BỔ SUNG HÀM MỚI 2 ---
  Future<void> joinClass(int classId) async {
    try {
      await _apiClient.dio.post(ApiConfig.studentJoinClass(classId));
      // Dio tự ném lỗi nếu status != 200
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Không thể tham gia lớp');
    }
  }
}
