// Model này khớp với AdminPieChartDTO của C#
class AdminPieChartModel {
  final String label;
  final int count;

  AdminPieChartModel({required this.label, required this.count});

  factory AdminPieChartModel.fromJson(Map<String, dynamic> json) {
    return AdminPieChartModel(
      label: json['label'] as String,
      count: json['count'] as int,
    );
  }
}
