import 'package:flutter/material.dart';
import 'package:mobile/data/models/vocabulary_levels_model.dart';
import 'package:mobile/domain/repositories/student/student_vocabulary_level_repository.dart';
import 'package:mobile/utils/toast_helper.dart';

class StudentVocabularyViewModel extends ChangeNotifier {
  final StudentVocabularyLevelRepository _repository;

  StudentVocabularyViewModel(this._repository);

  VocabularyLevelsModel? _vocabularyData;
  bool _isLoading = false;
  String? _error;

  VocabularyLevelsModel? get vocabularyData => _vocabularyData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadVocabularyLevels() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _vocabularyData = await _repository.getVocabularyLevels();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      ToastHelper.showError(_error!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _vocabularyData = null;
    notifyListeners();
  }
}
