import 'package:flutter/material.dart';
import 'package:mobile/data/models/lesson_model.dart';
import 'package:mobile/data/models/paged_result_model.dart';
import 'package:mobile/domain/repositories/admin_lesson_repository.dart';
import 'package:mobile/utils/toast_helper.dart';

class AdminLessonService extends ChangeNotifier {
  final AdminLessonRepository _lessonRepository;
  AdminLessonService(this._lessonRepository);

  List<LessonModel> _lessons = [];
  PagedResultModel<LessonModel>? _pagedResult;

  bool _isLoading = false;
  String? _errorMessage;
  String? _currentSearchQuery;

  List<LessonModel> get lessons => _lessons;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get totalCount => _pagedResult?.totalCount ?? 0;
  int get totalPages => _pagedResult?.totalPages ?? 0;
  int get currentPage => _pagedResult?.pageNumber ?? 1;
  bool get hasNextPage => _pagedResult?.hasNextPage ?? false;
  bool get hasPreviousPage => _pagedResult?.hasPreviousPage ?? false;
  String? get currentSearchQuery => _currentSearchQuery;

  Future<void> fetchLessons({
    required String moduleId,
    int pageNumber = 1,
    String? searchQuery,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    _currentSearchQuery = searchQuery;

    try {
      final result = await _lessonRepository.getPaginatedLessons(
        moduleId: moduleId,
        pageNumber: pageNumber,
        pageSize: 5,
        searchQuery: searchQuery,
      );

      _lessons = result.items;
      _pagedResult = result;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      ToastHelper.showError(_errorMessage!);
      _lessons = [];
      _pagedResult = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<LessonModel> fetchLessonById(String lessonId) async {
    try {
      return await _lessonRepository.getLessonById(lessonId);
    } catch (e) {
      ToastHelper.showError(
        'Không thể tải nội dung bài học: ${e.toString().replaceFirst('Exception: ', '')}',
      );
      rethrow;
    }
  }

  // ADD (để refresh đúng)
  Future<bool> addLesson(LessonModifyModel lesson) async {
    try {
      await _lessonRepository.createLesson(lesson);
      ToastHelper.showSuccess('Thêm bài học thành công');
      await fetchLessons(
        moduleId: lesson.moduleId,
        pageNumber: 1,
        searchQuery: _currentSearchQuery,
      );
      return true;
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      ToastHelper.showError('Thêm thất bại: $errorMessage');
      return false;
    }
  }

  // UPDATE (để refresh đúng)
  Future<bool> updateLesson(String id, LessonModifyModel lesson) async {
    try {
      await _lessonRepository.updateLesson(id, lesson);
      ToastHelper.showSuccess('Cập nhật bài học thành công');
      await fetchLessons(
        moduleId: lesson.moduleId,
        pageNumber: currentPage, // Giữ nguyên trang
        searchQuery: _currentSearchQuery,
      );
      return true;
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      ToastHelper.showError('Cập nhật thất bại: $errorMessage');
      return false;
    }
  }

  // DELETE (để refresh đúng)
  Future<bool> deleteLesson(String id, String moduleId) async {
    try {
      await _lessonRepository.deleteLesson(id);
      ToastHelper.showSuccess('Xóa bài học thành công');
      await fetchLessons(
        moduleId: moduleId,
        pageNumber: 1,
        searchQuery: _currentSearchQuery,
      );
      return true;
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      ToastHelper.showError(errorMessage);
      return false;
    }
  }
}
