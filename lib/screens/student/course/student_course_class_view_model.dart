import 'package:flutter/foundation.dart';
import 'package:mobile/data/models/student_class_model.dart';
import 'package:mobile/domain/repositories/student/student_class_repository.dart';
import 'package:mobile/domain/repositories/student/student_course_repository.dart';
import 'package:mobile/utils/toast_helper.dart';

class StudentCourseClassViewModel extends ChangeNotifier {
  final StudentCourseRepository _courseRepository;
  final StudentClassRepository _classRepository;

  StudentCourseClassViewModel(this._courseRepository, this._classRepository);

  List<StudentClassModel> _classes = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<StudentClassModel> get classes => _classes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load classes for a specific course
  Future<void> loadClassesForCourse(String courseId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _classes = await _courseRepository.getClassesByCourse(courseId);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      ToastHelper.showError(_error!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Join a class
  Future<bool> joinClass(String classId, String courseId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _classRepository.joinClass(classId);
      ToastHelper.showSuccess('Tham gia lớp thành công');
      // Refresh the class list to remove the joined class
      await loadClassesForCourse(courseId);
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      ToastHelper.showError(_error!);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear data
  void clear() {
    _classes = [];
    _error = null;
    notifyListeners();
  }
}
