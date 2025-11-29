class ClassSkillOverviewModel {
  final String studentId;
  final String studentName;
  final String? avatarUrl;
  final Map<String, double> skills;

  ClassSkillOverviewModel({
    required this.studentId,
    required this.studentName,
    this.avatarUrl,
    required this.skills,
  });

  factory ClassSkillOverviewModel.fromJson(Map<String, dynamic> json) {
    Map<String, double> skillsMap = {};
    if (json['skills'] != null) {
      (json['skills'] as Map<String, dynamic>).forEach((key, value) {
        skillsMap[key] = (value as num).toDouble();
      });
    }

    return ClassSkillOverviewModel(
      studentId: json['studentId'] ?? '',
      studentName: json['studentName'] ?? 'Unknown',
      avatarUrl: json['avatarUrl'],
      skills: skillsMap,
    );
  }
}
