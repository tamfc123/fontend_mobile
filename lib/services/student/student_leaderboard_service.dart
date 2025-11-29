import 'package:flutter/material.dart';
import 'package:mobile/data/models/leaderboard_model.dart';
import 'package:mobile/domain/repositories/student_leaderboard_repository.dart';
import 'package:mobile/services/auth/auth_service.dart';

class StudentLeaderboardService extends ChangeNotifier {
  final StudentLeaderboardRepository _repository;
  final AuthService _authService;

  StudentLeaderboardService(this._repository, this._authService);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // Trạng thái filter: 'xp', 'coins', hoặc 'streak'
  String _selectedMetric = 'xp';
  String get selectedMetric => _selectedMetric;

  // Period (Backend chưa hỗ trợ, nhưng giữ UI cũng được)
  String _selectedPeriod = 'all-time';
  String get selectedPeriod => _selectedPeriod;

  List<LeaderboardItemModel> _topRankings = [];

  // Getter cho danh sách đầy đủ
  List<LeaderboardItemModel> get topRankings => _topRankings;

  LeaderboardItemModel? _currentUserRank;
  LeaderboardItemModel? get currentUserRank => _currentUserRank;

  bool isCurrentUser(String userId) {
    return _authService.currentUser?.id == userId;
  }

  // ✅ LOGIC MỚI: Lấy Top 3 an toàn hơn
  // Trả về danh sách theo thứ tự bình thường [1, 2, 3]
  // Việc sắp xếp vị trí bục (2 - 1 - 3) nên để UI (Widget) xử lý
  List<LeaderboardItemModel> get top3Items {
    if (_topRankings.isEmpty) return [];
    return _topRankings.take(3).toList();
  }

  // ✅ LOGIC MỚI: Lấy danh sách còn lại (Từ hạng 4 trở đi)
  List<LeaderboardItemModel> get otherItems {
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
      // Gọi API với metric hiện tại (xp, coins, streak)
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

  // ✅ Cập nhật khi chọn Chip: XP / Coins / Streak
  void setMetric(String metric) {
    if (_selectedMetric == metric) return;
    _selectedMetric = metric;
    notifyListeners();
    fetchLeaderboard(); // Gọi lại API để lấy dữ liệu mới
  }

  void setPeriod(String period) {
    if (_selectedPeriod == period) return;
    _selectedPeriod = period;
    notifyListeners();
    // Backend chưa hỗ trợ filter theo tuần/tháng nên chưa gọi API lại
  }
}
