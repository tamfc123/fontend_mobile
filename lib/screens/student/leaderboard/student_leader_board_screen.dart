import 'package:flutter/material.dart';
import 'package:mobile/screens/student/leaderboard/student_leaderboard_view_model.dart';
import 'package:mobile/services/auth/auth_service.dart';
import 'package:mobile/data/models/leaderboard_model.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentLeaderboardViewModel>().loadLeaderboard();
    });
  }

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

  // ✅ CẬP NHẬT: Hiển thị đúng đơn vị dựa trên Metric
  String _getMetricValue(LeaderboardItemModel user, String selectedMetric) {
    switch (selectedMetric) {
      case 'xp':
        return '${user.score} XP';
      case 'coins':
        return '${user.score} xu';
      case 'streak':
        return '${user.score} ngày'; // Backend đã map streak vào score
      default:
        return '${user.score}';
    }
  }

  Color _getMedalColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber.shade600;
      case 2:
        return Colors.grey.shade400;
      case 3:
        return Colors.brown.shade400;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<StudentLeaderboardViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F2937),
        centerTitle: true,
        title: const Text(
          "Bảng xếp hạng",
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
      ),
      body: Column(
        children: [
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
                  const SizedBox(width: 8),
                  // ✅ ĐÃ BẬT LẠI STREAK (Vì backend đã hỗ trợ)
                  _buildMetricChip(
                    icon: Icons.local_fire_department_rounded,
                    label: 'Chuỗi ngày',
                    value: 'streak',
                    color: Colors.deepOrange,
                    isSelected: service.selectedMetric == 'streak',
                    onSelected: (value) => service.setMetric(value),
                  ),
                ],
              ),
            ),
          ),

          // Nội dung chính
          Expanded(child: _buildContentBody(service)),
        ],
      ),
    );
  }

  Widget _buildContentBody(StudentLeaderboardViewModel service) {
    if (service.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (service.error != null) {
      return Center(child: Text("Lỗi: ${service.error}"));
    }
    if (service.topRankings.isEmpty) {
      return const Center(child: Text('Chưa có ai trên bảng xếp hạng.'));
    }

    final authService = context.watch<AuthService>();
    final currentUserId = authService.currentUser?.id;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Top 3 podium (Service của bạn đã xử lý logic top3 an toàn chưa? Nếu rồi thì dùng)
        if (service
            .top3Items
            .isNotEmpty) // Dùng getter top3Items từ Service mới
          _buildPodium(service.top3Items, service.selectedMetric),

        const SizedBox(height: 24),

        // Other ranks (Hạng 4 trở đi)
        ...service.otherItems.map((user) {
          // Dùng getter otherItems từ Service mới
          final bool isCurrentUser = user.userId == currentUserId;
          return _buildLeaderboardItem(
            user,
            isCurrentUser,
            service.selectedMetric,
          );
        }),

        const SizedBox(height: 16),

        // Current user position (Sticky bottom logic nếu cần, hoặc để cuối list)
        if (service.currentUserRank != null) ...[
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              "Hạng của bạn:",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
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
        ],

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildMetricChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isSelected,
    required Function(String) onSelected,
  }) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: isSelected ? Colors.white : color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : color,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) onSelected(value);
      },
      backgroundColor: Colors.white,
      selectedColor: color,
      checkmarkColor: Colors.white,
      side: BorderSide(
        color: isSelected ? color : color.withOpacity(0.2),
        width: 1.5,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      showCheckmark: false,
    );
  }

  Widget _buildPodium(List<LeaderboardItemModel> top3, String selectedMetric) {
    if (top3.isEmpty) return const SizedBox.shrink();

    // Xử lý an toàn nếu list < 3
    LeaderboardItemModel? rank1 = top3.isNotEmpty ? top3[0] : null;
    LeaderboardItemModel? rank2 = top3.length > 1 ? top3[1] : null;
    LeaderboardItemModel? rank3 = top3.length > 2 ? top3[2] : null;

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
              if (rank2 != null)
                Expanded(child: _buildPodiumItem(rank2, 2, selectedMetric)),
              const SizedBox(width: 8),
              if (rank1 != null)
                Expanded(
                  child: _buildPodiumItem(rank1, 1, selectedMetric),
                ), // Rank 1 to hơn
              const SizedBox(width: 8),
              if (rank3 != null)
                Expanded(child: _buildPodiumItem(rank3, 3, selectedMetric)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumItem(
    LeaderboardItemModel user,
    int rank,
    String selectedMetric,
  ) {
    final height = rank == 1 ? 130.0 : (rank == 2 ? 110.0 : 100.0);
    final medalColor = _getMedalColor(rank);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: medalColor, width: 3),
              ),
              child: CircleAvatar(
                radius: rank == 1 ? 32 : 26,
                backgroundImage:
                    user.avatarUrl != null
                        ? NetworkImage(user.avatarUrl!)
                        : null,
                child: user.avatarUrl == null ? Text(user.name[0]) : null,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: medalColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white),
              ),
              child: Text(
                '$rank',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          user.name.split(' ').last,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          _getMetricValue(user, selectedMetric),
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: medalColor.withOpacity(0.2),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            border: Border(top: BorderSide(color: medalColor, width: 3)),
          ),
          alignment: Alignment.center,
          child: Text(
            '$rank',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: medalColor.withOpacity(0.4),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardItem(
    LeaderboardItemModel user,
    bool isCurrentUser,
    String selectedMetric,
  ) {
    final levelConfig = _getLevelConfig(user.level);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isCurrentUser ? Colors.blue.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isCurrentUser ? Border.all(color: Colors.blue.shade300) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              '#${user.rank}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 20,
            backgroundImage:
                user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
            child: user.avatarUrl == null ? Text(user.name[0]) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color:
                        isCurrentUser ? Colors.blue.shade800 : Colors.black87,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: (levelConfig['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        levelConfig['name'],
                        style: TextStyle(
                          fontSize: 10,
                          color: levelConfig['color'],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Lv.${user.level}',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            _getMetricValue(user, selectedMetric),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isCurrentUser ? Colors.blue : Colors.amber.shade800,
            ),
          ),
        ],
      ),
    );
  }
}
