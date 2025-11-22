import 'package:dio/dio.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/constants/api_config.dart';
import 'package:mobile/data/models/class_model.dart';
import 'package:mobile/data/models/paged_result_model.dart';

class AdminClassRepository {
  final ApiClient _apiClient;
  AdminClassRepository(this._apiClient);

  // Lấy tất cả lớp học
  Future<PagedResultModel<ClassModel>> getAllClasses({
    String? search,
    int pageNumber = 1,
  }) async {
    try {
      // 2. Thêm queryParameters vào request
      final response = await _apiClient.dio.get(
        ApiConfig.classes,
        queryParameters: {
          'search': search,
          'pageNumber': pageNumber,
          // PageSize đã được set cứng = 5 ở backend
        },
      );

      return PagedResultModel.fromJson(
        response.data,
        (json) => ClassModel.fromJson(json),
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Lỗi khi tải danh sách lớp học',
      );
    }
  }

  Future<List<ClassModel>> getAllActiveClasses() async {
    try {
      final response = await _apiClient.dio.get(
        ApiConfig.adminGetAllActiveClasses,
      );
      return (response.data as List)
          .map((json) => ClassModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ??
            'Không thể tải danh sách lớp học (active)',
      );
    }
  }

  // Tạo lớp học
  Future<bool> createClass(
    String name,
    String courseId,
    String? teacherId,
  ) async {
    try {
      await _apiClient.dio.post(
        ApiConfig.classes,
        data: {
          'name': name,
          'courseId': courseId,
          if (teacherId != null) 'teacherId': teacherId,
        },
      );
      // Dio ném lỗi nếu status != 200/201, nên đến đây là thành công
      return true;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi khi tạo lớp học');
    }
  }

  // Cập nhật lớp học
  Future<bool> updateClass(
    String id,
    String name,
    String courseId,
    String? teacherId,
  ) async {
    try {
      await _apiClient.dio.put(
        ApiConfig.classById(id),
        data: {
          'name': name,
          'courseId': courseId,
          if (teacherId != null) 'teacherId': teacherId,
        },
      );
      return true;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Lỗi khi cập nhật lớp học',
      );
    }
  }

  // Xóa lớp học
  Future<bool> deleteClass(String id) async {
    try {
      await _apiClient.dio.delete(ApiConfig.classById(id));
      return true;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi khi xóa lớp học');
    }
  }
}
