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
}
