// lib/domain/repositories/quiz_repository.dart

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/constants/api_config.dart';
import 'package:mobile/data/models/quiz_detail_model.dart';
import 'package:mobile/data/models/quiz_list_model.dart';

class QuizRepository {
  final ApiClient _apiClient;
  QuizRepository(this._apiClient);

  // 1. Lấy danh sách Quizzes (Không cần sửa)
  // (Nó tự hoạt động vì QuizListModel.fromJson đã được cập nhật)
  Future<List<QuizListModel>> getQuizzes(int classId) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConfig.teacherQuizzes(classId),
      );
      return (response.data as List)
          .map((e) => QuizListModel.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Lỗi khi tải danh sách bài tập',
      );
    }
  }

  // 2. Lấy chi tiết một Quiz (Không cần sửa)
  // (Nó tự hoạt động vì QuizDetailModel.fromJson đã được cập nhật)
  Future<QuizDetailModel> getQuizDetails(int classId, int quizId) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConfig.teacherQuizById(classId, quizId),
      );
      return QuizDetailModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Lỗi khi tải chi tiết bài tập',
      );
    }
  }

  // 3. Xóa một Quiz (Không cần sửa)
  Future<void> deleteQuiz(int classId, int quizId) async {
    try {
      await _apiClient.dio.delete(ApiConfig.teacherQuizById(classId, quizId));
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi khi xóa bài tập');
    }
  }

  // ✅ ========================================================
  // ✅ 4. TẠO MỚI QUIZ (ĐÃ CẬP NHẬT)
  // ✅ ========================================================
  Future<void> createQuiz({
    required int classId,
    required String title,
    String? description,
    required int timeLimitMinutes,
    required PlatformFile platformFile,

    // ✅ THÊM CÁC TRƯỜNG MỚI TỪ DTO
    required String skillType,
    String? readingPassage,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'Title': title,
        'Description': description ?? '',
        'TimeLimitMinutes': timeLimitMinutes,

        // ✅ THÊM CÁC TRƯỜNG MỚI VÀO FORMDATA
        'SkillType': skillType,
        'ReadingPassage': readingPassage ?? '', // Gửi chuỗi rỗng nếu null

        'File': MultipartFile.fromBytes(
          platformFile.bytes!,
          filename: platformFile.name,
        ),
      });

      await _apiClient.dio.post(
        ApiConfig.teacherQuizzes(classId),
        data: formData,
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi khi tạo bài tập');
    }
  }
}
