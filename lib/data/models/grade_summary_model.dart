class GradeSummaryModel {
  final double averageAccuracy;
  final double averageFluency;
  final double averageCompleteness;
  final Map<String, double> overallSkills;

  GradeSummaryModel({
    required this.averageAccuracy,
    required this.averageFluency,
    required this.averageCompleteness,
    required this.overallSkills,
  });

  factory GradeSummaryModel.fromJson(Map<String, dynamic> json) {
    Map<String, double> skillsMap = {};

    if (json['overallSkills'] != null) {
      (json['overallSkills'] as Map<String, dynamic>).forEach((key, value) {
        // Convert từ num sang double để tránh lỗi int/double
        skillsMap[key] = (value as num).toDouble();
      });
    }
    return GradeSummaryModel(
      averageAccuracy: (json['averageAccuracy'] as num).toDouble(),
      averageFluency: (json['averageFluency'] as num).toDouble(),
      averageCompleteness: (json['averageCompleteness'] as num).toDouble(),
      overallSkills: skillsMap,
    );
  }
}
