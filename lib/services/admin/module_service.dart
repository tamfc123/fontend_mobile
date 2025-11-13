// ❌ XÓA: import 'dart:typed_data';
import 'package:flutter/material.dart';
// ✅ 1. IMPORT MODEL MỚI
import 'package:mobile/data/models/module_model.dart';
// ❌ XÓA: import 'package:mobile/data/models/upload_response_model.dart';
// ✅ 2. IMPORT REPO MỚI
import 'package:mobile/domain/repositories/module_repository.dart';
// ❌ XÓA: import 'package:mobile/domain/repositories/upload_repository.dart';
import 'package:mobile/utils/toast_helper.dart';
// ❌ XÓA: import 'package:url_launcher/url_launcher.dart';

// ✅ 3. ĐỔI TÊN CLASS
class ModuleService extends ChangeNotifier {
  // ✅ 4. SỬA REPOSITORY
  final ModuleRepository _moduleRepository;
  // ❌ 5. XÓA REPO UPLOAD
  // final UploadRepository _uploadRepository;

  // ✅ 6. SỬA CONSTRUCTOR
  ModuleService(this._moduleRepository);

  // ✅ 7. SỬA KIỂU DỮ LIỆU CỦA LIST
  List<ModuleModel> _modules = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ModuleModel> get modules => _modules;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ✅ 8. SỬA HÀM FETCH (DÙNG courseId)
  Future<void> fetchModules(int courseId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Gọi repository mới với courseId
      _modules = await _moduleRepository.getModulesByCourse(courseId);
    } catch (e) {
      _errorMessage =
          'Lỗi khi tải chương học: ${e.toString().replaceFirst('Exception: ', '')}';
      ToastHelper.showError(_errorMessage!);
      _modules = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ 9. SỬA HÀM ADD (DÙNG ModuleCreateModel)
  Future<bool> addModule(ModuleCreateModel module) async {
    try {
      await _moduleRepository.createModule(module);
      ToastHelper.showSucess('Thêm chương học thành công');
      // Fetch lại theo courseId
      await fetchModules(module.courseId);
      return true;
    } catch (e) {
      ToastHelper.showError(
        'Thêm chương học thất bại: ${e.toString().replaceFirst('Exception: ', '')}',
      );
      return false;
    }
  }

  // ✅ 10. SỬA HÀM UPDATE (DÙNG ModuleModel)
  Future<bool> updateModule(int id, ModuleModel module) async {
    try {
      await _moduleRepository.updateModule(id, module);
      ToastHelper.showSucess('Cập nhật chương học thành công');
      // Fetch lại theo courseId
      await fetchModules(module.courseId);
      return true;
    } catch (e) {
      ToastHelper.showError(
        'Cập nhật chương học thất bại: ${e.toString().replaceFirst('Exception: ', '')}',
      );
      return false;
    }
  }

  // ✅ 11. SỬA HÀM DELETE (DÙNG courseId)
  Future<bool> deleteModule(int id, int courseId) async {
    try {
      await _moduleRepository.deleteModule(id);
      ToastHelper.showSucess('Xóa chương học thành công');
      // Fetch lại theo courseId
      await fetchModules(courseId);
      return true;
    } catch (e) {
      ToastHelper.showError(
        'Xóa chương học thất bại: ${e.toString().replaceFirst('Exception: ', '')}',
      );
      return false;
    }
  }

  // ❌ 12. XÓA TOÀN BỘ CÁC HÀM VỀ FILE
  // (Xóa hàm openModuleFile)
  // (Xóa hàm uploadModuleFile)
}
