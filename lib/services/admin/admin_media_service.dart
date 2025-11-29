import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mobile/data/models/media_file_model.dart';
import 'package:mobile/domain/repositories/admin_media_repository.dart';
import 'package:mobile/utils/toast_helper.dart';

class AdminMediaService extends ChangeNotifier {
  final AdminMediaRepository _repository;

  AdminMediaService(this._repository);

  // --- STATE ---
  List<MediaFileModel> _files = [];
  bool _isLoading = false;
  String? _error;

  // Phân trang
  int _currentPage = 1;
  final int _pageSize = 20;
  int _totalCount = 0;

  // Getters
  List<MediaFileModel> get files => _files;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get totalCount => _totalCount;
  int get totalPages => (_totalCount / _pageSize).ceil();

  // ✅ 1. FETCH DATA
  Future<void> fetchMedia({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _files.clear();
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.getAllMedia(
        page: _currentPage,
        limit: _pageSize,
      );

      _files = result['data'];
      _totalCount = result['total'];
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      ToastHelper.showError(_error!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ 2. CHUYỂN TRANG
  Future<void> goToPage(int page) async {
    if (page < 1 || (page > totalPages && totalPages > 0)) return;
    _currentPage = page;
    await fetchMedia();
  }

  // ✅ 3. UPLOAD AUDIO
  Future<bool> uploadAudio(PlatformFile file) async {
    _isLoading = true; // Hiện loading toàn màn hình hoặc dialog
    notifyListeners();

    try {
      await _repository.uploadAudio(file);
      ToastHelper.showSuccess('Tải lên thành công!');

      // Refresh lại danh sách để thấy file mới nhất ở đầu
      await fetchMedia(refresh: true);
      return true;
    } catch (e) {
      String msg = e.toString().replaceFirst('Exception: ', '');
      ToastHelper.showError(msg);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ 4. DELETE MEDIA
  Future<void> deleteMedia(String id) async {
    try {
      await _repository.deleteMedia(id);
      ToastHelper.showSuccess('Đã xóa file!');

      // Xóa local để đỡ phải fetch lại (Optimistic update)
      _files.removeWhere((f) => f.id == id);
      _totalCount--; // Giảm tổng số

      // Nếu trang hiện tại bị xóa hết, có thể cần fetch lại trang trước
      if (_files.isEmpty && _currentPage > 1) {
        goToPage(_currentPage - 1);
      }
    } catch (e) {
      String msg = e.toString().replaceFirst('Exception: ', '');
      ToastHelper.showError(msg);
    } finally {
      notifyListeners();
    }
  }
}
