import 'package:flutter/material.dart';
import 'package:mobile/data/models/student_quiz_models.dart';
import 'package:mobile/domain/repositories/student/student_quiz_repository.dart';
import 'package:mobile/utils/toast_helper.dart';

class StudentQuizViewModel extends ChangeNotifier {
  final StudentQuizRepository _quizRepository;
  StudentQuizViewModel(this._quizRepository);

  // Quiz List Screen
  List<StudentQuizListModel> _quizzes = [];
  bool _isLoadingList = false;
  String? _listError;

  List<StudentQuizListModel> get quizzes => _quizzes;
  bool get isLoadingList => _isLoadingList;
  String? get listError => _listError;

  String _currentFilter = 'ALL';
  String get currentFilter => _currentFilter;

  Future<void> loadQuizList(String classId, {String filter = 'ALL'}) async {
    _isLoadingList = true;
    _currentFilter = filter;
    _listError = null;
    notifyListeners();

    try {
      _quizzes = await _quizRepository.fetchQuizList(
        classId,
        skillType: filter,
      );
    } catch (e) {
      _listError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoadingList = false;
      notifyListeners();
    }
  }

  // Quiz Taking Screen
  StudentQuizTakeModel? _currentQuiz;
  bool _isLoadingDetail = false;
  String? _detailError;

  StudentQuizTakeModel? get currentQuiz => _currentQuiz;
  bool get isLoadingDetail => _isLoadingDetail;
  String? get detailError => _detailError;

  Future<void> loadQuizForTaking(String classId, String quizId) async {
    _isLoadingDetail = true;
    _detailError = null;
    _currentQuiz = null;
    notifyListeners();

    try {
      _currentQuiz = await _quizRepository.fetchQuizForTaking(classId, quizId);
    } catch (e) {
      _detailError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> submitQuiz(
    String classId,
    String quizId,
    List<StudentAnswerInputModel> answers,
  ) async {
    _isLoadingDetail = true;

    try {
      final result = await _quizRepository.submitQuiz(classId, quizId, answers);
      return result;
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      ToastHelper.showError(msg);
      return null;
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> submitWritingQuiz(
    String classId,
    String quizId,
    String content,
  ) async {
    _isLoadingDetail = true;
    notifyListeners();

    try {
      final result = await _quizRepository.submitWritingQuiz(
        classId,
        quizId,
        content,
      );
      return result;
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      ToastHelper.showError(msg);
      return null;
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  void clearQuizDetail() {
    _currentQuiz = null;
    _detailError = null;
  }

  // Review Screen
  StudentQuizReviewModel? _currentReview;
  bool _isLoadingReview = false;
  String? _reviewError;

  StudentQuizReviewModel? get currentReview => _currentReview;
  bool get isLoadingReview => _isLoadingReview;
  String? get reviewError => _reviewError;

  Future<void> loadQuizResult(String classId, String quizId) async {
    _isLoadingReview = true;
    _reviewError = null;
    _currentReview = null;
    notifyListeners();

    try {
      _currentReview = await _quizRepository.fetchQuizResult(classId, quizId);
    } catch (e) {
      _reviewError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoadingReview = false;
      notifyListeners();
    }
  }

  void clearQuizResult() {
    _currentReview = null;
    _reviewError = null;
  }
}
