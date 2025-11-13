import 'package:flutter/material.dart';
import 'package:mobile/services/student/leaderboard_service.dart';
import 'package:mobile/data/models/leaderboard_model.dart'; // Import model thật
import 'package:provider/provider.dart';

class StudentLeaderboardScreen extends StatefulWidget {
  const StudentLeaderboardScreen({super.key});

  @override
  State<StudentLeaderboardScreen> createState() =>
      _StudentLeaderboardScreenState();
}

class _StudentLeaderboardScreenState extends State<StudentLeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    // Tải dữ liệu thật ngay khi vào màn hình
    Future.microtask(() {
      // Tải lần đầu (dùng metric 'xp' mặc định từ service)
      context.read<LeaderboardService>().fetchLeaderboard();
    });
  }

  // ❌ XÓA mock data: _mockLeaderboard
  // ❌ XÓA mock data: _currentUser
  // ❌ XÓA state: _selectedPeriod, _selectedMetric (Service sẽ quản lý)

  // Level configuration (Giữ nguyên)
  Map<String, dynamic> _getLevelConfig(int level) {
    switch (level) {
      case 1:
        return {'name': 'Beginner', 'color': Colors.teal};
      case 2:
        return {'name': 'Elementary', 'color': Colors.green};
      case 3:
        return {'name': 'Intermediate', 'color': Colors.blue};
      case 4:
        return {'name': 'Upper-Intermediate', 'color': Colors.purple};
      case 5:
        return {'name': 'Advanced', 'color': Colors.orange};
      case 6:
        return {'name': 'Master', 'color': Colors.amber};
      default:
        return {'name': 'Beginner', 'color': Colors.teal};
    }
  }

  // Get metric value (SỬA LẠI: dùng model và lấy metric từ service)
  String _getMetricValue(LeaderboardItemModel user, String selectedMetric) {
    switch (selectedMetric) {
      case 'xp':
        return '${user.score} XP';
      case 'coins':
        return '${user.score} xu';
      // (Streak chưa hỗ trợ ở V1)
      // case 'streak':
      //   return '${user.streak} ngày';
      default:
        return '${user.score} XP';
    }
  }

  // Get medal color for top 3 (Giữ nguyên)
  Color _getMedalColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber.shade600; // Gold
      case 2:
        return Colors.grey.shade400; // Silver
      case 3:
        return Colors.brown.shade400; // Bronze
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Lắng nghe service
    final service = context.watch<LeaderboardService>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F2937),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          // Sửa: Dùng GoRouter để pop nếu bạn đang dùng GoRouter
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Bảng xếp hạng",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: Column(
        children: [
          // Period filter tabs
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: _buildPeriodTab(
                    label: 'Tuần',
                    value: 'week',
                    isSelected: service.selectedPeriod == 'week',
                    onTap: (value) => service.setPeriod(value),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildPeriodTab(
                    label: 'Tháng',
                    value: 'month',
                    isSelected: service.selectedPeriod == 'month',
                    onTap: (value) => service.setPeriod(value),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildPeriodTab(
                    label: 'Mọi lúc',
                    value: 'all-time',
                    isSelected: service.selectedPeriod == 'all-time',
                    onTap: (value) => service.setPeriod(value),
                  ),
                ),
              ],
            ),
          ),

          // Metric filter chips
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildMetricChip(
                    icon: Icons.star_rounded,
                    label: 'Kinh nghiệm',
                    value: 'xp',
                    color: Colors.purple,
                    isSelected: service.selectedMetric == 'xp',
                    onSelected: (value) => service.setMetric(value),
                  ),
                  const SizedBox(width: 8),
                  _buildMetricChip(
                    icon: Icons.monetization_on_rounded,
                    label: 'Xu',
                    value: 'coins',
                    color: Colors.amber,
                    isSelected: service.selectedMetric == 'coins',
                    onSelected: (value) => service.setMetric(value),
                  ),
                  // (API V1 chưa hỗ trợ Streak, tạm ẩn đi)
                  // const SizedBox(width: 8),
                  // _buildMetricChip(
                  //   icon: Icons.local_fire_department_rounded,
                  //   label: 'Streak',
                  //   value: 'streak',
                  //   color: Colors.orange,
                  //   ...
                  // ),
                ],
              ),
            ),
          ),

          // 2. Hiển thị nội dung dựa trên state
          Expanded(child: _buildContentBody(service)),
        ],
      ),
    );
  }

  // Widget hiển thị nội dung chính (loading, error, data)
  Widget _buildContentBody(LeaderboardService service) {
    if (service.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (service.error != null) {
      return Center(
        child: Text(
          "Lỗi tải Bảng xếp hạng: ${service.error}",
          textAlign: TextAlign.center,
        ),
      );
    }
    if (service.topRankings.isEmpty) {
      return const Center(child: Text('Chưa có ai trên bảng xếp hạng.'));
    }

    // Dữ liệu thật
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Top 3 podium
        // Chỉ hiển thị podium nếu có đủ 3 người
        if (service.top3.isNotEmpty)
          _buildPodium(service.top3, service.selectedMetric),

        const SizedBox(height: 24),

        // Other ranks (Từ hạng 4 trở đi)
        ...service.others.map((user) {
          // Lấy ID user hiện tại
          final bool isCurrentUser = service.isCurrentUser(user.userId);
          return _buildLeaderboardItem(
            user,
            isCurrentUser,
            service.selectedMetric,
          );
        }),

        const SizedBox(height: 16),

        // Current user position
        // (Chỉ hiển thị nếu user có rank và không nằm trong Top)
        if (service.currentUserRank != null)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade600, Colors.blue.shade400],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: _buildLeaderboardItem(
              service.currentUserRank!,
              true,
              service.selectedMetric,
            ),
          ),

        const SizedBox(height: 24),
      ],
    );
  }

  // Period tab widget (SỬA LẠI: nhận onTap)
  Widget _buildPeriodTab({
    required String label,
    required String value,
    required bool isSelected,
    required Function(String) onTap, // <-- Thêm dòng này
  }) {
    return GestureDetector(
      onTap: () => onTap(value), // <-- Sửa dòng này
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade600 : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue.shade600 : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // Metric chip widget (SỬA LẠI: nhận onSelected)
  Widget _buildMetricChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isSelected, // <-- Thêm dòng này
    required Function(String) onSelected, // <-- Thêm dòng này
  }) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isSelected ? Colors.white : color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          onSelected(value); // <-- Sửa dòng này
        }
      },
      backgroundColor: Colors.white,
      selectedColor: color,
      checkmarkColor: Colors.white,
      side: BorderSide(
        color: isSelected ? color : color.withOpacity(0.3),
        width: 1.5,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  // Top 3 podium widget (SỬA LẠI: nhận List<model> và metric)
  Widget _buildPodium(List<LeaderboardItemModel> top3, String selectedMetric) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.emoji_events, color: Colors.amber, size: 28),
              SizedBox(width: 8),
              Text(
                'Top 3',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 2nd place (top3[0] là Hạng 2)
              _buildPodiumItem(top3[0], 2, selectedMetric),
              const SizedBox(width: 12),
              // 1st place (top3[1] là Hạng 1)
              _buildPodiumItem(top3[1], 1, selectedMetric),
              const SizedBox(width: 12),
              // 3rd place (top3[2] là Hạng 3)
              _buildPodiumItem(top3[2], 3, selectedMetric),
            ],
          ),
        ],
      ),
    );
  }

  // Podium item widget (SỬA LẠI: nhận model)
  Widget _buildPodiumItem(
    LeaderboardItemModel user,
    int rank,
    String selectedMetric,
  ) {
    final height =
        rank == 1
            ? 120.0
            : rank == 2
            ? 100.0
            : 90.0;
    final medalColor = _getMedalColor(rank);
    final levelConfig = _getLevelConfig(user.level);

    return Expanded(
      child: Column(
        children: [
          // Avatar with medal
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: medalColor, width: 3),
                ),
                child: CircleAvatar(
                  radius: rank == 1 ? 36 : 32,
                  backgroundImage:
                      user.avatarUrl != null
                          ? NetworkImage(user.avatarUrl!) // Dùng model
                          // Placeholder nếu user không có avatar
                          : const AssetImage(
                                'assets/images/avatar_placeholder.png',
                              )
                              as ImageProvider,
                ),
              ),
              Positioned(
                top: -8,
                right: -8,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: medalColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Text(
                    '$rank',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            user.name.split(' ').last, // Dùng model
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            _getMetricValue(user, selectedMetric), // Dùng model
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          // Podium base
          Container(
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  medalColor.withOpacity(0.3),
                  medalColor.withOpacity(0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Center(
              child: Icon(
                rank == 1
                    ? Icons.emoji_events
                    : rank == 2
                    ? Icons.military_tech
                    : Icons.workspace_premium,
                color: medalColor,
                size: rank == 1 ? 40 : 32,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Leaderboard item widget (SỬA LẠI: nhận model)
  Widget _buildLeaderboardItem(
    LeaderboardItemModel user,
    bool isCurrentUser,
    String selectedMetric,
  ) {
    final levelConfig = _getLevelConfig(user.level); // Dùng model
    final levelColor = levelConfig['color'] as Color;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        // Viền xanh đặc biệt cho user hiện tại
        border:
            isCurrentUser
                ? Border.all(color: Colors.blue.shade600, width: 2)
                : null,
      ),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCurrentUser ? Colors.blue.shade50 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '#${user.rank}', // Dùng model
                style: TextStyle(
                  color:
                      isCurrentUser
                          ? Colors.blue.shade700
                          : Colors.grey.shade700,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Avatar
          Stack(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage:
                    user.avatarUrl != null
                        ? NetworkImage(user.avatarUrl!) // Dùng model
                        // Placeholder nếu user không có avatar
                        : const AssetImage(
                              'assets/images/avatar_placeholder.png',
                            )
                            as ImageProvider,
              ),
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: levelColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Text(
                    '${user.level}', // Dùng model
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          // Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name, // Dùng model
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color:
                        isCurrentUser
                            ? Colors.blue.shade700
                            : const Color(0xFF1F2937),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  levelConfig['name'],
                  style: TextStyle(
                    fontSize: 12,
                    color: levelColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Metric value
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isCurrentUser ? Colors.blue.shade50 : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _getMetricValue(user, selectedMetric), // Dùng model
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color:
                    isCurrentUser ? Colors.blue.shade700 : Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
