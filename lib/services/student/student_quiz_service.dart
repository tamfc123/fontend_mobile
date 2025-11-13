import 'package:flutter/material.dart';
import 'package:mobile/data/models/student_quiz_list_model.dart';
import 'package:mobile/data/models/student_quiz_review_model.dart';
import 'package:mobile/data/models/student_quiz_take_model.dart';
// ✅ 1. IMPORT MODEL MỚI CHO VIỆC NỘP BÀI
import 'package:mobile/data/models/student_submission_model.dart';
import 'package:mobile/domain/repositories/student_quiz_repository.dart';

class StudentQuizService extends ChangeNotifier {
  final StudentQuizRepository _quizRepository;
  StudentQuizService(this._quizRepository);

  // --- State cho màn hình List (StudentQuizListScreen) ---
  List<StudentQuizListModel> _quizzes = [];
  List<StudentQuizListModel> get quizzes => _quizzes;

  bool _isLoadingList = false;
  bool get isLoadingList => _isLoadingList;

  String? _listError;
  String? get listError => _listError;

  // --- màn hình Làm bài (StudentQuizTakingScreen) ---
  StudentQuizTakeModel? _currentQuiz;
  StudentQuizTakeModel? get currentQuiz => _currentQuiz;

  bool _isLoadingDetail = false;
  bool get isLoadingDetail => _isLoadingDetail;

  String? _detailError;
  String? get detailError => _detailError;

  // --- mà hình xem lịch sử ---
  StudentQuizReviewModel? _currentReview;
  StudentQuizReviewModel? get currentReview => _currentReview;

  bool _isLoadingReview = false;
  bool get isLoadingReview => _isLoadingReview;

  String? _reviewError;
  String? get reviewError => _reviewError;

  // --- API 1: Lấy danh sách quiz (Giữ nguyên) ---
  Future<void> fetchQuizList(int classId) async {
    _isLoadingList = true;
    _listError = null;
    notifyListeners();

    try {
      _quizzes = await _quizRepository.fetchQuizList(classId);
    } catch (e) {
      _listError = e.toString();
    }

    _isLoadingList = false;
    notifyListeners();
  }

  // --- API 2: Lấy chi tiết quiz để làm (Giữ nguyên) ---
  Future<void> fetchQuizForTaking(int classId, int quizId) async {
    _isLoadingDetail = true;
    _detailError = null;
    _currentQuiz = null;
    notifyListeners();

    try {
      _currentQuiz = await _quizRepository.fetchQuizForTaking(classId, quizId);
    } catch (e) {
      _detailError = e.toString();
    }

    _isLoadingDetail = false;
    notifyListeners();
  }

  // ✅ ========================================================
  // ✅ API 3: NỘP BÀI (ĐÃ CẬP NHẬT)
  // ✅ ========================================================
  Future<Map<String, dynamic>> submitQuiz(
    int classId,
    int quizId,
    // 2. 👈 THAM SỐ ĐÃ THAY ĐỔI
    List<StudentAnswerInputModel> answers,
  ) async {
    // 3. 👈 Chỉ cần gọi thẳng repository
    // (UI sẽ quản lý state loading/error khi nộp bài)
    return _quizRepository.submitQuiz(classId, quizId, answers);
  }

  // --- API 4 lịch sử làm bài (Giữ nguyên) ---
  Future<void> fetchQuizResult(int classId, int quizId) async {
    _isLoadingReview = true;
    _reviewError = null;
    _currentReview = null;
    notifyListeners();

    try {
      _currentReview = await _quizRepository.fetchQuizResult(classId, quizId);
    } catch (e) {
      _reviewError = e.toString();
    }

    _isLoadingReview = false;
    notifyListeners();
  }

  // --- Hàm dọn dẹp (Giữ nguyên) ---
  void clearQuizDetail() {
    _currentQuiz = null;
    _detailError = null;
  }

  void clearQuizResult() {
    _currentReview = null;
    _reviewError = null;
  }
}
