import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile/data/models/module_model.dart';
import 'package:mobile/domain/repositories/admin/admin_module_repository.dart';
import 'package:mobile/utils/toast_helper.dart';

class ManageModuleViewModel extends ChangeNotifier {
  final AdminModuleRepository _moduleRepository;

  ManageModuleViewModel(this._moduleRepository);

  List<ModuleModel> _modules = [];
  List<ModuleModel> get modules => _modules;

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

  Future<void> fetchModules({
    required String courseId,
    int? pageNumber,
    String? searchQuery,
  }) async {
    _isLoading = true;
    if (pageNumber != null) _currentPage = pageNumber;
    if (searchQuery != null) _searchQuery = searchQuery;
    notifyListeners();

    try {
      final result = await _moduleRepository.getPaginatedModules(
        courseId: courseId,
        pageNumber: _currentPage,
        pageSize: _pageSize,
        searchQuery: _searchQuery,
      );

      _modules = result.items;
      _totalCount = result.totalCount;
      _totalPages = (_totalCount / _pageSize).ceil();
      if (_totalPages == 0) _totalPages = 1;
    } catch (e) {
      ToastHelper.showError('Lỗi tải danh sách chương: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> applySearch(String courseId, String query) async {
    if (_searchQuery == query) return;
    _searchQuery = query;
    _currentPage = 1;
    await fetchModules(courseId: courseId);
  }

  Future<void> goToPage(String courseId, int page) async {
    if (page < 1 || page > _totalPages || page == _currentPage) return;
    _currentPage = page;
    await fetchModules(courseId: courseId);
  }

  Future<bool> createModule(ModuleCreateModel module) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _moduleRepository.createModule(module);
      ToastHelper.showSuccess('Thêm chương thành công');
      await fetchModules(courseId: module.courseId);
      return true;
    } catch (e) {
      ToastHelper.showError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateModule(String id, ModuleModel module) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _moduleRepository.updateModule(id, module);
      ToastHelper.showSuccess('Cập nhật chương thành công');
      await fetchModules(courseId: module.courseId);
      return true;
    } catch (e) {
      ToastHelper.showError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteModule(String id, String courseId) async {
    try {
      await _moduleRepository.deleteModule(id);
      ToastHelper.showSuccess('Xóa chương thành công');
      // Nếu xóa item cuối cùng của trang, quay lại trang trước
      if (_modules.length == 1 && _currentPage > 1) {
        _currentPage--;
      }
      await fetchModules(courseId: courseId);
      return true;
    } catch (e) {
      ToastHelper.showError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }
}
