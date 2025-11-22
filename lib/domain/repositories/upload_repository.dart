import 'dart:typed_data'; // Cho Uint8List
import 'package:dio/dio.dart'; // Cho Dio, FormData, MultipartFile
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/constants/api_config.dart';
import 'package:mobile/data/models/media_file_model.dart';
import 'package:mobile/data/models/upload_response_model.dart';

class UploadRepository {
  final ApiClient _apiClient;
  UploadRepository(this._apiClient);

  /// Trả về UploadResponse chứa url và publicId
  Future<UploadResponse?> uploadFileWeb(
    Uint8List bytes,
    String fileName,
  ) async {
    try {
      FormData formData = FormData.fromMap({
        "file": MultipartFile.fromBytes(bytes, filename: fileName),
      });
      final response = await _apiClient.dio.post(
        ApiConfig.uploadContentImage,
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        Map<String, dynamic>? payload;
        if (data is Map<String, dynamic>) {
          payload = data;
        } else if (data is List &&
            data.isNotEmpty &&
            data[0] is Map<String, dynamic>) {
          payload = Map<String, dynamic>.from(data[0]);
        } else {
          throw Exception('Không thể xử lý phản hồi upload từ server.');
        }

        return UploadResponse.fromJson(payload);
      } else {
        throw Exception(
          "Upload thành công nhưng server trả về status ${response.statusCode}",
        );
      }
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data?['message'] ?? e.message ?? "Upload thất bại";
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception("Có lỗi không xác định xảy ra khi upload file.");
    }
  }

  Future<UploadResponse?> uploadAudioFileWeb(
    Uint8List bytes,
    String fileName,
  ) async {
    try {
      FormData formData = FormData.fromMap({
        "file": MultipartFile.fromBytes(bytes, filename: fileName),
      });
      final response = await _apiClient.dio.post(
        ApiConfig.uploadRawFile, // ⬅️ Gọi API mới
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return UploadResponse.fromJson(response.data);
      } else {
        throw Exception(
          "Upload thành công nhưng server trả về status ${response.statusCode}",
        );
      }
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data?['message'] ?? e.message ?? "Upload thất bại";
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception("Có lỗi không xác định xảy ra khi upload file.");
    }
  }

  // ✅ HÀM MỚI (Dùng cho Giáo viên upload file nghe)
  Future<UploadResponse?> uploadTeacherAudio(
    Uint8List bytes,
    String fileName,
  ) async {
    try {
      FormData formData = FormData.fromMap({
        // Tên "file" phải khớp với [FromForm] IFormFile file
        "file": MultipartFile.fromBytes(bytes, filename: fileName),
      });

      final response = await _apiClient.dio.post(
        ApiConfig.uploadAudio, // ⬅️ Gọi API mới
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // API này trả về JSON object, nên FromJson là đúng
        return UploadResponse.fromJson(response.data);
      } else {
        throw Exception(
          "Upload thành công nhưng server trả về status ${response.statusCode}",
        );
      }
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data?['message'] ?? e.message ?? "Upload thất bại";
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception("Có lỗi không xác định xảy ra khi upload file.");
    }
  }

  Future<List<MediaFileModel>> getMyMedia() async {
    try {
      final response = await _apiClient.dio.get(
        ApiConfig.teacherGetMyMedia, // GET /api/my-media
      );

      // API trả về một List<dynamic>
      final List<dynamic> data = response.data as List;

      // Map list đó sang List<MediaFileModel>
      return data.map((json) => MediaFileModel.fromJson(json)).toList();
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data?['message'] ??
          e.message ??
          "Tải danh sách media thất bại";
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception("Có lỗi không xác định xảy ra khi tải media.");
    }
  }

  Future<void> deleteMediaFile(String id) async {
    try {
      await _apiClient.dio.delete(
        ApiConfig.teacherDeleteMedia(id), // DELETE /api/delete-media/{id}
      );
      // Không cần trả về gì nếu thành công (void)
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data?['message'] ?? e.message ?? "Xóa file thất bại";
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception("Có lỗi không xác định xảy ra khi xóa file.");
    }
  }
}
