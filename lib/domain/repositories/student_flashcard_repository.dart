// lib/domain/repositories/student_flashcard_repository.dart
import 'package:dio/dio.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/constants/api_config.dart';
import 'package:mobile/data/models/flashcard_session_model.dart';
import 'package:mobile/data/models/pronunciation_result_model.dart';

class StudentFlashcardRepository {
  final ApiClient _apiClient;
  StudentFlashcardRepository(this._apiClient);

  // 1. Lấy danh sách Flashcard
  Future<FlashcardSessionModel> getFlashcards(String lessonId) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConfig.studentLessonFlashcards(lessonId),
      );
      return FlashcardSessionModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi tải flashcards');
    }
  }

  Future<PronunciationResultModel> assessPronunciation(
    String vocabularyId,
    String audioPath,
  ) async {
    try {
      String fileName = audioPath.split('/').last;
      FormData formData = FormData.fromMap({
        'vocabularyId': vocabularyId,
        'audioFile': await MultipartFile.fromFile(
          audioPath,
          filename: fileName,
        ),
      });

      final response = await _apiClient.dio.post(
        ApiConfig.studentAssessPronunciation,
        data: formData,
      );

      return PronunciationResultModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi gửi file âm thanh');
    }
  }
}
