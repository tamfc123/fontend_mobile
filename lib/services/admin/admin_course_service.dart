import 'package:flutter/material.dart';
import 'package:mobile/data/models/course_model.dart';
import 'package:mobile/data/models/paged_result_model.dart';
import 'package:mobile/domain/repositories/admin_course_repository.dart';
import 'package:mobile/utils/toast_helper.dart';

class AdminCourseService extends ChangeNotifier {
  final AdminCourseRepository _courseRepository;
  AdminCourseService(this._courseRepository);

  List<CourseModel> _courses = [];
  List<CourseModel> _coursesForDropdown = [];
  bool _isLoading = false;
  String? _error;

  int _currentPage = 1;
  int _pageSize = 5;
  int _totalCount = 0;
  int _totalPages = 0;
  String? _searchQuery;

  List<CourseModel> get courses => _courses;
  List<CourseModel> get coursesForDropdown => _coursesForDropdown;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalCount => _totalCount;
  String? get searchQuery => _searchQuery;

  // =================== LẤY DANH SÁCH COURSE (ĐÃ SỬA) ===================
  Future<void> fetchCourses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final PagedResultModel<CourseModel> result = await _courseRepository
          .getAllCourses(search: _searchQuery, pageNumber: _currentPage);

      _courses = result.items;
      _totalCount = result.totalCount;
      _totalPages = result.totalPages;
      _pageSize = result.pageSize;
      _currentPage = result.pageNumber;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _courses = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllCoursesForDropdown() async {
    try {
      _coursesForDropdown = await _courseRepository.getAllCoursesForDropdown();
      notifyListeners(); // Cập nhật UI để Dropdown có dữ liệu
    } catch (e) {
      debugPrint('Lỗi tải danh sách khóa học cho dropdown: $e');
      ToastHelper.showError('Không tải được danh sách khóa học');
    }
  }

  Future<void> applySearch(String query) async {
    _searchQuery = query.isEmpty ? null : query;
    _currentPage = 1;
    await fetchCourses();
  }

  Future<void> goToPage(int page) async {
    if (page < 1 || (page > _totalPages && _totalPages > 0)) return;
    _currentPage = page;
    await fetchCourses();
  }

  // =================== TẠO COURSE (ĐÃ SỬA) ===================
  Future<bool> addCourse(CourseModel course) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _courseRepository.createCourse(course);
      ToastHelper.showSuccess('Tạo khóa học thành công');
      _currentPage = 1;
      _searchQuery = null; // Xóa search để thấy mục mới
      await fetchCourses();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      ToastHelper.showError('Tạo thất bại: $_error');
      notifyListeners();
      return false;
    }
  }

  // =================== CẬP NHẬT COURSE (ĐÃ SỬA) ===================
  Future<bool> updateCourse(String id, CourseModel course) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _courseRepository.updateCourse(id, course);
      ToastHelper.showSuccess('Cập nhật khóa học thành công');
      await fetchCourses();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      ToastHelper.showError('Cập nhật thất bại: $_error');
      notifyListeners();
      return false;
    }
  }

  // =================== XÓA COURSE (ĐÃ SỬA) ===================
  Future<bool> deleteCourse(String id) async {
    try {
      await _courseRepository.deleteCourse(id);
      ToastHelper.showSuccess('Xóa khóa học thành công');
      _currentPage = 1;
      await fetchCourses();
      return true;
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      _error = errorMessage;
      ToastHelper.showError(errorMessage); // Hiển thị lỗi từ API
      notifyListeners();
      return false;
    }
  }
}
