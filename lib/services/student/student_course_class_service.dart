import 'package:flutter/material.dart';
import 'package:mobile/data/models/student_class_model.dart';
import 'package:mobile/domain/repositories/student_course_repository.dart';
import 'package:mobile/utils/toast_helper.dart';

class StudentCourseClassService extends ChangeNotifier {
  final StudentCourseRepository _studentCourseRepository;
  StudentCourseClassService(this._studentCourseRepository);

  List<StudentClassModel> _classes = [];
  bool _isLoading = false;
  String? _error;

  List<StudentClassModel> get classes => _classes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Lấy danh sách lớp theo courseId
  Future<void> fetchClasses(int courseId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 6. GỌI REPOSITORY
      // Repository đã trả về List<StudentClassModel> đã map
      final data = await _studentCourseRepository.getClassesByCourse(courseId);

      // ✅ Sửa lỗi logic: Gán trực tiếp, không cần map lại
      _classes = data;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      ToastHelper.showError(_error!); // Thêm toast
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Tham gia lớp
  Future<bool> joinClass(int classId) async {
    try {
      // 7. GỌI REPOSITORY
      await _studentCourseRepository.joinClass(classId);

      _classes.removeWhere((c) => c.classId == classId);
      notifyListeners();
      ToastHelper.showSucess('Tham gia lớp thành công'); // Thêm toast
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      ToastHelper.showError(_error!); // Thêm toast
      notifyListeners();
      return false;
    }
  }
}
