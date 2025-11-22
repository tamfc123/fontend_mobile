class StudentClassModel {
  final String classId;
  final String className;
  final String courseName;
  final String teacherName;
  final int requiredLevel;
  final bool isLocked;

  StudentClassModel({
    required this.classId,
    required this.className,
    required this.courseName,
    required this.teacherName,
    this.requiredLevel = 0,
    this.isLocked = false,
  });

  factory StudentClassModel.fromJson(Map<String, dynamic> json) {
    return StudentClassModel(
      classId: json['classId'],
      className: json['className'] ?? 'Lớp chưa đặt tên',
      courseName: json['courseName'] ?? 'Chưa có môn',
      teacherName: json['teacherName'] ?? 'Chưa phân công',
      requiredLevel: json['requiredLevel'] ?? 0,
      isLocked: json['isLocked'] ?? false,
    );
  }
}
