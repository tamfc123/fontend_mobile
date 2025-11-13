import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile/data/models/upload_response_model.dart';
import 'package:mobile/domain/repositories/upload_repository.dart';
import 'package:mobile/utils/toast_helper.dart';
// ✅ 1. IMPORT MODEL MỚI (TỪ DATABASE)
import 'package:mobile/data/models/media_file_model.dart';

// ❌ 2. XÓA CLASS TẠM THỜI (UploadedMediaFile)
// class UploadedMediaFile { ... }

class TeacherMediaService extends ChangeNotifier {
  final UploadRepository _repository;
  TeacherMediaService(this._repository);

  // _isLoading dùng chung cho (fetch, upload, delete)
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // ✅ 3. THAY ĐỔI STATE: Dùng List<MediaFileModel>
  // Danh sách file media thật từ database
  List<MediaFileModel> _mediaFiles = [];
  List<MediaFileModel> get mediaFiles => _mediaFiles;

  // ✅ 4. THÊM HÀM MỚI: LẤY DANH SÁCH TỪ DATABASE
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

  // ✅ 5. CẬP NHẬT HÀM UPLOAD
  Future<void> uploadAudioFile(PlatformFile file) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final Uint8List? fileBytes = file.bytes;
      if (fileBytes == null) {
        throw Exception("Không thể đọc được file.");
      }

      // 1. Gọi Repository để upload (giữ nguyên)
      final UploadResponse? response = await _repository.uploadTeacherAudio(
        fileBytes,
        file.name,
      );

      if (response != null && response.url != null) {
        ToastHelper.showSucess('Upload thành công!');

        // 2. ✅ TẢI LẠI DANH SÁCH
        // Thay vì thêm vào list tạm, ta tải lại toàn bộ danh sách
        // để lấy đúng file (với ID) từ database.
        await fetchMyMedia();
      } else {
        throw Exception("Upload thất bại, không nhận được URL.");
      }
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      ToastHelper.showError(_error!);
    } finally {
      // fetchMyMedia() đã set isLoading = false,
      // nhưng chúng ta set lại ở đây để đảm bảo an toàn nếu fetch bị lỗi
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ 6. THÊM HÀM MỚI: XÓA FILE
  Future<void> deleteMediaFile(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Gọi Repository để xóa
      await _repository.deleteMediaFile(id);

      // 2. Xóa khỏi danh sách UI (cách tối ưu, không cần gọi lại API)
      _mediaFiles.removeWhere((file) => file.id == id);

      ToastHelper.showSucess('Xóa file thành công!');
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      ToastHelper.showError(_error!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
