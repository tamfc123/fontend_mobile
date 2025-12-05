import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/constants/api_config.dart';
import 'package:mobile/data/models/media_file_model.dart';
import 'package:http_parser/http_parser.dart';

class AdminMediaRepository {
  final ApiClient _apiClient;

  AdminMediaRepository(this._apiClient);

  Future<MediaFileModel> uploadAudio(PlatformFile platformFile) async {
    try {
      // Xác định ContentType (MP3 hoặc WAV)
      MediaType? contentType;
      final ext = platformFile.extension?.toLowerCase() ?? '';
      if (ext == 'mp3') {
        contentType = MediaType('audio', 'mpeg');
      } else if (ext == 'wav') {
        contentType = MediaType('audio', 'wav');
      } else if (ext == 'm4a') {
        contentType = MediaType('audio', 'mp4');
      }

      MultipartFile multipartFile;
      if (platformFile.bytes != null) {
        // Web
        multipartFile = MultipartFile.fromBytes(
          platformFile.bytes!,
          filename: platformFile.name,
          contentType: contentType,
        );
      } else {
        // Mobile
        multipartFile = await MultipartFile.fromFile(
          platformFile.path!,
          filename: platformFile.name,
          contentType: contentType,
        );
      }

      FormData formData = FormData.fromMap({'File': multipartFile});

      final response = await _apiClient.dio.post(
        ApiConfig.adminUploadAudio,
        data: formData,
      );

      // Lưu ý: Backend upload xong trả về { url, publicId... } nhưng CHƯA CÓ ID của DB.
      // Nên ta tạm để ID rỗng. Sau khi upload xong, UI nên gọi fetch lại list để có ID đầy đủ.
      return MediaFileModel(
        id: '',
        fileName: response.data['fileName'],
        url: response.data['url'],
        publicId: response.data['publicId'],
        createdAt: DateTime.now(),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi khi tải file lên');
    }
  }

  Future<Map<String, dynamic>> getAllMedia({
    int page = 1,
    int limit = 5,
    String searchQuery = '',
  }) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConfig.adminMedia,
        queryParameters: {
          'page': page,
          'limit': limit,
          'searchQuery': searchQuery,
        },
      );

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
