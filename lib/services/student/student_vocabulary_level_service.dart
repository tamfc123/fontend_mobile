// file: services/student/student_vocabulary_level_service.dart

import 'package:flutter/material.dart';
import 'package:mobile/data/models/vocabulary_levels_model.dart';
import 'package:mobile/domain/repositories/student_vocabulary_level_repository.dart';
import 'package:mobile/utils/toast_helper.dart';

class StudentVocabularyLevelService extends ChangeNotifier {
  final StudentVocabularyLevelRepository _levelRepository;
  StudentVocabularyLevelService(this._levelRepository);

  VocabularyLevelsModel? _levelsData;
  bool _isLoading = false;
  String? _error;

  // Getters cho UI
  VocabularyLevelsModel? get levelsData => _levelsData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Hàm để UI gọi khi vào màn hình
  Future<void> fetchLevels() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _levelsData = await _levelRepository.getVocabularyLevels();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      ToastHelper.showError(_error!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Xóa cache khi người dùng log out
  void clear() {
    _levelsData = null;
    notifyListeners();
  }
}
