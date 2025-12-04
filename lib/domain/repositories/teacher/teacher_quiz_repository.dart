import 'package:dio/dio.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/constants/api_config.dart';
import 'package:mobile/data/models/quiz_models.dart';

class TeacherQuizRepository {
  final ApiClient _apiClient;

  TeacherQuizRepository(this._apiClient);

  Future<List<QuizListModel>> getQuizzes(
    String classId, {
    String? search,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConfig.teacherClassQuizzes(classId),
        queryParameters: {if (search != null) 'search': search},
      );

      final List<dynamic> list = response.data;
      return list.map((e) => QuizListModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Lỗi tải danh sách bài tập',
      );
    }
  }

  Future<QuizDetailModel> getQuizDetail(String classId, String quizId) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConfig.teacherQuizDetail(classId, quizId),
      );
      return QuizDetailModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Lỗi tải chi tiết bài tập',
      );
    }
  }
}
