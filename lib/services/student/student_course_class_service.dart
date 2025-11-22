import 'package:flutter/material.dart';
import 'package:mobile/data/models/student_class_model.dart';
import 'package:mobile/domain/repositories/student_course_repository.dart';
import 'package:mobile/utils/toast_helper.dart';

class StudentCourseClassService extends ChangeNotifier {
  final StudentCourseRepository _courseRepository;

  // Inject Repository
  StudentCourseClassService(this._courseRepository);

  List<StudentClassModel> _classes = [];
  bool _isLoading = false;
  String? _error;

  List<StudentClassModel> get classes => _classes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Lấy danh sách lớp theo courseId
  Future<void> fetchClasses(String courseId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Gọi repository (đã được cập nhật API mới bên trong)
      final data = await _courseRepository.getClassesByCourse(courseId);
      _classes = data;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      debugPrint(_error);
      ToastHelper.showError(_error!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _classes = [];
    _error = null;
    notifyListeners();
  }
}
