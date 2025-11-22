import 'package:flutter/material.dart';
import 'package:mobile/data/models/module_model.dart';
import 'package:mobile/data/models/paged_result_model.dart';
import 'package:mobile/domain/repositories/admin_module_repository.dart';
import 'package:mobile/utils/toast_helper.dart';

class AdminModuleService extends ChangeNotifier {
  final AdminModuleRepository _moduleRepository;
  AdminModuleService(this._moduleRepository);

  List<ModuleModel> _modules = [];
  PagedResultModel<ModuleModel>? _pagedResult;

  bool _isLoading = false;
  String? _errorMessage;
  String? _currentSearchQuery;

  List<ModuleModel> get modules => _modules;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get totalCount => _pagedResult?.totalCount ?? 0;
  int get totalPages => _pagedResult?.totalPages ?? 0;
  int get currentPage => _pagedResult?.pageNumber ?? 1;
  bool get hasNextPage => _pagedResult?.hasNextPage ?? false;
  bool get hasPreviousPage => _pagedResult?.hasPreviousPage ?? false;
  String? get currentSearchQuery => _currentSearchQuery;

  Future<void> fetchModules({
    required String courseId,
    int pageNumber = 1,
    String? searchQuery,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    _currentSearchQuery = searchQuery;

    try {
      final result = await _moduleRepository.getPaginatedModules(
        courseId: courseId,
        pageNumber: pageNumber,
        pageSize: 5,
        searchQuery: searchQuery,
      );

      _modules = result.items;
      _pagedResult = result;
    } catch (e) {
      _errorMessage =
          'Lỗi khi tải chương học: ${e.toString().replaceFirst('Exception: ', '')}';
      ToastHelper.showError(_errorMessage!);
      _modules = [];
      _pagedResult = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addModule(ModuleCreateModel module) async {
    try {
      await _moduleRepository.createModule(module);
      ToastHelper.showSuccess('Thêm chương học thành công');

      await fetchModules(
        courseId: module.courseId,
        pageNumber: 1,
        searchQuery: _currentSearchQuery,
      );
      return true;
    } catch (e) {
      ToastHelper.showError(
        'Thêm chương học thất bại: ${e.toString().replaceFirst('Exception: ', '')}',
      );
      return false;
    }
  }

  Future<bool> updateModule(String id, ModuleModel module) async {
    try {
      await _moduleRepository.updateModule(id, module);
      ToastHelper.showSuccess('Cập nhật chương học thành công');

      await fetchModules(
        courseId: module.courseId,
        pageNumber: currentPage, // Giữ nguyên trang
        searchQuery: _currentSearchQuery, // Giữ nguyên search
      );
      return true;
    } catch (e) {
      ToastHelper.showError(
        'Cập nhật chương học thất bại: ${e.toString().replaceFirst('Exception: ', '')}',
      );
      return false;
    }
  }

  Future<bool> deleteModule(String id, String courseId) async {
    try {
      await _moduleRepository.deleteModule(id);
      ToastHelper.showSuccess('Xóa chương học thành công');

      await fetchModules(
        courseId: courseId,
        pageNumber: 1,
        searchQuery: _currentSearchQuery,
      );
      return true;
    } catch (e) {
      ToastHelper.showError(
        'Xóa chương học thất bại: ${e.toString().replaceFirst('Exception: ', '')}',
      );
      return false;
    }
  }
}
