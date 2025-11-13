import 'package:flutter/material.dart';
// ✅ 1. IMPORT MODEL MỚI
import 'package:mobile/data/models/module_model.dart';
import 'package:mobile/domain/repositories/student_module_repository.dart';
import 'package:mobile/utils/toast_helper.dart';

class StudentModuleService extends ChangeNotifier {
  final StudentModuleRepository _moduleRepository;
  StudentModuleService(this._moduleRepository);

  // ✅ 2. SỬA KIỂU DỮ LIỆU CỦA LIST
  List<ModuleModel> _modules = [];
  bool _isLoading = false;
  String? _error;

  // ✅ 3. SỬA KIỂU GETTER
  List<ModuleModel> get modules => _modules;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchModules(int classId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // ✅ 4. SỬA TÊN HÀM GỌI (repository của bạn tên là getModulesByClass)
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
