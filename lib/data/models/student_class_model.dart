class StudentClassModel {
  final int classId;
  final String className;
  final String courseName;
  final String teacherName;

  StudentClassModel({
    required this.classId,
    required this.className,
    required this.courseName,
    required this.teacherName,
  });

  factory StudentClassModel.fromJson(Map<String, dynamic> json) {
    return StudentClassModel(
      classId: json['classId'],
      className: json['className'],
      courseName: json['courseName'],
      teacherName: json['teacherName'],
    );
  }
}
