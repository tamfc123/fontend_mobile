import 'package:flutter/material.dart';
import 'package:mobile/data/models/student_in_class_model.dart';
import 'package:mobile/data/models/teacher_class_model.dart';
import 'package:mobile/data/models/paged_result_model.dart';
import 'package:mobile/domain/repositories/teacher_class_repository.dart';
import 'package:mobile/utils/toast_helper.dart';

enum ClassSortType {
  nameAsc,
  nameDesc,
  courseNameAsc,
  courseNameDesc,
  studentCountAsc,
  studentCountDesc,
}

class TeacherAdminClassService extends ChangeNotifier {
  final TeacherClassRepository _teacherClassRepository;
  TeacherAdminClassService(this._teacherClassRepository);

  List<TeacherClassModel> _classes = [];
  PagedResultModel<TeacherClassModel>? _pagedResult;

  bool _isLoading = false;
  String? _errorMessage;

  String? _currentSearch;
  ClassSortType _currentSortType = ClassSortType.nameAsc;
  String? _currentSortBy = 'name';
  String? _currentSortOrder = 'asc';

  List<TeacherClassModel> get classes => _classes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String? get currentSearch => _currentSearch;
  ClassSortType? get currentSortType => _currentSortType;

  int get totalCount => _pagedResult?.totalCount ?? 0;
  int get totalPages => _pagedResult?.totalPages ?? 0;
  int get currentPage => _pagedResult?.pageNumber ?? 1;
  bool get hasNextPage => _pagedResult?.hasNextPage ?? false;
  bool get hasPreviousPage => _pagedResult?.hasPreviousPage ?? false;
  String? get currentSearchQuery => _currentSearch;

  // ================== CÁC PHƯƠNG THỨC GỌI API ==================

  Future<void> fetchTeacherClasses({int? pageNumber}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _teacherClassRepository.getPaginatedTeacherClasses(
        pageNumber: pageNumber ?? currentPage,
        pageSize: 5,
        search: _currentSearch,
        sortBy: _currentSortBy,
        sortOrder: _currentSortOrder,
      );
      _classes = result.items;
      _pagedResult = result;
    } catch (e) {
      _errorMessage =
          'Lỗi khi tải lớp: ${e.toString().replaceFirst('Exception: ', '')}';
      ToastHelper.showError(_errorMessage!);
      _classes = [];
      _pagedResult = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateTeacherClass(String id, String name) async {
    try {
      await _teacherClassRepository.updateTeacherClass(id, name);
      await fetchTeacherClasses(pageNumber: currentPage);
      ToastHelper.showSuccess('Cập nhật thành công');
      return true;
    } catch (e) {
      ToastHelper.showError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  Future<List<StudentInClassModel>> getStudentsInClass(String classId) async {
    try {
      final students = await _teacherClassRepository.getStudentsInClass(
        classId,
      );
      return students;
    } catch (e) {
      ToastHelper.showError(
        e.toString().replaceFirst(
          'Exception: ',
          'Lỗi khi tải danh sách sinh viên: ',
        ),
      );
      return []; // Trả về rỗng để UI không bị crash
    }
  }

  // ================== CÁC PHƯƠG THỨC FILTER/SORT ==================

  Future<void> applySearch(String searchTerm) async {
    _currentSearch = searchTerm.trim().isEmpty ? null : searchTerm.trim();
    // 6.1 Luôn về trang 1 khi search
    await fetchTeacherClasses(pageNumber: 1);
  }

  Future<void> applySort(ClassSortType sortType) async {
    _currentSortType = sortType;
    switch (sortType) {
      case ClassSortType.courseNameAsc:
        _currentSortBy = 'courseName';
        _currentSortOrder = 'asc';
        break;
      case ClassSortType.courseNameDesc:
        _currentSortBy = 'courseName';
        _currentSortOrder = 'desc';
        break;
      case ClassSortType.studentCountAsc:
        _currentSortBy = 'studentCount';
        _currentSortOrder = 'asc';
        break;
      case ClassSortType.studentCountDesc:
        _currentSortBy = 'studentCount';
        _currentSortOrder = 'desc';
        break;
      case ClassSortType.nameAsc:
        _currentSortBy = 'name';
        _currentSortOrder = 'asc';
        break;
      case ClassSortType.nameDesc:
        _currentSortBy = 'name';
        _currentSortOrder = 'desc';
        break;
    }
    await fetchTeacherClasses(pageNumber: 1);
  }

  Future<void> clearFiltersAndSort() async {
    _currentSearch = null;
    _currentSortType = ClassSortType.nameAsc; // Reset về mặc định
    _currentSortBy = 'name';
    _currentSortOrder = 'asc';
    await fetchTeacherClasses(pageNumber: 1);
  }

  Future<void> goToPage(int page) async {
    if (page < 1 || (page > totalPages && totalPages > 0)) return;
    await fetchTeacherClasses(pageNumber: page);
  }
}
