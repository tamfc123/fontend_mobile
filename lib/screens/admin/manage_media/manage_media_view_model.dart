import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mobile/data/models/media_file_model.dart';
import 'package:mobile/domain/repositories/admin/admin_media_repository.dart';
import 'package:mobile/utils/toast_helper.dart';

class ManageMediaViewModel extends ChangeNotifier {
  final AdminMediaRepository _repository;

  ManageMediaViewModel(this._repository);

  List<MediaFileModel> _files = [];
  bool _isLoading = false;

  // Pagination
  int _currentPage = 1;
  final int _pageSize = 5;
  int _totalCount = 0;

  List<MediaFileModel> get files => _files;
  bool get isLoading => _isLoading;
  int get currentPage => _currentPage;
  int get totalCount => _totalCount;
  int get totalPages => (_totalCount / _pageSize).ceil();

  Future<void> fetchMedia({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _files.clear();
    }

    _isLoading = true;
    notifyListeners();

    try {
      final result = await _repository.getAllMedia(
        page: _currentPage,
        limit: _pageSize,
      );

      _files = result['data'];
      _totalCount = result['total'];
    } catch (e) {
      ToastHelper.showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> goToPage(int page) async {
    if (page < 1 || (page > totalPages && totalPages > 0)) return;
    _currentPage = page;
    await fetchMedia();
  }

  Future<bool> uploadAudio(PlatformFile file) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.uploadAudio(file);
      ToastHelper.showSuccess('Tải lên thành công!');
      await fetchMedia(refresh: true);
      return true;
    } catch (e) {
      ToastHelper.showError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteMedia(String id) async {
    try {
      await _repository.deleteMedia(id);
      ToastHelper.showSuccess('Đã xóa file!');

      _files.removeWhere((f) => f.id == id);
      _totalCount--;

      if (_files.isEmpty && _currentPage > 1) {
        goToPage(_currentPage - 1);
      } else {
        notifyListeners();
      }
    } catch (e) {
      ToastHelper.showError(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}
