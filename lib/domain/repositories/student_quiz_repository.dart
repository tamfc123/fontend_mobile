import 'package:dio/dio.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/constants/api_config.dart';
import 'package:mobile/data/models/student_quiz_models.dart';

class StudentQuizRepository {
  final ApiClient _apiClient;
  StudentQuizRepository(this._apiClient);

  Future<List<StudentQuizListModel>> fetchQuizList(
    String classId, {
    String? skillType,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConfig.getStudentQuizList(classId),
        // ✅ Gửi thêm query parameters
        queryParameters:
            (skillType != null && skillType != 'ALL')
                ? {'skillType': skillType}
                : null,
      );

      final List<dynamic> data = response.data as List;
      return data.map((json) => StudentQuizListModel.fromJson(json)).toList();
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? e.message;
      throw Exception(msg);
    }
  }

  Future<StudentQuizTakeModel> fetchQuizForTaking(
    String classId,
    String quizId,
  ) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConfig.getQuizForTaking(classId, quizId),
      );
      return StudentQuizTakeModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      // 👈 Dùng DioException
      throw Exception(
        'Lỗi Repository: Không thể tải chi tiết quiz: ${e.message}',
      );
    }
  }

  Future<Map<String, dynamic>> submitQuiz(
    String classId,
    String quizId,
    List<StudentAnswerInputModel> answers,
  ) async {
    try {
      final List<Map<String, dynamic>> encodableAnswers =
          answers.map((answer) => answer.toJson()).toList();
      final body = {'answers': encodableAnswers};

      final response = await _apiClient.dio.post(
        ApiConfig.submitQuiz(classId, quizId),
        data: body,
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data?['message'] ?? e.message ?? "Lỗi không xác định";
      throw Exception('Lỗi Repository: Không thể nộp bài: $errorMessage');
    }
  }

  Future<Map<String, dynamic>> submitWritingQuiz(
    String classId,
    String quizId,
    String content,
  ) async {
    try {
      // Body khớp với StudentWritingSubmissionDTO bên Backend
      final body = {'Content': content};

      final response = await _apiClient.dio.post(
        ApiConfig.submitWritingQuiz(classId, quizId),
        data: body,
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data?['message'] ?? e.message ?? "Lỗi không xác định";
      throw Exception(errorMessage);
    }
  }

  Future<StudentQuizReviewModel> fetchQuizResult(
    String classId,
    String quizId,
  ) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConfig.getQuizResult(classId, quizId),
      );
      return StudentQuizReviewModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw Exception(
        'Lỗi Repository: Không thể tải lịch sử bài làm: ${e.message}',
      );
    }
  }
}
