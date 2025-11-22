import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/constants/api_config.dart';
import 'package:mobile/data/models/quiz_models.dart';

class AdminQuizRepository {
  final ApiClient _apiClient;

  AdminQuizRepository(this._apiClient);

  Future<Map<String, dynamic>> getQuizzes({
    required String courseId,
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConfig.adminCourseQuizzes(courseId),
        queryParameters: {
          'pageNumber': page, // Khớp với DTO backend AdminQuizParams
          'pageSize': limit, // Khớp với DTO backend AdminQuizParams
          'searchQuery': search, // Khớp với DTO backend AdminQuizParams
        },
      );

      // Backend trả về PagedResultDTO: { "items": [...], "totalCount": 100, ... }
      final data = response.data;

      final List<dynamic> itemsJson = data['items'] ?? [];
      final List<QuizListModel> quizzes =
          itemsJson.map((e) => QuizListModel.fromJson(e)).toList();

      return {'quizzes': quizzes, 'totalCount': data['totalCount'] ?? 0};
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Lỗi khi tải danh sách bài tập',
      );
    }
  }

  // ✅ 2. Lấy chi tiết Quiz
  Future<QuizDetailModel> getQuizDetails(String courseId, String quizId) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConfig.adminCourseQuizById(courseId, quizId),
      );
      return QuizDetailModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Lỗi khi tải chi tiết bài tập',
      );
    }
  }

  // ✅ 3. Xóa Quiz
  Future<void> deleteQuiz(String courseId, String quizId) async {
    try {
      await _apiClient.dio.delete(
        ApiConfig.adminCourseQuizById(courseId, quizId),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi khi xóa bài tập');
    }
  }

  // ✅ 4. Xóa câu hỏi lẻ (Tính năng mới)
  Future<void> deleteQuestion(String courseId, String questionId) async {
    try {
      await _apiClient.dio.delete(
        ApiConfig.adminDeleteQuestion(courseId, questionId),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi khi xóa câu hỏi');
    }
  }

  // ✅ 5. Tạo Quiz mới (Upload Excel)
  Future<void> createQuiz({
    required String courseId, // Thay classId bằng courseId
    required String title,
    String? description,
    required int timeLimitMinutes,
    required PlatformFile platformFile,
    required String skillType,
    String? readingPassage,
    String? mediaUrl, // 🟢 Thêm mới: Link file nghe cho Listening
  }) async {
    try {
      // Tạo Map dữ liệu cơ bản
      final Map<String, dynamic> mapData = {
        'Title': title,
        'Description': description ?? '',
        'TimeLimitMinutes': timeLimitMinutes,
        'SkillType': skillType,
        'ReadingPassage': readingPassage ?? '',
        'MediaUrl': mediaUrl ?? '', // Gửi lên backend
      };

      // Xử lý File (Hỗ trợ cả Web và Mobile)
      MultipartFile multipartFile;
      if (platformFile.bytes != null) {
        // Dùng cho Web hoặc khi file đã load vào RAM
        multipartFile = MultipartFile.fromBytes(
          platformFile.bytes!,
          filename: platformFile.name,
        );
      } else {
        // Dùng cho Mobile (lấy theo đường dẫn file để tiết kiệm RAM)
        multipartFile = await MultipartFile.fromFile(
          platformFile.path!,
          filename: platformFile.name,
        );
      }

      // Đóng gói vào FormData
      FormData formData = FormData.fromMap({...mapData, 'File': multipartFile});

      await _apiClient.dio.post(
        ApiConfig.adminCourseQuizzes(courseId),
        data: formData,
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi khi tạo bài tập');
    }
  }
}
