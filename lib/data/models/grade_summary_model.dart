class GradeSummaryModel {
  final double averageAccuracy;
  final double averageFluency;
  final double averageCompleteness;

  GradeSummaryModel({
    required this.averageAccuracy,
    required this.averageFluency,
    required this.averageCompleteness,
  });

  factory GradeSummaryModel.fromJson(Map<String, dynamic> json) {
    return GradeSummaryModel(
      averageAccuracy: (json['averageAccuracy'] as num).toDouble(),
      averageFluency: (json['averageFluency'] as num).toDouble(),
      averageCompleteness: (json['averageCompleteness'] as num).toDouble(),
    );
  }
}
