import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/constants/api_config.dart';
import 'package:mobile/data/models/course_model.dart';
import 'package:mobile/data/models/student_class_model.dart';

class StudentCourseRepository {
  final ApiClient _apiClient;
  StudentCourseRepository(this._apiClient);

  // Lấy danh sách khóa học
  Future<List<CourseModel>> getAvailableCourses() async {
    try {
      final response = await _apiClient.dio.get(
        ApiConfig.studentAvailableCourses, // /api/StudentCourses/courses
      );

      final data = response.data;
      if (data is List) {
        return data.map((e) => CourseModel.fromJson(e)).toList();
      }
      if (data is Map && data['data'] != null) {
        return (data['data'] as List)
            .map((e) => CourseModel.fromJson(e))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Không thể tải khóa học');
    }
  }

  // ✅ CẬP NHẬT: Gọi đúng API api/StudentCourses/{id}/classes
  Future<List<StudentClassModel>> getClassesByCourse(String courseId) async {
    try {
      // Sử dụng helper trong ApiConfig để tạo URL: /api/StudentCourses/123/classes
      final response = await _apiClient.dio.get(
        ApiConfig.studentClassesByCourse(courseId),
      );

      // API này trả về List<AvailableClassDTO>
      final data = response.data as List;

      // Model đã có logic map isLocked từ JSON rồi
      return data.map((e) => StudentClassModel.fromJson(e)).toList();
    } on DioException catch (e) {
      debugPrint(e.toString());
      throw Exception(e.response?.data['message'] ?? 'Không thể tải lớp học');
    }
  }
}
