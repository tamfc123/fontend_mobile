// lib/data/models/module_details_model.dart

// Khớp với LessonInfoDTO
class LessonInfoModel {
  final int id;
  final String title;
  final int totalWords;
  final int completedWords;

  LessonInfoModel({
    required this.id,
    required this.title,
    required this.totalWords,
    required this.completedWords,
  });

  factory LessonInfoModel.fromJson(Map<String, dynamic> json) {
    return LessonInfoModel(
      id: json['id'],
      title: json['title'],
      totalWords: json['totalWords'],
      completedWords: json['completedWords'],
    );
  }
}

// Khớp với ModuleDetailsDTO
class ModuleDetailsModel {
  final int moduleId;
  final String moduleName;
  final List<LessonInfoModel> lessons;

  ModuleDetailsModel({
    required this.moduleId,
    required this.moduleName,
    required this.lessons,
  });

  factory ModuleDetailsModel.fromJson(Map<String, dynamic> json) {
    var list = json['lessons'] as List;
    List<LessonInfoModel> lessonsList =
        list.map((i) => LessonInfoModel.fromJson(i)).toList();

    return ModuleDetailsModel(
      moduleId: json['moduleId'],
      moduleName: json['moduleName'],
      lessons: lessonsList,
    );
  }
}
