import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mobile/data/models/quiz_models.dart';
import 'package:mobile/domain/repositories/admin_quiz_repository.dart';
import 'package:mobile/utils/toast_helper.dart';

class AdminQuizService extends ChangeNotifier {
  final AdminQuizRepository _quizRepository;
  AdminQuizService(this._quizRepository);

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

  QuizDetailModel? _selectedQuiz;
  bool _isLoadingDetail = false;
  String? _detailError;
  QuizDetailModel? get selectedQuiz => _selectedQuiz;
  bool get isLoadingDetail => _isLoadingDetail;
  String? get detailError => _detailError;

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
      final result = await _quizRepository.getQuizzes(
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

  Future<void> fetchQuizDetails(String courseId, String quizId) async {
    _isLoadingDetail = true;
    _detailError = null;
    _selectedQuiz = null;
    notifyListeners();

    try {
      _selectedQuiz = await _quizRepository.getQuizDetails(courseId, quizId);
    } catch (e) {
      _detailError = e.toString().replaceFirst('Exception: ', '');
      ToastHelper.showError(_detailError!);
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
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
    _isLoadingDetail = true;
    _detailError = null;
    notifyListeners();

    try {
      await _quizRepository.createQuiz(
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
      _detailError = e.toString().replaceFirst('Exception: ', '');
      ToastHelper.showError('Tạo thất bại: $_detailError');
      return false;
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  Future<void> deleteQuiz(String courseId, String quizId) async {
    try {
      await _quizRepository.deleteQuiz(courseId, quizId);
      ToastHelper.showSuccess('Đã chuyển bài tập vào thùng rác');
      await fetchQuizzes(courseId);
    } catch (e) {
      final errorMsg = e.toString().replaceFirst('Exception: ', '');
      debugPrint(errorMsg);
      ToastHelper.showError(errorMsg);
    } finally {
      notifyListeners();
    }
  }

  Future<void> restoreQuiz(String courseId, String quizId) async {
    try {
      await _quizRepository.restoreQuiz(courseId, quizId);
      ToastHelper.showSuccess('Khôi phục bài tập thành công');
      await fetchQuizzes(courseId);
    } catch (e) {
      final errorMsg = e.toString().replaceFirst('Exception: ', '');
      ToastHelper.showError('Khôi phục thất bại: $errorMsg');
    } finally {
      notifyListeners();
    }
  }

  Future<void> deleteQuestion(String courseId, String questionId) async {
    try {
      await _quizRepository.deleteQuestion(courseId, questionId);
      ToastHelper.showSuccess('Đã xóa câu hỏi');
      if (_selectedQuiz != null) {
        _selectedQuiz!.questions.removeWhere((q) => q.id == questionId);
        _selectedQuiz = _selectedQuiz!.copyWith();
      }
    } catch (e) {
      ToastHelper.showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      notifyListeners();
    }
  }
}
