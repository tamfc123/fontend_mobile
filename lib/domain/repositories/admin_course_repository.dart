import 'package:dio/dio.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/constants/api_config.dart';
import 'package:mobile/data/models/course_model.dart';
import 'package:mobile/data/models/paged_result_model.dart';

class AdminCourseRepository {
  final ApiClient _apiClient;
  AdminCourseRepository(this._apiClient);

  // Lấy tất cả khóa học
  Future<PagedResultModel<CourseModel>> getAllCourses({
    String? search,
    int pageNumber = 1,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConfig.courses,
        queryParameters: {'search': search, 'pageNumber': pageNumber},
      );

      return PagedResultModel.fromJson(
        response.data,
        (json) => CourseModel.fromJson(json),
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Không thể tải danh sách khóa học',
      );
    }
  }

  Future<List<CourseModel>> getAllCoursesForDropdown() async {
    try {
      final response = await _apiClient.dio.get(
        ApiConfig.adminGetAllCourses, // Endpoint: /api/courses/all-active
      );

      // Backend trả về List<CourseDTO>
      return (response.data as List)
          .map((json) => CourseModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ??
            'Không thể tải danh sách khóa học đầy đủ',
      );
    }
  }

  // Tạo khóa học
  Future<CourseModel> createCourse(CourseModel course) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConfig.courses,
        data: course.toJson(includeId: false),
      );

      final data = response.data;
      final json = (data is Map && data['data'] != null) ? data['data'] : data;
      return CourseModel.fromJson(json);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Không thể tạo khóa học');
    }
  }

  // Cập nhật khóa học
  Future<CourseModel> updateCourse(String id, CourseModel course) async {
    try {
      final response = await _apiClient.dio.put(
        ApiConfig.courseById(id),
        data: course.toJson(),
      );

      final data = response.data;
      final json = (data is Map && data['data'] != null) ? data['data'] : data;
      return CourseModel.fromJson(json);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Không thể cập nhật khóa học',
      );
    }
  }

  // Xóa khóa học
  Future<bool> deleteCourse(String id) async {
    try {
      await _apiClient.dio.delete(ApiConfig.courseById(id));
      return true;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi khi xóa khóa học');
    }
  }
}
