import 'package:flutter/material.dart';
import 'package:mobile/data/models/teacher_schedule_model.dart';
import 'package:mobile/domain/repositories/teacher_schedule_repository.dart';
import 'package:mobile/utils/toast_helper.dart';

class TeacherScheduleService extends ChangeNotifier {
  final TeacherScheduleRepository _scheduleRepository;
  TeacherScheduleService(this._scheduleRepository);

  List<TeacherScheduleModel> _schedules = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<TeacherScheduleModel> get schedules => _schedules;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Hàm này hỗ trợ truyền các điều kiện lọc như thứ, lớp, môn học
  Future<void> fetchSchedules({int? dayOfWeek}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 5. GỌI REPOSITORY
      _schedules = await _scheduleRepository.getTeacherSchedules(
        dayOfWeek: dayOfWeek,
      );
    } catch (e) {
      _errorMessage =
          'Lỗi khi tải lịch dạy: ${e.toString().replaceFirst('Exception: ', '')}';
      ToastHelper.showError(_errorMessage!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createSchedule(Map<String, dynamic> scheduleJson) async {
    try {
      // 6. GỌI REPOSITORY (Không cần check 'success' nữa)
      await _scheduleRepository.createTeacherSchedule(scheduleJson);

      await fetchSchedules();
      ToastHelper.showSucess('Tạo lịch giảng dạy thành công');
      return true;
    } catch (e) {
      ToastHelper.showError(
        'Lỗi khi tạo lịch: ${e.toString().replaceFirst('Exception: ', '')}',
      );
      return false;
    }
  }

  Future<bool> updateSchedule(int id, Map<String, dynamic> scheduleJson) async {
    try {
      // 7. GỌI REPOSITORY
      await _scheduleRepository.updateTeacherSchedule(id, scheduleJson);

      await fetchSchedules();
      ToastHelper.showSucess('Cập nhật lịch giảng dạy thành công');
      return true;
    } catch (e) {
      ToastHelper.showError(
        'Lỗi khi cập nhật: ${e.toString().replaceFirst('Exception: ', '')}',
      );
      return false;
    }
  }

  Future<void> deleteSchedule(int id) async {
    try {
      // 8. GỌI REPOSITORY
      await _scheduleRepository.deleteTeacherSchedule(id);

      _schedules.removeWhere((s) => s.id == id);
      notifyListeners();
      ToastHelper.showSucess('Xoá lịch thành công');
    } catch (e) {
      ToastHelper.showError(
        'Lỗi khi xoá lịch: ${e.toString().replaceFirst('Exception: ', '')}',
      );
    }
  }
}
