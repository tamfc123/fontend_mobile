import 'package:dio/dio.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/constants/api_config.dart';
import 'package:mobile/data/models/admin_chart_data_model.dart';
import 'package:mobile/data/models/admin_dashboard_stats_model.dart';
import 'package:mobile/data/models/admin_pie_chart_model.dart';
import 'package:mobile/data/models/admin_recent_teacher_model.dart';
import 'package:mobile/data/models/admin_top_student_model.dart';

class AdminDashboardRepository {
  final ApiClient _apiClient;
  AdminDashboardRepository(this._apiClient);

  Future<AdminDashboardStatsModel> getDashboardStats() async {
    try {
      final response = await _apiClient.dio.get(ApiConfig.adminDashboardStats);
      return AdminDashboardStatsModel.fromJson(response.data);
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? "Lỗi tải thống kê";
      throw Exception(errorMessage);
    }
  }

  Future<List<AdminChartDataModel>> getNewUsersChart() async {
    try {
      final response = await _apiClient.dio.get(ApiConfig.adminNewUsersChart);
      final List<dynamic> data = response.data as List;
      return data.map((json) => AdminChartDataModel.fromJson(json)).toList();
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data?['message'] ?? "Lỗi tải dữ liệu biểu đồ";
      throw Exception(errorMessage);
    }
  }

  Future<List<AdminPieChartModel>> getQuizSkillDistribution() async {
    try {
      final response = await _apiClient.dio.get(
        ApiConfig.adminQuizSkillDistribution,
      );
      final List<dynamic> data = response.data as List;
      return data.map((json) => AdminPieChartModel.fromJson(json)).toList();
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data?['message'] ?? "Lỗi tải dữ liệu biểu đồ tròn";
      throw Exception(errorMessage);
    }
  }

  Future<List<AdminRecentTeacherModel>> getRecentTeachers() async {
    try {
      final response = await _apiClient.dio.get(ApiConfig.adminRecentTeachers);
      final List<dynamic> data = response.data as List;
      return data
          .map((json) => AdminRecentTeacherModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data?['message'] ?? "Lỗi tải danh sách giáo viên";
      throw Exception(errorMessage);
    }
  }

  Future<List<AdminTopStudentModel>> getTopStudents() async {
    try {
      final response = await _apiClient.dio.get(ApiConfig.adminTopStudents);
      final List<dynamic> data = response.data as List;
      return data.map((json) => AdminTopStudentModel.fromJson(json)).toList();
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data?['message'] ?? "Lỗi tải danh sách sinh viên";
      throw Exception(errorMessage);
    }
  }
}
