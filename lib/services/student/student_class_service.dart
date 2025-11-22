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
      _joinedClasses = await _classRepository.getJoinedClasses();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      ToastHelper.showError(_error!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> joinClass(String classId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _classRepository.joinClass(classId);
      await loadJoinedClasses();

      ToastHelper.showSuccess('Tham gia lớp thành công');
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      ToastHelper.showError(_error!);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Rời lớp học
  Future<bool> leaveClass(String classId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _classRepository.leaveClass(classId);
      _joinedClasses.removeWhere((c) => c.classId == classId);

      ToastHelper.showSuccess('Rời lớp thành công');
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      ToastHelper.showError(_error!);
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
