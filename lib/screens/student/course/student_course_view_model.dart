import 'package:flutter/foundation.dart';
import 'package:mobile/data/models/course_model.dart';
import 'package:mobile/domain/repositories/student/student_course_repository.dart';
import 'package:mobile/utils/toast_helper.dart';

class StudentCourseViewModel extends ChangeNotifier {
  final StudentCourseRepository _repository;

  StudentCourseViewModel(this._repository);

  List<CourseModel> _courses = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<CourseModel> get courses => _courses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load available courses
  Future<void> loadAvailableCourses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _courses = await _repository.getAvailableCourses();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      ToastHelper.showError(_error!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear data
  void clear() {
    _courses = [];
    _error = null;
    notifyListeners();
  }
}
