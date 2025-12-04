import 'package:flutter/material.dart';
import 'package:mobile/data/models/quiz_models.dart';
import 'package:mobile/domain/repositories/admin/admin_quiz_repository.dart';
import 'package:mobile/utils/toast_helper.dart';

class QuizDetailViewModel extends ChangeNotifier {
  final AdminQuizRepository _repository;

  QuizDetailViewModel(this._repository);

  QuizDetailModel? _selectedQuiz;
  bool _isLoading = false;
  String? _error;

  QuizDetailModel? get selectedQuiz => _selectedQuiz;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchQuizDetails(String courseId, String quizId) async {
    _isLoading = true;
    _error = null;
    _selectedQuiz = null;
    notifyListeners();

    try {
      _selectedQuiz = await _repository.getQuizDetails(courseId, quizId);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      ToastHelper.showError(_error!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteQuestion(String courseId, String questionId) async {
    try {
      await _repository.deleteQuestion(courseId, questionId);
      ToastHelper.showSuccess('Đã xóa câu hỏi');
      if (_selectedQuiz != null) {
        _selectedQuiz!.questions.removeWhere((q) => q.id == questionId);
        // Force notify listeners by creating a copy or just notify
        // Since QuizDetailModel fields are final and list is mutable or not?
        // The model definition shows final List<QuestionDetailModel> questions;
        // If the list itself is mutable we can remove.
        // Let's assume it is mutable for now or we need to copyWith.
        // The previous service did: _selectedQuiz!.questions.removeWhere...
        // So it seems the list is mutable.
        notifyListeners();
      }
    } catch (e) {
      ToastHelper.showError(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}
