class LessonModel {
  final String id;
  final String moduleId;
  final String title;
  final int order;
  final String? content; // ⬅️ Trường "giống Word" (JSON)
  final bool hasContent;

  LessonModel({
    required this.id,
    required this.moduleId,
    required this.title,
    required this.order,
    this.content,
    required this.hasContent,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'],
      moduleId: json['moduleId'],
      title: json['title'],
      order: json['order'],
      content: json['content'],
      hasContent: json['hasContent'] ?? false,
    );
  }
}

// Model để gửi đi khi TẠO/SỬA (khớp LessonModifyDTO)
class LessonModifyModel {
  final String moduleId;
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
