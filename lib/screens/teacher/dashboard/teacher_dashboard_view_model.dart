import 'package:flutter/material.dart';
import 'package:mobile/data/models/teacher_dashboard_model.dart';
import 'package:mobile/domain/repositories/teacher/teaacher_dashboard_repository.dart';

class TeacherDashboardViewModel extends ChangeNotifier {
  final TeaacherDashboardRepository _repository;

  TeacherDashboardViewModel(this._repository);

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
      debugPrint('Error fetching teacher dashboard data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
