import 'package:dio/dio.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/constants/api_config.dart';
import 'package:mobile/data/models/class_model.dart';

class ClassRepository {
  final ApiClient _apiClient;
  ClassRepository(this._apiClient);

  // Lấy tất cả lớp học
  Future<List<ClassModel>> getAllClasses() async {
    try {
      final response = await _apiClient.dio.get(ApiConfig.classes);
      // Logic cũ: (data as List).map((e) => ClassModel.fromJson(e)).toList()
      return (response.data as List)
          .map((e) => ClassModel.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Lỗi khi tải danh sách lớp học',
      );
    }
  }

  // Tạo lớp học
  Future<bool> createClass(String name, int courseId, String? teacherId) async {
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
    int id,
    String name,
    int courseId,
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
  Future<bool> deleteClass(int id) async {
    try {
      await _apiClient.dio.delete(ApiConfig.classById(id));
      return true;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi khi xóa lớp học');
    }
  }
}
