import 'package:flutter/material.dart';
import 'package:mobile/data/models/student_schedule_model.dart';
import 'package:mobile/domain/repositories/student_schedule_repository.dart';
import 'package:mobile/utils/toast_helper.dart';

class StudentScheduleService extends ChangeNotifier {
  final StudentScheduleRepository _scheduleRepository;
  StudentScheduleService(this._scheduleRepository);

  List<StudentScheduleModel> _schedules = [];
  bool _isLoading = false;
  String? _error;

  List<StudentScheduleModel> get schedules => _schedules;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchSchedules({int? dayOfWeek}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 5. GỌI REPOSITORY
      _schedules = await _scheduleRepository.getStudentSchedules(
        dayOfWeek: dayOfWeek,
      );
    } catch (e) {
      _error =
          'Không thể tải lịch học: ${e.toString().replaceFirst('Exception: ', '')}';
      ToastHelper.showError(_error!);
      _schedules = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
