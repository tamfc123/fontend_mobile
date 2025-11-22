import 'package:flutter/material.dart';
import 'package:mobile/data/models/teacher_dashboard_model.dart';
import 'package:mobile/domain/repositories/teaacher_dashboard_repository.dart';

class TeacherDashboardService extends ChangeNotifier {
  final TeaacherDashboardRepository _repository;
  TeacherDashboardService(this._repository);

  bool _isLoading = false;
  TeacherDashboardModel? _dashboardData;

  bool get isLoading => _isLoading;
  TeacherDashboardStatsModel? get stats => _dashboardData?.stats;
  List<TeacherUpcomingScheduleModel> get upcomingSchedules =>
      _dashboardData?.upcomingSchedules ?? [];
  List<TeacherQuickClassModel> get myClasses => _dashboardData?.myClasses ?? [];

  Future<void> fetchDashboardData() async {
    _isLoading = true;
    notifyListeners();
    try {
      _dashboardData = await _repository.getTeacherDashboardSummary();
    } catch (e) {
      debugPrint(e.toString());
      // (Bạn có thể thêm Toast ở đây)
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
