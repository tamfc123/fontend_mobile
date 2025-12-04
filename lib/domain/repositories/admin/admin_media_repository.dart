import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/constants/api_config.dart';
import 'package:mobile/data/models/media_file_model.dart';

class AdminMediaRepository {
  final ApiClient _apiClient;

  AdminMediaRepository(this._apiClient);

  // ✅ 1. UPLOAD AUDIO
  Future<MediaFileModel> uploadAudio(PlatformFile platformFile) async {
    try {
      // Xử lý file cho cả Web (bytes) và Mobile (path)
      MultipartFile multipartFile;
      if (platformFile.bytes != null) {
        multipartFile = MultipartFile.fromBytes(
          platformFile.bytes!,
          filename: platformFile.name,
        );
      } else {
        multipartFile = await MultipartFile.fromFile(
          platformFile.path!,
          filename: platformFile.name,
        );
      }

      FormData formData = FormData.fromMap({'File': multipartFile});

      final response = await _apiClient.dio.post(
        ApiConfig.adminUploadAudio,
        data: formData,
      );

      // Backend trả về thông tin file vừa upload, ta map sang Model luôn
      // Lưu ý: Backend trả về: { "url": "...", "publicId": "...", ... }
      // Ta có thể tạo model tạm hoặc trả về map, nhưng ở đây tôi return Model chuẩn
      // bằng cách fake ID (vì API upload trả về chưa có ID DB ngay, hoặc bạn sửa BE trả về full object)
      // Tạm thời return kết quả thô để Service xử lý hoặc gọi reload list.
      return MediaFileModel(
        id: '', // Chưa có ID từ DB trả về ở endpoint upload (nếu BE chưa sửa)
        fileName: response.data['fileName'],
        url: response.data['url'],
        publicId: response.data['publicId'],
        createdAt: DateTime.now(),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi khi tải file lên');
    }
  }

  // ✅ 2. GET ALL MEDIA (Có phân trang)
  Future<Map<String, dynamic>> getAllMedia({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConfig.adminGetAllMedia(page: page, limit: limit),
      );

      // Cấu trúc JSON trả về: { "data": [...], "meta": { "total": 100, ... } }
      final data = response.data;
      final List<dynamic> itemsJson = data['data'] ?? [];

      final List<MediaFileModel> files =
          itemsJson.map((e) => MediaFileModel.fromJson(e)).toList();

      final meta = data['meta'];

      return {'data': files, 'total': meta['total'] ?? 0};
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi tải danh sách media');
    }
  }

  // ✅ 3. DELETE MEDIA
  Future<void> deleteMedia(String id) async {
    try {
      await _apiClient.dio.delete(ApiConfig.adminDeleteMedia(id));
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi khi xóa file');
    }
  }
}
