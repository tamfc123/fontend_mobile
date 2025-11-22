import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mobile/data/models/quiz_models.dart';
import 'package:mobile/domain/repositories/admin_quiz_repository.dart';
import 'package:mobile/utils/toast_helper.dart';

class AdminQuizService extends ChangeNotifier {
  final AdminQuizRepository _quizRepository;

  AdminQuizService(this._quizRepository);

  // --- STATE DANH SÁCH ---
  List<QuizListModel> _quizzes = [];
  bool _isLoading = false; // Đổi tên cho giống CourseService
  String? _error;

  // State Phân trang & Tìm kiếm
  int _currentPage = 1;
  final int _pageSize = 5;
  int _totalCount = 0;
  int _totalPages = 0;
  String? _searchQuery;

  // Getters
  List<QuizListModel> get quizzes => _quizzes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalCount => _totalCount;
  String? get searchQuery => _searchQuery;

  // --- STATE CHI TIẾT (Cho màn hình Detail/Edit) ---
  QuizDetailModel? _selectedQuiz;
  bool _isLoadingDetail = false;
  String? _detailError;
  QuizDetailModel? get selectedQuiz => _selectedQuiz;
  bool get isLoadingDetail => _isLoadingDetail;
  String? get detailError => _detailError;

  // =================== LẤY DANH SÁCH QUIZ ===================
  Future<void> fetchQuizzes(String courseId, {bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _searchQuery = null;
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
      );

      _quizzes = result['quizzes'];
      _totalCount = result['totalCount'];

      // Tính tổng số trang (giống logic PagedResultModel)
      _totalPages = (_totalCount / _pageSize).ceil();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _quizzes = []; // Clear list nếu lỗi
      ToastHelper.showError(_error!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // =================== TÌM KIẾM & PHÂN TRANG ===================

  // Giống AdminCourseService: Chỉ nhận query, việc debounce để UI lo
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

  // =================== LẤY CHI TIẾT ===================
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

  // =================== TẠO QUIZ ===================
  Future<bool> createQuiz({
    required String courseId,
    required String title,
    String? description,
    required int timeLimitMinutes,
    required PlatformFile platformFile,
    required String skillType,
    String? readingPassage,
    // ❌ Đã xóa mediaUrl
  }) async {
    _isLoadingDetail = true; // Tận dụng loading detail hoặc tạo loading riêng
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
        // mediaUrl: mediaUrl, // Xóa
      );

      ToastHelper.showSuccess('Tạo bài tập thành công');

      // Refresh lại danh sách về trang 1 để thấy bài mới
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

  // =================== XÓA QUIZ ===================
  Future<void> deleteQuiz(String courseId, String quizId) async {
    try {
      await _quizRepository.deleteQuiz(courseId, quizId);
      ToastHelper.showSuccess('Xóa bài tập thành công');

      // Logic giống AdminCourseService: Load lại trang hiện tại
      await fetchQuizzes(courseId);
    } catch (e) {
      final errorMsg = e.toString().replaceFirst('Exception: ', '');
      ToastHelper.showError(errorMsg);
    } finally {
      notifyListeners();
    }
  }

  // =================== XÓA CÂU HỎI LẺ ===================
  Future<void> deleteQuestion(String courseId, String questionId) async {
    try {
      await _quizRepository.deleteQuestion(courseId, questionId);
      ToastHelper.showSuccess('Đã xóa câu hỏi');

      // Cập nhật UI Local ngay lập tức
      if (_selectedQuiz != null) {
        _selectedQuiz!.questions.removeWhere((q) => q.id == questionId);
        // Trick: update lại object để UI repaint
        _selectedQuiz = _selectedQuiz!.copyWith();
      }
    } catch (e) {
      ToastHelper.showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      notifyListeners();
    }
  }
}
