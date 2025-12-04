import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mobile/data/models/quiz_models.dart';
import 'package:mobile/domain/repositories/admin/admin_quiz_repository.dart';
import 'package:mobile/utils/toast_helper.dart';

class ManageQuizViewModel extends ChangeNotifier {
  final AdminQuizRepository _repository;

  ManageQuizViewModel(this._repository);

  List<QuizListModel> _quizzes = [];
  bool _isLoading = false;
  String? _error;

  int _currentPage = 1;
  final int _pageSize = 5;
  int _totalCount = 0;
  int _totalPages = 0;
  String? _searchQuery;
  bool _showDeleted = false;

  // Getters
  List<QuizListModel> get quizzes => _quizzes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalCount => _totalCount;
  String? get searchQuery => _searchQuery;
  bool get showDeleted => _showDeleted;

  void toggleShowDeleted(String courseId) {
    _showDeleted = !_showDeleted;
    fetchQuizzes(courseId, refresh: true);
  }

  Future<void> fetchQuizzes(String courseId, {bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.getQuizzes(
        courseId: courseId,
        page: _currentPage,
        limit: _pageSize,
        search: _searchQuery,
        returnDeleted: _showDeleted,
      );
      _quizzes = result['quizzes'];
      _totalCount = result['totalCount'];
      _totalPages = (_totalCount / _pageSize).ceil();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _quizzes = [];
      ToastHelper.showError(_error!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> applySearch(String courseId, String query) async {
    _searchQuery = query.isEmpty ? null : query;
    _currentPage = 1;
    await fetchQuizzes(courseId);
  }

  Future<void> goToPage(String courseId, int page) async {
    if (page < 1 || (page > _totalPages && _totalPages > 0)) return;
    _currentPage = page;
    await fetchQuizzes(courseId);
  }

  Future<bool> createQuiz({
    required String courseId,
    required String title,
    String? description,
    required int timeLimitMinutes,
    required PlatformFile platformFile,
    required String skillType,
    String? readingPassage,
  }) async {
    _isLoading =
        true; // Use local loading or reuse main loading? Reuse main for simplicity or add specific loading
    // Actually, dialog usually handles its own loading or blocks UI.
    // But here we can just return future and let dialog handle loading state.
    // However, to keep consistent with previous service, let's just use try-catch here and return bool.
    // The dialog in previous implementation used service state.
    // Let's stick to returning bool and let dialog handle its own loading state if possible,
    // OR expose a specific creating state.
    // For now, let's just return bool and let the caller handle UI loading if they want,
    // BUT the previous implementation in service set _isLoadingDetail.
    // I will just return bool and let the dialog manage its loading state (which it already does in my plan).

    try {
      await _repository.createQuiz(
        courseId: courseId,
        title: title,
        description: description,
        timeLimitMinutes: timeLimitMinutes,
        platformFile: platformFile,
        skillType: skillType,
        readingPassage: readingPassage,
      );

      ToastHelper.showSuccess('Tạo bài tập thành công');

      if (_showDeleted) _showDeleted = false;
      _currentPage = 1;
      _searchQuery = null;
      await fetchQuizzes(courseId);

      return true;
    } catch (e) {
      final errorMsg = e.toString().replaceFirst('Exception: ', '');
      ToastHelper.showError('Tạo thất bại: $errorMsg');
      return false;
    }
  }

  Future<void> deleteQuiz(String courseId, String quizId) async {
    try {
      await _repository.deleteQuiz(courseId, quizId);
      ToastHelper.showSuccess('Đã chuyển bài tập vào thùng rác');
      await fetchQuizzes(courseId);
    } catch (e) {
      final errorMsg = e.toString().replaceFirst('Exception: ', '');
      ToastHelper.showError(errorMsg);
    }
  }

  Future<void> restoreQuiz(String courseId, String quizId) async {
    try {
      await _repository.restoreQuiz(courseId, quizId);
      ToastHelper.showSuccess('Khôi phục bài tập thành công');
      await fetchQuizzes(courseId);
    } catch (e) {
      final errorMsg = e.toString().replaceFirst('Exception: ', '');
      ToastHelper.showError('Khôi phục thất bại: $errorMsg');
    }
  }
}
