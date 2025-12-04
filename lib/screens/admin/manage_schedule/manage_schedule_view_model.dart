import 'package:flutter/material.dart';
import 'package:mobile/data/models/class_schedule_model.dart';
import 'package:mobile/data/models/room_model.dart';
import 'package:mobile/domain/repositories/admin/admin_room_repository.dart';
import 'package:mobile/domain/repositories/admin/admin_schedule_repository.dart';
import 'package:mobile/utils/toast_helper.dart';

class ManageScheduleViewModel extends ChangeNotifier {
  final AdminScheduleRepository _scheduleRepository;
  final AdminRoomRepository _roomRepository;

  ManageScheduleViewModel(this._scheduleRepository, this._roomRepository);

  List<ClassScheduleModel> _schedules = [];
  List<RoomModel> _activeRooms = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Filters
  String _searchTeacher = '';
  int? _filterDayOfWeek;

  List<ClassScheduleModel> get schedules => _schedules;
  List<RoomModel> get activeRooms => _activeRooms;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchTeacher => _searchTeacher;
  int? get filterDayOfWeek => _filterDayOfWeek;

  Future<void> loadData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.wait([_fetchSchedules(), _fetchActiveRooms()]);
    } catch (e) {
      _errorMessage =
          'Lỗi khi tải dữ liệu: ${e.toString().replaceFirst('Exception: ', '')}';
      ToastHelper.showError(_errorMessage!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchSchedules() async {
    _schedules = await _scheduleRepository.getAllSchedules(
      teacherName: _searchTeacher.isNotEmpty ? _searchTeacher : null,
      dayOfWeek: _filterDayOfWeek,
    );
  }

  Future<void> _fetchActiveRooms() async {
    _activeRooms = await _roomRepository.getAllActiveRooms();
  }

  void updateSearchTeacher(String value) {
    if (_searchTeacher != value) {
      _searchTeacher = value;
      _refreshSchedules();
    }
  }

  void updateFilterDay(int? dayOfWeek) {
    if (_filterDayOfWeek != dayOfWeek) {
      _filterDayOfWeek = dayOfWeek;
      _refreshSchedules();
    }
  }

  Future<void> _refreshSchedules() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _fetchSchedules();
    } catch (e) {
      ToastHelper.showError('Lỗi tải lịch học: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateSchedule(String id, ClassScheduleModel schedule) async {
    try {
      await _scheduleRepository.updateSchedule(id, schedule);
      await _refreshSchedules();
      ToastHelper.showSuccess('Cập nhật lịch học thành công');
      return true;
    } catch (e) {
      ToastHelper.showError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  Future<bool> deleteSchedule(String id) async {
    try {
      await _scheduleRepository.deleteSchedule(id);
      _schedules.removeWhere((s) => s.id == id);
      notifyListeners();
      ToastHelper.showSuccess('Xóa lịch học thành công');
      return true;
    } catch (e) {
      ToastHelper.showError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }
}
