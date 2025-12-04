import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile/data/models/lesson_model.dart';
import 'package:mobile/domain/repositories/admin/admin_lesson_repository.dart';
import 'package:mobile/utils/toast_helper.dart';

class ManageLessonViewModel extends ChangeNotifier {
  final AdminLessonRepository _lessonRepository;

  ManageLessonViewModel(this._lessonRepository);

  List<LessonModel> _lessons = [];
  List<LessonModel> get lessons => _lessons;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _searchQuery;
  String? get searchQuery => _searchQuery;

  int _currentPage = 1;
  int get currentPage => _currentPage;

  int _totalPages = 1;
  int get totalPages => _totalPages;

  int _totalCount = 0;
  int get totalCount => _totalCount;

  final int _pageSize = 5;

  Future<void> fetchLessons({
    required String moduleId,
    int? pageNumber,
    String? searchQuery,
  }) async {
    _isLoading = true;
    if (pageNumber != null) _currentPage = pageNumber;
    if (searchQuery != null) _searchQuery = searchQuery;
    notifyListeners();

    try {
      final result = await _lessonRepository.getPaginatedLessons(
        moduleId: moduleId,
        pageNumber: _currentPage,
        pageSize: _pageSize,
        searchQuery: _searchQuery,
      );

      _lessons = result.items;
      _totalCount = result.totalCount;
      _totalPages = (_totalCount / _pageSize).ceil();
      if (_totalPages == 0) _totalPages = 1;
    } catch (e) {
      ToastHelper.showError('Lỗi tải danh sách bài học: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<LessonModel?> fetchLessonById(String lessonId) async {
    try {
      return await _lessonRepository.getLessonById(lessonId);
    } catch (e) {
      ToastHelper.showError('Lỗi tải chi tiết bài học: $e');
      return null;
    }
  }

  Future<void> applySearch(String moduleId, String query) async {
    if (_searchQuery == query) return;
    _searchQuery = query;
    _currentPage = 1;
    await fetchLessons(moduleId: moduleId);
  }

  Future<void> goToPage(String moduleId, int page) async {
    if (page < 1 || page > _totalPages || page == _currentPage) return;
    _currentPage = page;
    await fetchLessons(moduleId: moduleId);
  }

  Future<bool> createLesson(LessonModifyModel lesson) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _lessonRepository.createLesson(lesson);
      ToastHelper.showSuccess('Thêm bài học thành công');
      await fetchLessons(moduleId: lesson.moduleId);
      return true;
    } catch (e) {
      ToastHelper.showError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateLesson(String id, LessonModifyModel lesson) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _lessonRepository.updateLesson(id, lesson);
      ToastHelper.showSuccess('Cập nhật bài học thành công');
      await fetchLessons(moduleId: lesson.moduleId);
      return true;
    } catch (e) {
      ToastHelper.showError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteLesson(String id, String moduleId) async {
    try {
      await _lessonRepository.deleteLesson(id);
      ToastHelper.showSuccess('Xóa bài học thành công');
      // Nếu xóa item cuối cùng của trang, quay lại trang trước
      if (_lessons.length == 1 && _currentPage > 1) {
        _currentPage--;
      }
      await fetchLessons(moduleId: moduleId);
      return true;
    } catch (e) {
      ToastHelper.showError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }
}
