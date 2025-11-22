// file: domain/repositories/admin_lesson_repository.dart
import 'package:dio/dio.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/constants/api_config.dart';
import 'package:mobile/data/models/lesson_model.dart';
import 'package:mobile/data/models/paged_result_model.dart';

class AdminLessonRepository {
  final ApiClient _apiClient;
  AdminLessonRepository(this._apiClient);

  // GET: Lấy tất cả Lesson của 1 Module
  Future<PagedResultModel<LessonModel>> getPaginatedLessons({
    required String moduleId,
    int pageNumber = 1,
    int pageSize = 5,
    String? searchQuery,
  }) async {
    try {
      final queryParameters = {
        'moduleId': moduleId.toString(),
        'pageNumber': pageNumber.toString(),
        'pageSize': pageSize.toString(),
      };

      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParameters['searchQuery'] = searchQuery;
      }

      final response = await _apiClient.dio.get(
        ApiConfig.adminLessons,
        queryParameters: queryParameters,
      );

      return PagedResultModel.fromJson(
        response.data,
        (json) => LessonModel.fromJson(json),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi tải bài học');
    }
  }

  Future<LessonModel> getLessonById(String lessonId) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConfig.adminLessonById(lessonId),
      );
      // API này trả về 1 object LessonModel (đã có Content)
      return LessonModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Lỗi tải chi tiết bài học',
      );
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
  Future<void> updateLesson(String id, LessonModifyModel lesson) async {
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
  Future<void> deleteLesson(String id) async {
    try {
      final response = await _apiClient.dio.delete(
        ApiConfig.adminLessonById(id),
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(response.data?['message'] ?? 'Lỗi không xác định');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi xóa bài học');
    }
  }
}
