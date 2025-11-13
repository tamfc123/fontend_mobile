import 'package:flutter/material.dart';
import 'package:mobile/data/models/class_schedule_model.dart';
import 'package:mobile/domain/repositories/schedule_repository.dart';
import 'package:mobile/utils/toast_helper.dart';

class ScheduleService extends ChangeNotifier {
  final ScheduleRepository _scheduleRepository;
  ScheduleService(this._scheduleRepository);

  List<ClassScheduleModel> _schedules = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Bộ lọc
  String _searchTeacher = '';
  int? _filterDayOfWeek;

  List<ClassScheduleModel> get schedules => _schedules;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // === Fetch danh sách ===
  Future<void> fetchSchedules() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 5. GỌI REPOSITORY
      _schedules = await _scheduleRepository.getAllSchedules(
        teacherName: _searchTeacher.isNotEmpty ? _searchTeacher : null,
        dayOfWeek: _filterDayOfWeek,
      );
    } catch (e) {
      _errorMessage =
          'Lỗi khi tải lịch học: ${e.toString().replaceFirst('Exception: ', '')}';
      ToastHelper.showError(_errorMessage!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // === Cập nhật filter ===
  void updateSearchTeacher(String value) {
    _searchTeacher = value;
    fetchSchedules();
  }

  void updateFilterDay(int? dayOfWeek) {
    _filterDayOfWeek = dayOfWeek;
    fetchSchedules();
  }

  // === CRUD ===
  Future<bool> createSchedule(ClassScheduleModel schedule) async {
    try {
      // 6. GỌI REPOSITORY
      await _scheduleRepository.createSchedule(schedule);
      await fetchSchedules();
      ToastHelper.showSucess('Tạo lịch học thành công');
      return true;
    } catch (e) {
      ToastHelper.showError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  Future<bool> updateSchedule(int id, ClassScheduleModel schedule) async {
    try {
      // 7. GỌI REPOSITORY
      await _scheduleRepository.updateSchedule(id, schedule);
      await fetchSchedules();
      ToastHelper.showSucess('Cập nhật lịch học thành công');
      return true;
    } catch (e) {
      ToastHelper.showError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  Future<bool> deleteSchedule(int id) async {
    try {
      // 8. GỌI REPOSITORY
      await _scheduleRepository.deleteSchedule(id);
      _schedules.removeWhere((s) => s.id == id);
      notifyListeners();
      ToastHelper.showSucess('Xóa lịch học thành công');
      return true;
    } catch (e) {
      ToastHelper.showError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }
}
