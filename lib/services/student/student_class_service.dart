import 'package:flutter/material.dart';
import 'package:mobile/data/models/student_class_model.dart';
import 'package:mobile/domain/repositories/student_class_repository.dart';
import 'package:mobile/utils/toast_helper.dart';

class StudentClassService extends ChangeNotifier {
  final StudentClassRepository _classRepository;
  StudentClassService(this._classRepository);

  List<StudentClassModel> _joinedClasses = [];
  bool _isLoading = false;
  String? _error;

  List<StudentClassModel> get joinedClasses => _joinedClasses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load danh sách lớp đã tham gia
  Future<void> loadJoinedClasses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 6. GỌI REPOSITORY
      _joinedClasses = await _classRepository.getJoinedClasses();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      ToastHelper.showError(_error!); // Thêm toast
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Rời lớp
  Future<bool> leaveClass(int classId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 7. GỌI REPOSITORY
      await _classRepository.leaveClass(classId);

      // Tối ưu: Xóa khỏi list thay vì fetch lại
      _joinedClasses.removeWhere((c) => c.classId == classId);
      ToastHelper.showSucess('Rời lớp thành công'); // Thêm toast
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      ToastHelper.showError(_error!); // Thêm toast
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _joinedClasses = [];
    _error = null;
    notifyListeners();
  }
}
