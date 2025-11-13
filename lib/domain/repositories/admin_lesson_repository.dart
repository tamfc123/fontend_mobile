// file: domain/repositories/admin_lesson_repository.dart
import 'package:dio/dio.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/constants/api_config.dart';
import 'package:mobile/data/models/lesson_model.dart';

class AdminLessonRepository {
  final ApiClient _apiClient;
  AdminLessonRepository(this._apiClient);

  // GET: Lấy tất cả Lesson của 1 Module
  Future<List<LessonModel>> getLessonsByModule(int moduleId) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConfig.adminLessons,
        queryParameters: {'moduleId': moduleId.toString()},
      );
      return (response.data as List)
          .map((e) => LessonModel.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi tải bài học');
    }
  }

  // POST: Tạo Lesson mới
  Future<void> createLesson(LessonModifyModel lesson) async {
    try {
      await _apiClient.dio.post(ApiConfig.adminLessons, data: lesson.toJson());
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi tạo bài học');
    }
  }

  // PUT: Cập nhật Lesson (chủ yếu là cập nhật 'Content')
  Future<void> updateLesson(int id, LessonModifyModel lesson) async {
    try {
      await _apiClient.dio.put(
        ApiConfig.adminLessonById(id),
        data: lesson.toJson(),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi cập nhật bài học');
    }
  }

  // DELETE: Xóa Lesson
  Future<void> deleteLesson(int id) async {
    try {
      await _apiClient.dio.delete(ApiConfig.adminLessonById(id));
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi xóa bài học');
    }
  }
}
