import 'package:dio/dio.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/constants/api_config.dart';
// 👇 Đảm bảo bạn import ĐÚNG MODEL (GradeSummaryModel)
import 'package:mobile/data/models/grade_summary_model.dart';

class StudentGradeRepository {
  final ApiClient _apiClient;
  StudentGradeRepository(this._apiClient);

  // ✅ SỬA LỖI: Hàm này trả về 1 object GradeSummaryModel, KHÔNG PHẢI List
  Future<GradeSummaryModel> getGradeSummary() async {
    try {
      final response = await _apiClient.dio.get(ApiConfig.studentGrades);

      // ✅ SỬA LỖI: API trả về 1 object, không phải list.
      // Vì vậy, chúng ta parse 'response.data' trực tiếp.
      print('Grade Summary Response Data: ${response.data}');
      return GradeSummaryModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi tải kết quả');
    }
  }
}
