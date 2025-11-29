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
}
