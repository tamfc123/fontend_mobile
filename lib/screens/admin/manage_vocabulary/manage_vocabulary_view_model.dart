import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile/data/models/vocabulary_model.dart';
import 'package:mobile/data/models/paged_result_model.dart';
import 'package:mobile/domain/repositories/admin/admin_vocabulary_repository.dart';
import 'package:mobile/utils/toast_helper.dart';

class ManageVocabularyViewModel extends ChangeNotifier {
  final AdminVocabularyRepository _vocabRepository;
  ManageVocabularyViewModel(this._vocabRepository);

  List<VocabularyModel> _vocabularies = [];
  PagedResultModel<VocabularyModel>? _pagedResult;

  bool _isLoading = false;
  String? _currentSearchQuery;
  bool _showDeleted = false;

  List<VocabularyModel> get vocabularies => _vocabularies;
  bool get isLoading => _isLoading;
  bool get showDeleted => _showDeleted;

  int get totalCount => _pagedResult?.totalCount ?? 0;
  int get totalPages => _pagedResult?.totalPages ?? 0;
  int get currentPage => _pagedResult?.pageNumber ?? 1;
  String? get currentSearchQuery => _currentSearchQuery;

  void toggleShowDeleted(String lessonId) {
    _showDeleted = !_showDeleted;
    fetchVocabularies(
      lessonId: lessonId,
      pageNumber: 1,
      searchQuery: _currentSearchQuery,
    );
  }

  Future<void> fetchVocabularies({
    required String lessonId,
    int pageNumber = 1,
    String? searchQuery,
  }) async {
    _isLoading = true;
    _currentSearchQuery = searchQuery;
    notifyListeners();

    try {
      final result = await _vocabRepository.getPaginatedVocabularies(
        lessonId: lessonId,
        pageNumber: pageNumber,
        pageSize: 5,
        searchQuery: searchQuery,
        returnDeleted: _showDeleted,
      );

      _vocabularies = result.items;
      _pagedResult = result;
    } catch (e) {
      ToastHelper.showError(e.toString().replaceFirst('Exception: ', ''));
      _vocabularies = [];
      _pagedResult = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addVocabulary(VocabularyModifyModel vocab) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _vocabRepository.createVocabulary(vocab);
      ToastHelper.showSuccess('Thêm từ vựng thành công');
      if (_showDeleted) _showDeleted = false;
      await fetchVocabularies(
        lessonId: vocab.lessonId,
        pageNumber: 1,
        searchQuery: _currentSearchQuery,
      );
      return true;
    } catch (e) {
      ToastHelper.showError(
        'Thêm thất bại: ${e.toString().replaceFirst('Exception: ', '')}',
      );
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateVocabulary(String id, VocabularyModifyModel vocab) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _vocabRepository.updateVocabulary(id, vocab);
      ToastHelper.showSuccess('Cập nhật từ vựng thành công');
      await fetchVocabularies(
        lessonId: vocab.lessonId,
        pageNumber: currentPage,
        searchQuery: _currentSearchQuery,
      );
      return true;
    } catch (e) {
      ToastHelper.showError(
        'Cập nhật thất bại: ${e.toString().replaceFirst('Exception: ', '')}',
      );
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteVocabulary(String id, String lessonId) async {
    try {
      await _vocabRepository.deleteVocabulary(id);
      ToastHelper.showSuccess('Đã chuyển vào thùng rác');
      await fetchVocabularies(
        lessonId: lessonId,
        pageNumber: 1,
        searchQuery: _currentSearchQuery,
      );
      return true;
    } catch (e) {
      ToastHelper.showError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  Future<bool> restoreVocabulary(String id, String lessonId) async {
    try {
      await _vocabRepository.restoreVocabulary(id);
      ToastHelper.showSuccess('Khôi phục từ vựng thành công');

      await fetchVocabularies(
        lessonId: lessonId,
        pageNumber: currentPage,
        searchQuery: _currentSearchQuery,
      );
      return true;
    } catch (e) {
      ToastHelper.showError(
        'Khôi phục thất bại: ${e.toString().replaceFirst('Exception: ', '')}',
      );
      return false;
    }
  }
}
