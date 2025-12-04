import 'package:flutter/material.dart';
import 'package:mobile/data/models/quiz_models.dart';
import 'package:mobile/domain/repositories/teacher/teacher_quiz_repository.dart';
import 'package:mobile/utils/toast_helper.dart';

class TeacherQuizViewModel extends ChangeNotifier {
  final TeacherQuizRepository _repository;

  TeacherQuizViewModel(this._repository);

  List<QuizListModel> _quizzes = [];
  bool _isLoading = false;
  String? _error;

  List<QuizListModel> get quizzes => _quizzes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Dùng cho chi tiết (nếu cần show dialog xem trước)
  QuizDetailModel? _selectedQuiz;
  QuizDetailModel? get selectedQuiz => _selectedQuiz;

  Future<void> fetchQuizzes(String classId, {String? search}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _quizzes = await _repository.getQuizzes(classId, search: search);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _quizzes = [];
      // Chỉ hiện toast nếu không phải lỗi do search rỗng (UX tốt hơn)
      if (search == null) ToastHelper.showError(_error!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchQuizDetail(String classId, String quizId) async {
    // Hàm này dùng khi giáo viên bấm vào xem chi tiết
    try {
      _selectedQuiz = await _repository.getQuizDetail(classId, quizId);
      notifyListeners();
    } catch (e) {
      ToastHelper.showError(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}
