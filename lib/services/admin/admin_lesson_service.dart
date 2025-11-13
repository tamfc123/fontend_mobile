// file: services/admin/admin_lesson_service.dart
import 'package:flutter/material.dart';
import 'package:mobile/data/models/lesson_model.dart';
import 'package:mobile/domain/repositories/admin_lesson_repository.dart';
import 'package:mobile/utils/toast_helper.dart';

class AdminLessonService extends ChangeNotifier {
  final AdminLessonRepository _lessonRepository;
  AdminLessonService(this._lessonRepository);

  List<LessonModel> _lessons = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<LessonModel> get lessons => _lessons;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Lấy danh sách Lesson theo moduleId
  Future<void> fetchLessons(int moduleId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _lessons = await _lessonRepository.getLessonsByModule(moduleId);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      ToastHelper.showError(_errorMessage!);
      _lessons = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Thêm Lesson mới
  Future<bool> addLesson(LessonModifyModel lesson) async {
    try {
      await _lessonRepository.createLesson(lesson);
      ToastHelper.showSucess('Thêm bài học thành công');
      await fetchLessons(lesson.moduleId); // Tải lại danh sách
      return true;
    } catch (e) {
      ToastHelper.showError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  // Cập nhật Lesson
  Future<bool> updateLesson(int id, LessonModifyModel lesson) async {
    try {
      await _lessonRepository.updateLesson(id, lesson);
      ToastHelper.showSucess('Cập nhật bài học thành công');
      await fetchLessons(lesson.moduleId); // Tải lại danh sách
      return true;
    } catch (e) {
      ToastHelper.showError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  // Xóa Lesson
  Future<bool> deleteLesson(int id, int moduleId) async {
    try {
      await _lessonRepository.deleteLesson(id);
      ToastHelper.showSucess('Xóa bài học thành công');
      await fetchLessons(moduleId); // Tải lại danh sách
      return true;
    } catch (e) {
      ToastHelper.showError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }
}
