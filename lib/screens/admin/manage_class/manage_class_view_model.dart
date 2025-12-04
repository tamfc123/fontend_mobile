import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile/data/models/class_model.dart';
import 'package:mobile/data/models/course_model.dart';
import 'package:mobile/data/models/user_model.dart';
import 'package:mobile/domain/repositories/admin/admin_class_repository.dart';
import 'package:mobile/domain/repositories/admin/admin_course_repository.dart';
import 'package:mobile/domain/repositories/admin/admin_user_repository.dart';
import 'package:mobile/utils/toast_helper.dart';

class ManageClassViewModel extends ChangeNotifier {
  final AdminClassRepository _classRepository;
  final AdminUserRepository _userRepository;
  final AdminCourseRepository _courseRepository;

  ManageClassViewModel(
    this._classRepository,
    this._userRepository,
    this._courseRepository,
  );

  // State for Classes List
  List<ClassModel> _classes = [];
  bool _isLoading = false;
  String? _errorMessage;

  int _currentPage = 1;

  int _totalCount = 0;
  int _totalPages = 0;
  String? _searchQuery;

  // State for Dropdowns (Teachers & Courses)
  List<UserModel> _teachers = [];
  List<CourseModel> _courses = [];

  List<ClassModel> get classes => _classes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalCount => _totalCount;
  String? get searchQuery => _searchQuery;

  List<UserModel> get teachers => _teachers;
  List<CourseModel> get courses => _courses;

  Timer? _debounce;

  void init() {
    fetchClasses(page: 1);
    fetchTeachers();
    fetchCourses();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  // Fetch Classes (Paged)
  Future<void> fetchClasses({int? page}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _classRepository.getAllClasses(
        search: _searchQuery,
        pageNumber: page ?? _currentPage,
      );

      _classes = result.items;
      _totalCount = result.totalCount;
      _totalPages = result.totalPages;
      _currentPage = result.pageNumber;
    } catch (e) {
      _classes = [];
      _errorMessage =
          'Lỗi khi tải lớp học: ${e.toString().replaceFirst('Exception: ', '')}';
      ToastHelper.showError(_errorMessage!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch Teachers (for Dropdown)
  Future<void> fetchTeachers() async {
    try {
      // Assuming AdminUserRepository has a method to get teachers or paged users
      // Based on AdminUserService, it uses getUserPaged with role='teacher'
      final result = await _userRepository.getUserPaged(
        page: 1,
        pageSize: 100, // Get enough teachers
        role: 'teacher',
      );
      _teachers = result['data']; // Assuming result['data'] is List<UserModel>
      notifyListeners();
    } catch (e) {
      debugPrint('Lỗi tải danh sách giáo viên: $e');
    }
  }

  // Fetch Courses (for Dropdown)
  Future<void> fetchCourses() async {
    try {
      _courses = await _courseRepository.getAllCoursesForDropdown();
      notifyListeners();
    } catch (e) {
      debugPrint('Lỗi tải danh sách khóa học: $e');
    }
  }

  // Search Logic
  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchQuery = query.isEmpty ? null : query;
      fetchClasses(page: 1);
    });
  }

  Future<void> goToPage(int page) async {
    if (page < 1 || (page > _totalPages && _totalPages > 0)) return;
    fetchClasses(page: page);
  }

  // CRUD Operations
  Future<bool> addClass(String name, String courseId, String? teacherId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await _classRepository.createClass(
        name,
        courseId,
        teacherId,
      );
      if (success) {
        ToastHelper.showSuccess('Thêm lớp học thành công');
        _searchQuery = null;
        await fetchClasses(page: 1);
      }
      return success;
    } catch (e) {
      ToastHelper.showError(
        'Thêm lớp học thất bại: ${e.toString().replaceFirst('Exception: ', '')}',
      );
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateClass(
    String id,
    String name,
    String courseId,
    String? teacherId,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await _classRepository.updateClass(
        id,
        name,
        courseId,
        teacherId,
      );
      if (success) {
        ToastHelper.showSuccess('Cập nhật lớp học thành công');
        await fetchClasses(page: _currentPage);
      }
      return success;
    } catch (e) {
      ToastHelper.showError(
        'Cập nhật lớp học thất bại: ${e.toString().replaceFirst('Exception: ', '')}',
      );
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteClass(String id) async {
    // Optimistic update or wait? Let's wait.
    try {
      final success = await _classRepository.deleteClass(id);
      if (success) {
        ToastHelper.showSuccess('Xóa lớp học thành công!');
        await fetchClasses(page: _currentPage);
      }
      return success;
    } catch (e) {
      ToastHelper.showError(
        'Xóa lớp học thất bại: ${e.toString().replaceFirst('Exception: ', '')}',
      );
      return false;
    }
  }
}
