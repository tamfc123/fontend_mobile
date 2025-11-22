import 'package:flutter/material.dart';
import 'package:mobile/data/models/class_schedule_model.dart';
import 'package:mobile/domain/repositories/admin_schedule_repository.dart';
import 'package:mobile/utils/toast_helper.dart';

class AdminScheduleService extends ChangeNotifier {
  final AdminScheduleRepository _scheduleRepository;
  AdminScheduleService(this._scheduleRepository);

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
  Future<bool> createBulkSchedule({
    required String classId,
    required String teacherId,
    required DateTime rangeStartDate,
    required DateTime rangeEndDate,
    required List<WeeklySlotRequest> slots, // Import từ repository
  }) async {
    try {
      _isLoading = true; // Nên loading chút vì tạo bulk có thể lâu
      notifyListeners();

      await _scheduleRepository.createBulkSchedule(
        classId: classId,
        teacherId: teacherId,
        rangeStartDate: rangeStartDate,
        rangeEndDate: rangeEndDate,
        slots: slots,
      );

      await fetchSchedules(); // Load lại danh sách sau khi tạo
      ToastHelper.showSuccess('Xếp lịch thành công');
      return true;
    } catch (e) {
      debugPrint('Error in createBulkSchedule: $e');
      ToastHelper.showError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cập nhật (Vẫn giữ nguyên logic, nhưng lưu ý schedule truyền vào phải có roomId)
  Future<bool> updateSchedule(String id, ClassScheduleModel schedule) async {
    try {
      await _scheduleRepository.updateSchedule(id, schedule);
      await fetchSchedules();
      ToastHelper.showSuccess('Cập nhật lịch học thành công');
      return true;
    } catch (e) {
      ToastHelper.showError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  // Xóa
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
