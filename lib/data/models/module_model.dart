class ModuleModel {
  final String id;
  final String courseId; // ✅ THAY ĐỔI: Dùng courseId
  final String title;
  final String? description;
  final int order; // ✅ THAY ĐỔI: Dùng order

  ModuleModel({
    required this.id,
    required this.courseId,
    required this.title,
    this.description,
    required this.order,
  });

  factory ModuleModel.fromJson(Map<String, dynamic> json) {
    return ModuleModel(
      id: json['id'],
      courseId: json['courseId'], // ✅ Đọc courseId
      title: json['title'],
      description: json['description'],
      order: json['order'], // ✅ Đọc order
    );
  }

  // toJson dùng cho Admin cập nhật
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'title': title,
      'description': description,
      'order': order,
    };
  }
}

class ModuleCreateModel {
  final String courseId;
  final String title;
  final String? description;

  ModuleCreateModel({
    required this.courseId,
    required this.title,
    this.description,
  });

  // Hàm toJson() này được dùng trong hàm createModule()
  Map<String, dynamic> toJson() {
    return {'courseId': courseId, 'title': title, 'description': description};
  }
}
