import 'package:flutter/material.dart';
import 'package:mobile/data/models/vocabulary_model.dart';
import 'package:mobile/domain/repositories/admin_vocabulary_repository.dart';
import 'package:mobile/utils/toast_helper.dart';

class AdminVocabularyService extends ChangeNotifier {
  final AdminVocabularyRepository _vocabRepository;
  AdminVocabularyService(this._vocabRepository);

  List<VocabularyModel> _vocabularies = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<VocabularyModel> get vocabularies => _vocabularies;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Lấy danh sách Từ vựng theo lessonId
  Future<void> fetchVocabularies(int lessonId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _vocabularies = await _vocabRepository.getVocabulariesByLesson(lessonId);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      ToastHelper.showError(_errorMessage!);
      _vocabularies = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Thêm Từ vựng mới
  Future<bool> addVocabulary(VocabularyModifyModel vocab) async {
    try {
      await _vocabRepository.createVocabulary(vocab);
      ToastHelper.showSucess('Thêm từ vựng thành công');
      await fetchVocabularies(vocab.lessonId); // Tải lại danh sách
      return true;
    } catch (e) {
      ToastHelper.showError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  // Cập nhật Từ vựng
  Future<bool> updateVocabulary(int id, VocabularyModifyModel vocab) async {
    try {
      await _vocabRepository.updateVocabulary(id, vocab);
      ToastHelper.showSucess('Cập nhật từ vựng thành công');
      await fetchVocabularies(vocab.lessonId); // Tải lại danh sách
      return true;
    } catch (e) {
      ToastHelper.showError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  // Xóa Từ vựng
  Future<bool> deleteVocabulary(int id, int lessonId) async {
    try {
      await _vocabRepository.deleteVocabulary(id);
      ToastHelper.showSucess('Xóa từ vựng thành công');
      await fetchVocabularies(lessonId); // Tải lại danh sách
      return true;
    } catch (e) {
      ToastHelper.showError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }
}
