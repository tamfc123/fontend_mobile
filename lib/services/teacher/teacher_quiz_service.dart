import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mobile/data/models/quiz_detail_model.dart';
import 'package:mobile/data/models/quiz_list_model.dart';
import 'package:mobile/domain/repositories/quiz_repository.dart';
import 'package:mobile/utils/toast_helper.dart';

class QuizService extends ChangeNotifier {
  final QuizRepository _quizRepository;
  QuizService(this._quizRepository);

  // --- 🔹 State Quản lý danh sách ---
  List<QuizListModel> _quizzes = [];
  bool _isLoadingList = false;
  String? _listError;

  List<QuizListModel> get quizzes => _quizzes;
  bool get isLoadingList => _isLoadingList;
  String? get listError => _listError;

  // --- 🔹 State Quản lý chi tiết ---
  QuizDetailModel? _selectedQuiz;
  bool _isLoadingDetail = false;
  String? _detailError;

  QuizDetailModel? get selectedQuiz => _selectedQuiz;
  bool get isLoadingDetail => _isLoadingDetail;
  String? get detailError => _detailError;

  // --- 🔹 HÀM GỌI API ---

  // 1. Lấy danh sách Quizzes (Giữ nguyên, không cần sửa)
  Future<void> fetchQuizzes(int classId) async {
    _isLoadingList = true;
    _listError = null;
    notifyListeners();

    try {
      _quizzes = await _quizRepository.getQuizzes(classId);
    } catch (e) {
      _listError = e.toString().replaceFirst('Exception: ', '');
      ToastHelper.showError(_listError!);
    } finally {
      _isLoadingList = false;
      notifyListeners();
    }
  }

  // 2. Lấy chi tiết Quiz (Giữ nguyên, không cần sửa)
  Future<void> fetchQuizDetails(int classId, int quizId) async {
    _isLoadingDetail = true;
    _detailError = null;
    _selectedQuiz = null; // Xóa chi tiết cũ
    notifyListeners();

    try {
      _selectedQuiz = await _quizRepository.getQuizDetails(classId, quizId);
    } catch (e) {
      _detailError = e.toString().replaceFirst('Exception: ', '');
      ToastHelper.showError(_detailError!);
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  // ✅ ========================================================
  // ✅ 3. TẠO MỚI QUIZ (ĐÃ CẬP NHẬT)
  // ✅ ========================================================
  Future<bool> createQuiz({
    required int classId,
    required String title,
    String? description,
    required int timeLimitMinutes,
    required PlatformFile platformFile,

    // ✅ THÊM 2 TRƯỜNG MỚI
    required String skillType,
    String? readingPassage,
  }) async {
    _isLoadingDetail = true; // Có thể dùng chung state loading
    _detailError = null;
    notifyListeners();

    try {
      await _quizRepository.createQuiz(
        classId: classId,
        title: title,
        description: description,
        timeLimitMinutes: timeLimitMinutes,
        platformFile: platformFile,

        // ✅ TRUYỀN 2 TRƯỜNG MỚI XUỐNG REPOSITORY
        skillType: skillType,
        readingPassage: readingPassage,
      );

      ToastHelper.showSucess('Tạo bài tập thành công!');
      await fetchQuizzes(classId); // Tải lại danh sách
      return true;
    } catch (e) {
      _detailError = e.toString().replaceFirst('Exception: ', '');
      ToastHelper.showError(_detailError!);
      return false;
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  // 4. Xóa một Quiz (Giữ nguyên, không cần sửa)
  Future<void> deleteQuiz(int classId, int quizId) async {
    try {
      await _quizRepository.deleteQuiz(classId, quizId);
      ToastHelper.showSucess('Xóa bài tập thành công!');

      _quizzes.removeWhere((quiz) => quiz.id == quizId);
    } catch (e) {
      ToastHelper.showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      notifyListeners();
    }
  }
}
