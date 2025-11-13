// file: data/models/lesson_model.dart

// Model để nhận dữ liệu Lesson (khớp LessonDTO)
class LessonModel {
  final int id;
  final int moduleId;
  final String title;
  final int order;
  final String? content; // ⬅️ Trường "giống Word" (JSON)

  LessonModel({
    required this.id,
    required this.moduleId,
    required this.title,
    required this.order,
    this.content,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'],
      moduleId: json['moduleId'],
      title: json['title'],
      order: json['order'],
      content: json['content'],
    );
  }
}

// Model để gửi đi khi TẠO/SỬA (khớp LessonModifyDTO)
class LessonModifyModel {
  final int moduleId;
  final String title;
  final int order;
  final String? content;

  LessonModifyModel({
    required this.moduleId,
    required this.title,
    required this.order,
    this.content,
  });

  Map<String, dynamic> toJson() {
    return {
      'moduleId': moduleId,
      'title': title,
      'order': order,
      'content': content,
    };
  }
}
