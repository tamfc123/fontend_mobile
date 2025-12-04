import 'package:flutter/foundation.dart';
import 'package:mobile/data/models/student_class_model.dart';
import 'package:mobile/domain/repositories/student/student_class_repository.dart';
import 'package:mobile/utils/toast_helper.dart';

class StudentClassesViewModel extends ChangeNotifier {
  final StudentClassRepository _repository;

  StudentClassesViewModel(this._repository);

  List<StudentClassModel> _joinedClasses = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<StudentClassModel> get joinedClasses => _joinedClasses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load danh sách lớp học đã tham gia
  Future<void> loadClasses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _joinedClasses = await _repository.getJoinedClasses();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      ToastHelper.showError(_error!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Rời khỏi lớp học
  Future<void> leaveClass(String classId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.leaveClass(classId);
      _joinedClasses.removeWhere((c) => c.classId == classId);
      ToastHelper.showSuccess('Rời lớp thành công');
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      ToastHelper.showError(_error!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh lại danh sách
  Future<void> refresh() async {
    await loadClasses();
  }

  /// Clear data
  void clear() {
    _joinedClasses = [];
    _error = null;
    notifyListeners();
  }
}
