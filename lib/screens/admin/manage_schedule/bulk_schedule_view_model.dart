import 'package:flutter/material.dart';
import 'package:mobile/data/models/class_model.dart';
import 'package:mobile/data/models/room_model.dart';
import 'package:mobile/domain/repositories/admin/admin_class_repository.dart';
import 'package:mobile/domain/repositories/admin/admin_room_repository.dart';
import 'package:mobile/domain/repositories/admin/admin_schedule_repository.dart';
import 'package:mobile/utils/toast_helper.dart';

class BulkScheduleViewModel extends ChangeNotifier {
  final AdminScheduleRepository _scheduleRepository;
  final AdminClassRepository _classRepository;
  final AdminRoomRepository _roomRepository;

  BulkScheduleViewModel(
    this._scheduleRepository,
    this._classRepository,
    this._roomRepository,
  );

  List<ClassModel> _classes = [];
  List<RoomModel> _rooms = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ClassModel> get classes => _classes;
  List<RoomModel> get rooms => _rooms;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadInitialData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _classRepository.getAllActiveClasses(),
        _roomRepository.getAllActiveRooms(),
      ]);
      _classes = results[0] as List<ClassModel>;
      _rooms = results[1] as List<RoomModel>;
    } catch (e) {
      _errorMessage = 'Lỗi tải dữ liệu: ${e.toString()}';
      ToastHelper.showError(_errorMessage!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createBulkSchedule({
    required String classId,
    required String teacherId,
    required DateTime rangeStartDate,
    required DateTime rangeEndDate,
    required List<WeeklySlotRequest> slots,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _scheduleRepository.createBulkSchedule(
        classId: classId,
        teacherId: teacherId,
        rangeStartDate: rangeStartDate,
        rangeEndDate: rangeEndDate,
        slots: slots,
      );
      ToastHelper.showSuccess('Xếp lịch thành công');
      return true;
    } catch (e) {
      ToastHelper.showError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
