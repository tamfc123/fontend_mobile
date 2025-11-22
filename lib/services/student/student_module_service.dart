import 'package:flutter/material.dart';
import 'package:mobile/data/models/module_model.dart';
import 'package:mobile/domain/repositories/student_module_repository.dart';
import 'package:mobile/utils/toast_helper.dart';

class StudentModuleService extends ChangeNotifier {
  final StudentModuleRepository _moduleRepository;
  StudentModuleService(this._moduleRepository);

  List<ModuleModel> _modules = [];
  bool _isLoading = false;
  String? _error;

  List<ModuleModel> get modules => _modules;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchModules(String classId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _modules = await _moduleRepository.getModulesByClass(classId);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      ToastHelper.showError(_error!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _modules = [];
    _error = null;
    notifyListeners();
  }
}
