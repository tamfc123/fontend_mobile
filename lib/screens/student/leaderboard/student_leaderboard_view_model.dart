import 'package:flutter/material.dart';
import 'package:mobile/data/models/leaderboard_model.dart';
import 'package:mobile/domain/repositories/student/student_leaderboard_repository.dart';

class StudentLeaderboardViewModel extends ChangeNotifier {
  final StudentLeaderboardRepository _repository;

  StudentLeaderboardViewModel(this._repository);

  bool _isLoading = false;
  String? _error;
  String _selectedMetric = 'xp';
  String _selectedPeriod = 'all-time';

  List<LeaderboardItemModel> _topRankings = [];
  LeaderboardItemModel? _currentUserRank;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedMetric => _selectedMetric;
  String get selectedPeriod => _selectedPeriod;
  List<LeaderboardItemModel> get topRankings => _topRankings;
  LeaderboardItemModel? get currentUserRank => _currentUserRank;

  // Get top 3 for podium display
  List<LeaderboardItemModel> get top3Items {
    if (_topRankings.isEmpty) return [];
    return _topRankings.take(3).toList();
  }

  // Get remaining items (rank 4+)
  List<LeaderboardItemModel> get otherItems {
    if (_topRankings.length > 3) {
      return _topRankings.sublist(3);
    }
    return [];
  }

  Future<void> loadLeaderboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.getLeaderboard(_selectedMetric);
      _topRankings = response.topRankings;
      _currentUserRank = response.currentUserRank;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _topRankings = [];
      _currentUserRank = null;
      debugPrint('Error loading leaderboard: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setMetric(String metric) {
    if (_selectedMetric == metric) return;
    _selectedMetric = metric;
    notifyListeners();
    loadLeaderboard();
  }

  void setPeriod(String period) {
    if (_selectedPeriod == period) return;
    _selectedPeriod = period;
    notifyListeners();
    // Backend doesn't support period filtering yet
  }
}
