import 'package:flutter/material.dart';
import 'package:mobile/data/models/admin_chart_data_model.dart';
import 'package:mobile/data/models/admin_dashboard_stats_model.dart';
import 'package:mobile/data/models/admin_pie_chart_model.dart';
import 'package:mobile/data/models/admin_recent_teacher_model.dart';
import 'package:mobile/data/models/admin_top_student_model.dart';
import 'package:mobile/domain/repositories/admin_dashboard_repository.dart';

class AdminDashboardService extends ChangeNotifier {
  final AdminDashboardRepository _repository;
  AdminDashboardService(this._repository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  AdminDashboardStatsModel? _stats;
  AdminDashboardStatsModel? get stats => _stats;

  List<AdminChartDataModel> _userChartData = [];
  List<AdminChartDataModel> get userChartData => _userChartData;

  List<AdminPieChartModel> _skillPieData = [];
  List<AdminPieChartModel> get skillPieData => _skillPieData;

  List<AdminRecentTeacherModel> _recentTeachers = [];
  List<AdminRecentTeacherModel> get recentTeachers => _recentTeachers;

  List<AdminTopStudentModel> _topStudents = [];
  List<AdminTopStudentModel> get topStudents => _topStudents;

  Future<void> fetchDashboardStats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Chạy cả 2 API song song để tiết kiệm thời gian
      final statsTask = _repository.getDashboardStats();
      final userChartTask = _repository.getNewUsersChart();
      final skillPieTask = _repository.getQuizSkillDistribution();
      final recentTeachersTask = _repository.getRecentTeachers();
      final topStudentsTask = _repository.getTopStudents();

      await Future.wait([
        statsTask,
        userChartTask,
        skillPieTask,
        recentTeachersTask,
        topStudentsTask,
      ]);

      _stats = await statsTask;
      _userChartData = await userChartTask;
      _skillPieData = await skillPieTask;
      _recentTeachers = await recentTeachersTask;
      _topStudents = await topStudentsTask;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
