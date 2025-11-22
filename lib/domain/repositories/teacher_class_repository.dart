import 'package:dio/dio.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/constants/api_config.dart';
import 'package:mobile/data/models/student_in_class_model.dart';
import 'package:mobile/data/models/teacher_class_model.dart';
import 'package:mobile/data/models/paged_result_model.dart';

class TeacherClassRepository {
  final ApiClient _apiClient;
  TeacherClassRepository(this._apiClient);

  Future<PagedResultModel<TeacherClassModel>> getPaginatedTeacherClasses({
    required int pageNumber,
    required int pageSize,
    String? search,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final queryParameters = {
        'pageNumber': pageNumber.toString(),
        'pageSize': pageSize.toString(),
        'search': search,
        'sortBy': sortBy,
        'sortOrder': sortOrder,
      };

      final response = await _apiClient.dio.get(
        ApiConfig.teacherClasses,
        queryParameters: queryParameters,
      );

      return PagedResultModel.fromJson(
        response.data,
        (json) => TeacherClassModel.fromJson(json),
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Lỗi khi tải danh sách lớp',
      );
    }
  }

  Future<void> updateTeacherClass(String id, String name) async {
    try {
      await _apiClient.dio.put(
        ApiConfig.teacherClassById(id),
        data: {'name': name},
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Có lỗi xảy ra');
    }
  }

  Future<List<StudentInClassModel>> getStudentsInClass(String classId) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConfig.getStudentsInClass(classId),
      );
      return (response.data as List)
          .map((e) => StudentInClassModel.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Lỗi khi tải danh sách sinh viên',
      );
    }
  }
}
