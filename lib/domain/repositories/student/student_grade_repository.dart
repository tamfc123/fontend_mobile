import 'package:dio/dio.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/constants/api_config.dart';
// 👇 Đảm bảo bạn import ĐÚNG MODEL (GradeSummaryModel)
import 'package:mobile/data/models/grade_summary_model.dart';

class StudentGradeRepository {
  final ApiClient _apiClient;
  StudentGradeRepository(this._apiClient);

  Future<GradeSummaryModel> getGradeSummary() async {
    try {
      final response = await _apiClient.dio.get(ApiConfig.studentGrades);
      return GradeSummaryModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi tải kết quả');
    }
  }
}
