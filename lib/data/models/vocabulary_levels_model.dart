// file: data/models/vocabulary_levels_model.dart

// 1. Model cho 1 Level (khớp LevelInfoDTO)
class LevelInfoModel {
  final int id; // CourseId
  final String name; // "A1 - Cơ bản"
  final bool isLocked;

  LevelInfoModel({
    required this.id,
    required this.name,
    required this.isLocked,
  });

  factory LevelInfoModel.fromJson(Map<String, dynamic> json) {
    return LevelInfoModel(
      id: json['id'],
      name: json['name'],
      isLocked: json['isLocked'],
    );
  }
}

// 2. Model cho toàn bộ API response (khớp VocabularyLevelsDTO)
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
