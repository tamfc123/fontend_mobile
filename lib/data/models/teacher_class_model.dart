class TeacherClassModel {
  final int id;
  final String name;
  final int courseId;
  final String? courseName;
  final String? teacherName;
  final int studentCount;

  TeacherClassModel({
    required this.id,
    required this.name,
    required this.courseId,
    this.courseName,
    this.teacherName,
    required this.studentCount,
  });

  factory TeacherClassModel.fromJson(Map<String, dynamic> json) {
    return TeacherClassModel(
      id: json['id'],
      name: json['name'] ?? '',
      courseId: json['courseId'],
      courseName: json['courseName'],
      teacherName: json['teacherName'],
      studentCount: json['studentCount'] ?? 0,
    );
  }
}
