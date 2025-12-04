import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile/data/models/course_model.dart';
import 'package:mobile/domain/repositories/admin/admin_course_repository.dart';
import 'package:mobile/utils/toast_helper.dart';

class ManageCourseViewModel extends ChangeNotifier {
  final AdminCourseRepository _courseRepository;

  ManageCourseViewModel(this._courseRepository);

  List<CourseModel> _courses = [];
  List<CourseModel> get courses => _courses;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _searchQuery;
  String? get searchQuery => _searchQuery;

  int _currentPage = 1;
  int get currentPage => _currentPage;

  int _totalPages = 1;
  int get totalPages => _totalPages;

  int _totalCount = 0;
  int get totalCount => _totalCount;

  final int _pageSize = 5;

  Future<void> fetchCourses() async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _courseRepository.getAllCourses(
        pageNumber: _currentPage,
        search: _searchQuery,
      );

      _courses = result.items;
      _totalCount = result.totalCount;
      _totalPages = (_totalCount / _pageSize).ceil();
      if (_totalPages == 0) _totalPages = 1;
    } catch (e) {
      ToastHelper.showError('Lỗi tải danh sách khóa học: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> applySearch(String query) async {
    if (_searchQuery == query) return;
    _searchQuery = query;
    _currentPage = 1;
    await fetchCourses();
  }

  Future<void> goToPage(int page) async {
    if (page < 1 || page > _totalPages || page == _currentPage) return;
    _currentPage = page;
    await fetchCourses();
  }

  Future<bool> createCourse(CourseModel course) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _courseRepository.createCourse(course);
      ToastHelper.showSuccess('Thêm khóa học thành công');
      await fetchCourses();
      return true;
    } catch (e) {
      ToastHelper.showError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateCourse(String id, CourseModel course) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _courseRepository.updateCourse(id, course);
      ToastHelper.showSuccess('Cập nhật khóa học thành công');
      await fetchCourses();
      return true;
    } catch (e) {
      ToastHelper.showError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteCourse(String id) async {
    try {
      await _courseRepository.deleteCourse(id);
      ToastHelper.showSuccess('Xóa khóa học thành công');
      // Nếu xóa item cuối cùng của trang, quay lại trang trước
      if (_courses.length == 1 && _currentPage > 1) {
        _currentPage--;
      }
      await fetchCourses();
      return true;
    } catch (e) {
      ToastHelper.showError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }
}
