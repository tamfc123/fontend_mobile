import 'package:dio/dio.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/constants/api_config.dart';
import 'package:mobile/data/models/student_in_class_model.dart';
import 'package:mobile/data/models/teacher_class_model.dart';

class TeacherClassRepository {
  final ApiClient _apiClient;
  TeacherClassRepository(this._apiClient);

  // Lấy danh sách lớp của giảng viên
  Future<List<TeacherClassModel>> getTeacherClasses({
    String? search,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      // ✅ CẬP NHẬT: Thêm 'queryParameters' vào yêu cầu GET
      // Dio sẽ tự động xử lý:
      // 1. Thêm các tham số vào URL (ví dụ: /classes?search=abc&sortBy=name)
      // 2. Bỏ qua bất kỳ tham số nào có giá trị null.
      final response = await _apiClient.dio.get(
        ApiConfig.teacherClasses,
        queryParameters: {
          'search': search,
          'sortBy': sortBy,
          'sortOrder': sortOrder,
        },
      );

      return (response.data as List)
          .map((e) => TeacherClassModel.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Lỗi khi tải danh sách lớp',
      );
    }
  }

  // Cập nhật tên lớp
  // Dio sẽ tự ném lỗi nếu status != 200
  // Chúng ta không cần trả về Map<String, dynamic> nữa, chỉ cần `Future<void>`
  Future<void> updateTeacherClass(int id, String name) async {
    try {
      await _apiClient.dio.put(
        ApiConfig.teacherClassById(id),
        data: {'name': name},
      );
      // Nếu không có lỗi, nghĩa là đã thành công
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Có lỗi xảy ra');
    }
  }

  /// Lấy danh sách sinh viên (đã duyệt) trong một lớp cụ thể.
  Future<List<StudentInClassModel>> getStudentsInClass(int classId) async {
    try {
      // Gọi API đã config ở Task 2
      final response = await _apiClient.dio.get(
        ApiConfig.getStudentsInClass(classId),
      );

      // Parse kết quả trả về (List<dynamic>) sang List<StudentInClassModel>
      return (response.data as List)
          .map((e) => StudentInClassModel.fromJson(e))
          .toList();
    } on DioException catch (e) {
      // Ném lỗi để Service/Provider có thể bắt được
      throw Exception(
        e.response?.data['message'] ?? 'Lỗi khi tải danh sách sinh viên',
      );
    }
  }
}
