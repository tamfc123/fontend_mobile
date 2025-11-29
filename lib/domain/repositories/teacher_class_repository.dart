import 'package:dio/dio.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/constants/api_config.dart';
import 'package:mobile/data/models/class_skill_overview_model.dart';
import 'package:mobile/data/models/student_detail_model.dart';
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

  Future<List<ClassSkillOverviewModel>> getClassSkills(String classId) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConfig.teacherClassSkills(
          classId,
        ), // Nhớ check ApiConfig đã có hàm này chưa
      );

      return (response.data as List)
          .map((e) => ClassSkillOverviewModel.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi tải dữ liệu kỹ năng');
    }
  }

  Future<StudentDetailModel> getStudentDetail(
    String classId,
    String studentId,
  ) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConfig.getStudentDetail(
          classId,
          studentId,
        ), // Nhớ thêm vào ApiConfig
      );
      return StudentDetailModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi tải thông tin');
    }
  }
}
