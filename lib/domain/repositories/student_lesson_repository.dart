import 'package:dio/dio.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/constants/api_config.dart';
import 'package:mobile/data/models/lesson_model.dart';

class StudentLessonRepository {
  final ApiClient _apiClient;
  StudentLessonRepository(this._apiClient);

  // GET: Lấy tất cả Lesson (Bài học) của 1 Module (Chương)
  Future<List<LessonModel>> getLessonsByModule(int moduleId) async {
    try {
      final response = await _apiClient.dio.get(
        // Gọi API của Student
        ApiConfig.studentLessons,
        queryParameters: {'moduleId': moduleId.toString()},
      );
      print('Response data: ${response.data}');
      return (response.data as List)
          .map((e) => LessonModel.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi tải bài học');
    }
  }
}
