import 'package:flutter/material.dart';
import 'package:mobile/data/models/module_details_model.dart';
import 'package:mobile/domain/repositories/student/student_vocabulary_lesson_repository.dart';
import 'package:mobile/utils/toast_helper.dart';

class StudentVocabularyLessonViewModel extends ChangeNotifier {
  final StudentVocabularyLessonRepository _repository;

  StudentVocabularyLessonViewModel(this._repository);

  ModuleDetailsModel? _lessonData;
  bool _isLoading = false;
  String? _error;

  ModuleDetailsModel? get lessonData => _lessonData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadLessons(String moduleId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _lessonData = await _repository.getModuleLessons(moduleId);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      ToastHelper.showError(_error!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _lessonData = null;
    notifyListeners();
  }
}
