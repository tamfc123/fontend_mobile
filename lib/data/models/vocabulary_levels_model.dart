class VocabularyLevelsModel {
  final int currentUserLevel;
  final List<LevelInfoModel> levels;

  VocabularyLevelsModel({required this.currentUserLevel, required this.levels});

  factory VocabularyLevelsModel.fromJson(Map<String, dynamic> json) {
    var levelsList = json['levels'] as List;
    List<LevelInfoModel> levels =
        levelsList.map((i) => LevelInfoModel.fromJson(i)).toList();

    return VocabularyLevelsModel(
      currentUserLevel: json['currentUserLevel'],
      levels: levels,
    );
  }
}

class LevelInfoModel {
  final String id;
  final String name;
  final int level; // ✅ MỚI: Hứng số level (1, 2, 3...)
  final bool isLocked;

  LevelInfoModel({
    required this.id,
    required this.name,
    required this.level,
    required this.isLocked,
  });

  factory LevelInfoModel.fromJson(Map<String, dynamic> json) {
    return LevelInfoModel(
      id: json['id'],
      name: json['name'],
      // ✅ Map level, default là 1 nếu null
      level: json['level'] ?? json['Level'] ?? 1,
      // ✅ Map isLocked chuẩn (check cả viết hoa/thường)
      isLocked: json['isLocked'] ?? json['IsLocked'] ?? true,
    );
  }
}
