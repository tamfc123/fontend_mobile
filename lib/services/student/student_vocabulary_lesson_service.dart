// lib/services/student/student_vocabulary_lesson_service.dart
import 'package:flutter/material.dart';
import 'package:mobile/data/models/module_details_model.dart';
import 'package:mobile/domain/repositories/student_vocabulary_lesson_repository.dart';
import 'package:mobile/utils/toast_helper.dart';

class StudentVocabularyLessonService extends ChangeNotifier {
  final StudentVocabularyLessonRepository _lessonRepository;
  StudentVocabularyLessonService(this._lessonRepository);

  ModuleDetailsModel? _lessonData;
  bool _isLoading = false;
  String? _error;

  ModuleDetailsModel? get lessonData => _lessonData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchLessons(int moduleId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _lessonData = await _lessonRepository.getModuleLessons(moduleId);
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
