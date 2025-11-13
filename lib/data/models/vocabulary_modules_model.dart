// lib/data/models/vocabulary_modules_model.dart

// Class này tương ứng với VocabularyModulesDTO
class VocabularyModulesModel {
  // Tên 'topics' phải khớp với key JSON 'topics' từ C#
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
  final int id;
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

  // Các key (id, name, totalWords...) phải khớp 100% với C# DTO
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
