import 'package:flutter/foundation.dart';
import 'package:mobile/data/models/module_model.dart';
import 'package:mobile/domain/repositories/student/student_module_repository.dart';
import 'package:mobile/utils/toast_helper.dart';

class StudentClassDetailViewModel extends ChangeNotifier {
  final StudentModuleRepository _repository;

  StudentClassDetailViewModel(this._repository);

  List<ModuleModel> _modules = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<ModuleModel> get modules => _modules;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch modules cho một lớp học
  Future<void> fetchModules(String classId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _modules = await _repository.getModulesByClass(classId);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      ToastHelper.showError(_error!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh lại danh sách modules
  Future<void> refresh(String classId) async {
    await fetchModules(classId);
  }

  /// Clear data
  void clear() {
    _modules = [];
    _error = null;
    notifyListeners();
  }
}
