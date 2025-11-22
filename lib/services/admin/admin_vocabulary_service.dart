import 'package:flutter/material.dart';
import 'package:mobile/data/models/vocabulary_model.dart';
// ✅ 1. Import PagedResultModel
import 'package:mobile/data/models/paged_result_model.dart';
import 'package:mobile/domain/repositories/admin_vocabulary_repository.dart';
import 'package:mobile/utils/toast_helper.dart';

class AdminVocabularyService extends ChangeNotifier {
  final AdminVocabularyRepository _vocabRepository;
  AdminVocabularyService(this._vocabRepository);

  // ✅ 2. NÂNG CẤP STATE
  List<VocabularyModel> _vocabularies = [];
  PagedResultModel<VocabularyModel>? _pagedResult;

  bool _isLoading = false;
  String? _errorMessage;
  String? _currentSearchQuery;

  // ✅ 3. NÂNG CẤP GETTERS
  List<VocabularyModel> get vocabularies => _vocabularies;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get totalCount => _pagedResult?.totalCount ?? 0;
  int get totalPages => _pagedResult?.totalPages ?? 0;
  int get currentPage => _pagedResult?.pageNumber ?? 1;
  bool get hasNextPage => _pagedResult?.hasNextPage ?? false;
  bool get hasPreviousPage => _pagedResult?.hasPreviousPage ?? false;
  String? get currentSearchQuery => _currentSearchQuery;

  // ✅ 4. SỬA HÀM FETCH
  Future<void> fetchVocabularies({
    required String lessonId,
    int pageNumber = 1,
    String? searchQuery,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    _currentSearchQuery = searchQuery;

    try {
      final result = await _vocabRepository.getPaginatedVocabularies(
        lessonId: lessonId,
        pageNumber: pageNumber,
        pageSize: 5,
        searchQuery: searchQuery,
      );

      _vocabularies = result.items;
      _pagedResult = result;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      ToastHelper.showError(_errorMessage!);
      _vocabularies = [];
      _pagedResult = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addVocabulary(VocabularyModifyModel vocab) async {
    try {
      await _vocabRepository.createVocabulary(vocab);
      ToastHelper.showSuccess('Thêm từ vựng thành công');
      await fetchVocabularies(
        lessonId: vocab.lessonId,
        pageNumber: 1,
        searchQuery: _currentSearchQuery,
      );
      return true;
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      ToastHelper.showError('Thêm thất bại: $errorMessage');
      return false;
    }
  }

  Future<bool> updateVocabulary(String id, VocabularyModifyModel vocab) async {
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
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      ToastHelper.showError('Cập nhật thất bại: $errorMessage');
      return false;
    }
  }

  Future<bool> deleteVocabulary(String id, String lessonId) async {
    try {
      await _vocabRepository.deleteVocabulary(id);
      ToastHelper.showSuccess('Xóa từ vựng thành công');
      await fetchVocabularies(
        lessonId: lessonId,
        pageNumber: 1,
        searchQuery: _currentSearchQuery,
      );
      return true;
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      ToastHelper.showError(errorMessage);
      return false;
    }
  }
}
