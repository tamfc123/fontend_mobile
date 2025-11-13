// file: services/student/student_lesson_service.dart

import 'package:flutter/material.dart';
import 'package:mobile/data/models/lesson_model.dart';
import 'package:mobile/domain/repositories/student_lesson_repository.dart';
import 'package:mobile/utils/toast_helper.dart';

class StudentLessonService extends ChangeNotifier {
  final StudentLessonRepository _lessonRepository;
  StudentLessonService(this._lessonRepository);

  // KEY: moduleId → VALUE: dữ liệu riêng
  final Map<int, List<LessonModel>> _lessonsMap = {};
  final Map<int, bool> _isLoadingMap = {};
  final Map<int, String?> _errorMap = {};

  // Lấy dữ liệu theo moduleId
  List<LessonModel> getLessons(int moduleId) => _lessonsMap[moduleId] ?? [];
  bool isLoading(int moduleId) => _isLoadingMap[moduleId] ?? false;
  String? error(int moduleId) => _errorMap[moduleId];

  Future<void> fetchLessons(int moduleId) async {
    // Nếu đang tải → bỏ qua
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

  // Xóa toàn bộ khi rời màn hình
  void clear() {
    _lessonsMap.clear();
    _isLoadingMap.clear();
    _errorMap.clear();
    notifyListeners();
  }
}
