import 'package:flutter/material.dart';
import 'package:mobile/data/models/vocabulary_modules_model.dart';
import 'package:mobile/domain/repositories/student/student_vocabulary_module_repository.dart';
import 'package:mobile/utils/toast_helper.dart';

class StudentVocabularyModuleViewModel extends ChangeNotifier {
  final StudentVocabularyModuleRepository _repository;

  StudentVocabularyModuleViewModel(this._repository);

  VocabularyModulesModel? _modulesData;
  bool _isLoading = false;
  String? _error;

  VocabularyModulesModel? get modulesData => _modulesData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadModules(String levelId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _modulesData = await _repository.getVocabularyModules(levelId);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      ToastHelper.showError(_error!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _modulesData = null;
    notifyListeners();
  }
}
