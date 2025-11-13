import 'package:flutter/material.dart';
import 'package:mobile/data/models/student_in_class_model.dart';
import 'package:mobile/data/models/teacher_class_model.dart';
import 'package:mobile/domain/repositories/teacher_class_repository.dart';
import 'package:mobile/utils/toast_helper.dart';

// Enum này vẫn hữu ích cho UI.
enum ClassSortType {
  courseNameAsc,
  courseNameDesc,
  studentCountAsc,
  studentCountDesc,
}

class TeacherClassService extends ChangeNotifier {
  final TeacherClassRepository _teacherClassRepository;
  TeacherClassService(this._teacherClassRepository);

  List<TeacherClassModel> _classes = [];
  bool _isLoading = false;
  String? _errorMessage;

  // --- 🔹 State mới cho Search và Sort ---
  String? _currentSearch;
  ClassSortType? _currentSortType;
  String? _currentSortBy;
  String? _currentSortOrder;

  // --- 🔹 Getters ---
  List<TeacherClassModel> get classes => _classes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Getters cho trạng thái filter
  String? get currentSearch => _currentSearch;
  ClassSortType? get currentSortType => _currentSortType;

  // ================== CÁC PHƯƠNG THỨC GỌI API ==================
  Future<void> fetchTeacherClasses() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _classes = await _teacherClassRepository.getTeacherClasses(
        search: _currentSearch,
        sortBy: _currentSortBy,
        sortOrder: _currentSortOrder,
      );
    } catch (e) {
      _errorMessage =
          'Lỗi khi tải lớp: ${e.toString().replaceFirst('Exception: ', '')}';
      ToastHelper.showError(_errorMessage!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cập nhật lớp
  Future<bool> updateTeacherClass(int id, String name) async {
    try {
      await _teacherClassRepository.updateTeacherClass(id, name);
      await fetchTeacherClasses();
      ToastHelper.showSucess('Cập nhật thành công');
      return true;
    } catch (e) {
      ToastHelper.showError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  Future<List<StudentInClassModel>> getStudentsInClass(int classId) async {
    try {
      // Gọi thẳng từ repository
      final students = await _teacherClassRepository.getStudentsInClass(
        classId,
      );
      return students;
    } catch (e) {
      // Hiển thị lỗi (nếu có) và trả về một danh sách rỗng
      ToastHelper.showError(
        e.toString().replaceFirst(
          'Exception: ',
          'Lỗi khi tải danh sách sinh viên: ',
        ),
      );
      return []; // Trả về rỗng để UI không bị crash
    }
  }

  // ================== CÁC PHƯƠNG THỨC FILTER/SORT ==================
  Future<void> applySearch(String searchTerm) async {
    final newSearch = searchTerm.trim();
    if (newSearch.isEmpty) {
      _currentSearch = null;
    } else {
      _currentSearch = newSearch;
    }
    // Không cần notifyListeners() ở đây, vì fetchTeacherClasses sẽ làm điều đó
    await fetchTeacherClasses();
  }

  //sắp xếp
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
      // Bạn có thể thêm 'name' (tên lớp) nếu muốn
      // case ClassSortType.nameAsc:
      //   _currentSortBy = 'name';
      //   _currentSortOrder = 'asc';
      //   break;
    }

    // 3. Gọi API để lấy dữ liệu đã được sắp xếp
    await fetchTeacherClasses();
  }

  //Xóa tất cả bộ lọc và sắp xếp
  Future<void> clearFiltersAndSort() async {
    _currentSearch = null;
    _currentSortType = null;
    _currentSortBy = null;
    _currentSortOrder = null;
    await fetchTeacherClasses();
  }
}
