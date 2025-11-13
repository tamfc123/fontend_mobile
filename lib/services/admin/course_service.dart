import 'package:flutter/material.dart';
import 'package:mobile/data/models/course_model.dart';
import 'package:mobile/domain/repositories/course_repository.dart';

class CourseService extends ChangeNotifier {
  final CourseRepository _courseRepository;
  CourseService(this._courseRepository);

  List<CourseModel> _courses = [];
  bool _isLoading = false;
  String? _error;

  List<CourseModel> get courses => _courses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // =================== LẤY DANH SÁCH COURSE ===================
  Future<void> fetchCourses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 5. GỌI REPOSITORY
      _courses = await _courseRepository.getAllCourses();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // =================== TẠO COURSE ===================
  Future<void> addCourse(CourseModel course) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 6. GỌI REPOSITORY
      final newCourse = await _courseRepository.createCourse(course);
      _courses.add(newCourse);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // =================== CẬP NHẬT COURSE ===================
  Future<void> updateCourse(int id, CourseModel course) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 7. GỌI REPOSITORY
      final updatedCourse = await _courseRepository.updateCourse(id, course);
      final index = _courses.indexWhere((c) => c.id == id);
      if (index != -1) {
        // Cập nhật bằng dữ liệu trả về từ API (chuẩn hơn)
        _courses[index] = updatedCourse;
      }
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // =================== XÓA COURSE ===================
  Future<void> deleteCourse(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 8. GỌI REPOSITORY
      await _courseRepository.deleteCourse(id);
      _courses.removeWhere((c) => c.id == id);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
