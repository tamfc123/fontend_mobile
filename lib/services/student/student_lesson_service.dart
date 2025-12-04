import 'package:flutter/material.dart';
import 'package:mobile/data/models/lesson_model.dart';
import 'package:mobile/domain/repositories/student/student_lesson_repository.dart';
import 'package:mobile/utils/toast_helper.dart';

class StudentLessonService extends ChangeNotifier {
  final StudentLessonRepository _lessonRepository;
  StudentLessonService(this._lessonRepository);

  final Map<String, List<LessonModel>> _lessonsMap = {};
  final Map<String, bool> _isLoadingMap = {};
  final Map<String, String?> _errorMap = {};

  List<LessonModel> getLessons(String moduleId) => _lessonsMap[moduleId] ?? [];
  bool isLoading(String moduleId) => _isLoadingMap[moduleId] ?? false;
  String? error(String moduleId) => _errorMap[moduleId];

  Future<void> fetchLessons(String moduleId) async {
    if (_isLoadingMap[moduleId] == true) return;

    _isLoadingMap[moduleId] = true;
    _errorMap[moduleId] = null;
    notifyListeners();

    try {
      final lessons = await _lessonRepository.getLessonsByModule(moduleId);
      _lessonsMap[moduleId] = lessons;
    } catch (e) {
      _errorMap[moduleId] = e.toString().replaceFirst('Exception: ', '');
      ToastHelper.showError(_errorMap[moduleId]!);
      _lessonsMap[moduleId] = [];
    } finally {
      _isLoadingMap[moduleId] = false;
      notifyListeners();
    }
  }

  void clear() {
    _lessonsMap.clear();
    _isLoadingMap.clear();
    _errorMap.clear();
    notifyListeners();
  }
}
