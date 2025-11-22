import 'package:flutter/material.dart';
import 'package:mobile/data/models/class_model.dart';
import 'package:mobile/data/models/paged_result_model.dart';
import 'package:mobile/domain/repositories/admin_class_repository.dart';
import 'package:mobile/utils/toast_helper.dart';

class AdminClassService extends ChangeNotifier {
  final AdminClassRepository _classRepository;
  AdminClassService(this._classRepository);

  List<ClassModel> _classes = [];
  bool _isLoading = false;
  String? _errorMessage;

  String? _searchQuery;
  int _currentPage = 1;
  int _totalCount = 0;
  int _totalPages = 0;

  List<ClassModel> _allActiveClasses = [];

  List<ClassModel> get classes => _classes;
  List<ClassModel> get allActiveClasses => _allActiveClasses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalCount => _totalCount;
  String? get searchQuery => _searchQuery;

  Future<void> fetchClasses() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 5. GỌI REPOSITORY MỚI (truyền state)
      final PagedResultModel<ClassModel> result = await _classRepository
          .getAllClasses(search: _searchQuery, pageNumber: _currentPage);

      // 6. CẬP NHẬT TẤT CẢ STATE TỪ KẾT QUẢ
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

  Future<void> fetchAllActiveClasses() async {
    // Không set isLoading để tránh ảnh hưởng UI chính
    try {
      _allActiveClasses = await _classRepository.getAllActiveClasses();
      notifyListeners(); // Cập nhật các dropdown đang lắng nghe
    } catch (e) {
      ToastHelper.showError(
        'Lỗi tải danh sách lớp: ${e.toString().replaceFirst('Exception: ', '')}',
      );
    }
  }

  Future<void> applySearch(String query) async {
    _searchQuery = query.isEmpty ? null : query;
    _currentPage = 1;
    await fetchClasses();
  }

  Future<void> goToPage(int page) async {
    if (page < 1 || (page > _totalPages && _totalPages > 0))
      return; // Trang không hợp lệ
    _currentPage = page;
    await fetchClasses();
  }

  Future<bool> addClass(String name, String courseId, String? teacherId) async {
    try {
      // 6. GỌI REPOSITORY
      final success = await _classRepository.createClass(
        name,
        courseId,
        teacherId,
      );
      if (success) {
        ToastHelper.showSuccess('Thêm lớp học thành công');
        _currentPage = 1;
        _searchQuery = null;
        await fetchClasses();
      }
      return success;
    } catch (e) {
      ToastHelper.showError(
        'Thêm lớp học thất bại: ${e.toString().replaceFirst('Exception: ', '')}',
      );
      return false;
    }
  }

  Future<bool> updateClass(
    String id,
    String name,
    String courseId,
    String? teacherId,
  ) async {
    try {
      // 7. GỌI REPOSITORY
      final success = await _classRepository.updateClass(
        id,
        name,
        courseId,
        teacherId,
      );
      if (success) {
        ToastHelper.showSuccess('Cập nhật lớp học thành công');
        await fetchClasses();
      }
      return success;
    } catch (e) {
      ToastHelper.showError(
        'Cập nhật lớp học thất bại: ${e.toString().replaceFirst('Exception: ', '')}',
      );
      return false;
    }
  }

  Future<bool> deleteClass(String id) async {
    try {
      // 8. GỌI REPOSITORY
      final success = await _classRepository.deleteClass(id);
      if (success) {
        ToastHelper.showSuccess('Xóa lớp học thành công!');
        await fetchClasses();
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
