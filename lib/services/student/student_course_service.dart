import 'package:flutter/material.dart';
import 'package:mobile/data/models/course_model.dart';
import 'package:mobile/domain/repositories/student_course_repository.dart';
import 'package:mobile/utils/toast_helper.dart';

class StudentCourseService extends ChangeNotifier {
  final StudentCourseRepository _courseRepository;
  StudentCourseService(this._courseRepository);

  List<CourseModel> _courses = [];
  bool _isLoading = false;
  String? _error;

  List<CourseModel> get courses => _courses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Lấy danh sách khóa học khả dụng
  Future<void> loadAvailableCourses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 6. GỌI REPOSITORY
      _courses = await _courseRepository.getAvailableCourses();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      ToastHelper.showError(_error!); // Thêm toast
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _courses = [];
    _error = null;
    notifyListeners();
  }
}
