class LeaderboardItemModel {
  final int rank;
  final String userId; // Guid từ C# là String trong Dart
  final String name;
  final String? avatarUrl;
  final int level;
  final int score; // Chung cho XP hoặc Coins

  LeaderboardItemModel({
    required this.rank,
    required this.userId,
    required this.name,
    this.avatarUrl,
    required this.level,
    required this.score,
  });

  factory LeaderboardItemModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardItemModel(
      rank: json['rank'],
      userId: json['userId'],
      name: json['name'],
      avatarUrl: json['avatarUrl'],
      level: json['level'],
      score: json['score'],
    );
  }
}

class LeaderboardResponseModel {
  final List<LeaderboardItemModel> topRankings;
  final LeaderboardItemModel? currentUserRank;

  LeaderboardResponseModel({required this.topRankings, this.currentUserRank});

  factory LeaderboardResponseModel.fromJson(Map<String, dynamic> json) {
    var topList = json['topRankings'] as List? ?? [];
    List<LeaderboardItemModel> rankings =
        topList.map((i) => LeaderboardItemModel.fromJson(i)).toList();

    return LeaderboardResponseModel(
      topRankings: rankings,
      // Kiểm tra nếu currentUserRank có tồn tại trong JSON không
      currentUserRank:
          json['currentUserRank'] != null
              ? LeaderboardItemModel.fromJson(json['currentUserRank'])
              : null,
    );
  }
}
