import 'package:dio/dio.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/constants/api_config.dart';
import 'package:mobile/data/models/course_model.dart';

class CourseRepository {
  final ApiClient _apiClient;
  CourseRepository(this._apiClient);

  // Lấy tất cả khóa học
  Future<List<CourseModel>> getAllCourses() async {
    try {
      final response = await _apiClient.dio.get(ApiConfig.courses);
      final data = response.data;

      // Xử lý logic backend trả về 2 kiểu (List hoặc Map)
      if (data is List) {
        return data.map((e) => CourseModel.fromJson(e)).toList();
      }
      if (data is Map && data['data'] != null) {
        return (data['data'] as List)
            .map((e) => CourseModel.fromJson(e))
            .toList();
      }
      throw ('Dữ liệu khóa học không đúng định dạng');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Không thể tải danh sách khóa học',
      );
    }
  }

  // Tạo khóa học
  Future<CourseModel> createCourse(CourseModel course) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConfig.courses,
        data: course.toJson(includeId: false), // Giữ nguyên logic cũ
      );

      final data = response.data;
      // Xử lý logic backend trả về 2 kiểu
      final json = (data is Map && data['data'] != null) ? data['data'] : data;
      return CourseModel.fromJson(json);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Không thể tạo khóa học');
    }
  }

  // Cập nhật khóa học
  Future<CourseModel> updateCourse(int id, CourseModel course) async {
    try {
      final response = await _apiClient.dio.put(
        ApiConfig.courseById(id),
        data: course.toJson(),
      );

      final data = response.data;
      // Xử lý logic backend trả về 2 kiểu
      final json = (data is Map && data['data'] != null) ? data['data'] : data;
      return CourseModel.fromJson(json);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Không thể cập nhật khóa học',
      );
    }
  }

  // Xóa khóa học
  Future<bool> deleteCourse(int id) async {
    try {
      await _apiClient.dio.delete(ApiConfig.courseById(id));
      // Dio ném lỗi nếu status != 2xx, nên nếu đến đây là thành công
      return true;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi khi xóa khóa học');
    }
  }
}
