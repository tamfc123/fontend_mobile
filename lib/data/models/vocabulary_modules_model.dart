class VocabularyModulesModel {
  final List<ModuleInfoModel> topics;

  VocabularyModulesModel({required this.topics});

  factory VocabularyModulesModel.fromJson(Map<String, dynamic> json) {
    var list = json['topics'] as List;
    List<ModuleInfoModel> topicsList =
        list.map((i) => ModuleInfoModel.fromJson(i)).toList();
    return VocabularyModulesModel(topics: topicsList);
  }
}

// Class này tương ứng với ModuleInfoDTO
class ModuleInfoModel {
  final String id;
  final String name;
  final String? imageUrl;
  final int totalWords;
  final int completedWords;

  ModuleInfoModel({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.totalWords,
    required this.completedWords,
  });

  factory ModuleInfoModel.fromJson(Map<String, dynamic> json) {
    return ModuleInfoModel(
      id: json['id'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      totalWords: json['totalWords'],
      completedWords: json['completedWords'],
    );
  }
}
