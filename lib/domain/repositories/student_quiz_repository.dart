import 'package:dio/dio.dart'; // 👈 Import DioException (nếu bạn chưa có)
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/constants/api_config.dart';
import 'package:mobile/data/models/student_quiz_list_model.dart';
import 'package:mobile/data/models/student_quiz_review_model.dart';
import 'package:mobile/data/models/student_quiz_take_model.dart';
// ✅ 1. IMPORT MODEL MỚI BẠN VỪA TẠO
import 'package:mobile/data/models/student_submission_model.dart';

class StudentQuizRepository {
  final ApiClient _apiClient;
  StudentQuizRepository(this._apiClient);

  /// API 1: Lấy danh sách quiz (OK - Không cần sửa)
  /// (Model 'StudentQuizListModel' đã được cập nhật để nhận SkillType)
  Future<List<StudentQuizListModel>> fetchQuizList(int classId) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConfig.getStudentQuizList(classId),
      );
      final List<dynamic> data = response.data as List;
      return data.map((json) => StudentQuizListModel.fromJson(json)).toList();
    } on DioException catch (e) {
      // 👈 Dùng DioException
      throw Exception(
        'Lỗi Repository: Không thể tải danh sách quiz: ${e.message}',
      );
    }
  }

  /// API 2: Lấy chi tiết quiz để làm (OK - Không cần sửa)
  /// (Model 'StudentQuizTakeModel' đã được cập nhật để nhận các trường mới)
  Future<StudentQuizTakeModel> fetchQuizForTaking(
    int classId,
    int quizId,
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

  // ✅ ========================================================
  // ✅ API 3: NỘP BÀI (ĐÃ CẬP NHẬT HOÀN TOÀN)
  // ✅ ========================================================
  Future<Map<String, dynamic>> submitQuiz(
    int classId,
    int quizId,
    // 2. 👈 THAM SỐ ĐÃ THAY ĐỔI
    List<StudentAnswerInputModel> answers,
  ) async {
    try {
      // 3. 👈 Chuyển đổi List<Model> sang List<Map>
      final List<Map<String, dynamic>> encodableAnswers =
          answers.map((answer) => answer.toJson()).toList();

      // 4. 👈 Body phải khớp với StudentSubmissionDTO của C#
      final body = {'answers': encodableAnswers};

      final response = await _apiClient.dio.post(
        ApiConfig.submitQuiz(classId, quizId),
        data: body,
      );
      // Kết quả trả về vẫn là Map (chứa score, xpGained...)
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      // 👈 Dùng DioException
      final errorMessage =
          e.response?.data?['message'] ?? e.message ?? "Lỗi không xác định";
      throw Exception('Lỗi Repository: Không thể nộp bài: $errorMessage');
    }
  }

  /// API 4: Lấy chi tiết kết quả (OK - Không cần sửa)
  /// (Model 'StudentQuizReviewModel' đã được cập nhật để nhận các trường mới)
  Future<StudentQuizReviewModel> fetchQuizResult(
    int classId,
    int quizId,
  ) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConfig.getQuizResult(classId, quizId),
      );
      return StudentQuizReviewModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      // 👈 Dùng DioException
      throw Exception(
        'Lỗi Repository: Không thể tải lịch sử bài làm: ${e.message}',
      );
    }
  }
}
