import 'package:flutter/material.dart';
import 'package:mobile/data/models/leaderboard_model.dart';
import 'package:mobile/domain/repositories/leaderboard_repository.dart';
import 'package:mobile/services/auth/auth_service.dart'; // Cần để biết ID người dùng

class LeaderboardService extends ChangeNotifier {
  final LeaderboardRepository _repository;
  final AuthService _authService; // Cần để so sánh ID

  LeaderboardService(this._repository, this._authService);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // Trạng thái filter
  String _selectedMetric = 'xp'; // 'xp' or 'coins'
  String get selectedMetric => _selectedMetric;

  // (API V1 chưa hỗtrợ 'period', nhưng UI vẫn cần)
  String _selectedPeriod = 'all-time';
  String get selectedPeriod => _selectedPeriod;

  // Dữ liệu
  List<LeaderboardItemModel> _topRankings = [];
  List<LeaderboardItemModel> get topRankings => _topRankings;

  LeaderboardItemModel? _currentUserRank;
  LeaderboardItemModel? get currentUserRank => _currentUserRank;

  // Helper để UI check xem có phải user hiện tại không
  bool isCurrentUser(String userId) {
    return _authService.currentUser?.id == userId;
  }

  // Lấy Top 3 (cho podium)
  List<LeaderboardItemModel> get top3 {
    if (_topRankings.length >= 3) {
      return [
        _topRankings[1],
        _topRankings[0],
        _topRankings[2],
      ]; // [Hạng 2, Hạng 1, Hạng 3]
    }
    return []; // Không đủ 3 người
  }

  // Lấy phần còn lại (từ hạng 4)
  List<LeaderboardItemModel> get others {
    if (_topRankings.length > 3) {
      return _topRankings.sublist(3);
    }
    return [];
  }

  Future<void> fetchLeaderboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // (V1: Bỏ qua _selectedPeriod, luôn lấy 'all-time')
      final response = await _repository.getLeaderboard(_selectedMetric);

      _topRankings = response.topRankings;
      _currentUserRank = response.currentUserRank;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _topRankings = [];
      _currentUserRank = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Được gọi khi nhấn chip "XP" hoặc "Coins"
  void setMetric(String metric) {
    if (_selectedMetric == metric) return;
    _selectedMetric = metric;
    notifyListeners();
    fetchLeaderboard(); // Tải lại dữ liệu theo metric mới
  }

  // Được gọi khi nhấn tab "Tuần" / "Tháng"
  void setPeriod(String period) {
    if (_selectedPeriod == period) return;
    _selectedPeriod = period;
    notifyListeners();
    // V1 API không hỗ trợ, nên chúng ta không gọi fetchLeaderboard()
    // Khi nâng cấp API, bạn sẽ gọi fetchLeaderboard() ở đây
  }
}
