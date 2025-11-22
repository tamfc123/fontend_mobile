class ClassModel {
  final String id;
  final String name;
  final String courseId;
  final String courseName;
  final String? teacherId;
  final String? teacherName;

  ClassModel({
    required this.id,
    required this.name,
    required this.courseId,
    required this.courseName,
    this.teacherId,
    this.teacherName,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id'].toString(),
      name: json['name'],
      courseId: json['courseId'].toString(),
      courseName: json['courseName'] ?? '',
      teacherId: json['teacherId'], // nullable
      teacherName: json['teacherName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'courseId': courseId,
      'courseName': courseName,
      'teacherId': teacherId,
      'teacherName': teacherName,
    };
  }

  ClassModel copyWith({
    String? id,
    String? name,
    String? courseId,
    String? courseName,
    String? teacherId,
    String? teacherName,
  }) {
    return ClassModel(
      id: id ?? this.id,
      name: name ?? this.name,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
    );
  }
}
