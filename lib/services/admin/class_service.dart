import 'package:flutter/material.dart';
import 'package:mobile/data/models/class_model.dart';
import 'package:mobile/domain/repositories/class_repository.dart';
import 'package:mobile/utils/toast_helper.dart';

class ClassService extends ChangeNotifier {
  final ClassRepository _classRepository;
  ClassService(this._classRepository);

  List<ClassModel> _allClasses = [];
  List<ClassModel> _classes = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  List<ClassModel> get classes => _classes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchClasses() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      // 5. GỌI REPOSITORY
      _allClasses = await _classRepository.getAllClasses();
      _applyFilters();
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

  // --- (Hàm filter không đổi) ---
  void _applyFilters() {
    final query = _searchQuery.toLowerCase();
    if (query.isEmpty) {
      _classes = _allClasses;
    } else {
      _classes =
          _allClasses
              .where(
                (c) =>
                    c.name.toLowerCase().contains(query) ||
                    c.courseName.toLowerCase().contains(query),
              )
              .toList();
    }
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }
  // --- (Hết hàm filter) ---

  Future<bool> addClass(String name, int courseId, String? teacherId) async {
    try {
      // 6. GỌI REPOSITORY
      final success = await _classRepository.createClass(
        name,
        courseId,
        teacherId,
      );
      if (success) {
        ToastHelper.showSucess('Thêm lớp học thành công');
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
    int id,
    String name,
    int courseId,
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
        ToastHelper.showSucess('Cập nhật lớp học thành công');
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

  Future<bool> deleteClass(int id) async {
    try {
      // 8. GỌI REPOSITORY
      final success = await _classRepository.deleteClass(id);
      if (success) {
        ToastHelper.showSucess('Xóa lớp học thành công!');
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
