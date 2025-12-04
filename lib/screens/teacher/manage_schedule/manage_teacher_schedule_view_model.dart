import 'package:flutter/material.dart';
import 'package:mobile/data/models/teacher_schedule_model.dart';
import 'package:mobile/domain/repositories/teacher/teacher_schedule_repository.dart';
import 'package:mobile/utils/toast_helper.dart';

class ManageTeacherScheduleViewModel extends ChangeNotifier {
  final TeacherScheduleRepository _scheduleRepository;
  ManageTeacherScheduleViewModel(this._scheduleRepository);

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
