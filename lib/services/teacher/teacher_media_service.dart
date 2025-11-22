import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile/data/models/upload_response_model.dart';
import 'package:mobile/domain/repositories/upload_repository.dart';
import 'package:mobile/utils/toast_helper.dart';
import 'package:mobile/data/models/media_file_model.dart';

class TeacherMediaService extends ChangeNotifier {
  final UploadRepository _repository;
  TeacherMediaService(this._repository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  List<MediaFileModel> _mediaFiles = [];
  List<MediaFileModel> get mediaFiles => _mediaFiles;

  Future<void> fetchMyMedia() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Gọi repository
      _mediaFiles = await _repository.getMyMedia();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      ToastHelper.showError(_error!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> uploadAudioFile(PlatformFile file) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final Uint8List? fileBytes = file.bytes;
      if (fileBytes == null) {
        throw Exception("Không thể đọc được file.");
      }

      final UploadResponse? response = await _repository.uploadTeacherAudio(
        fileBytes,
        file.name,
      );

      if (response != null && response.url != null) {
        ToastHelper.showSuccess('Upload thành công!');
        await fetchMyMedia();
      } else {
        throw Exception("Upload thất bại, không nhận được URL.");
      }
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      ToastHelper.showError(_error!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteMediaFile(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Gọi Repository để xóa
      await _repository.deleteMediaFile(id);
      _mediaFiles.removeWhere((file) => file.id == id);

      ToastHelper.showSuccess('Xóa file thành công!');
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      ToastHelper.showError(_error!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
