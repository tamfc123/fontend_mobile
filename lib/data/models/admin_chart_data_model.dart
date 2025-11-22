// Model này khớp với AdminDailyCountDTO của C#
class AdminChartDataModel {
  final DateTime date;
  final int count;

  AdminChartDataModel({required this.date, required this.count});

  factory AdminChartDataModel.fromJson(Map<String, dynamic> json) {
    return AdminChartDataModel(
      date: DateTime.parse(json['date'] as String), // Nhận chuỗi ngày
      count: json['count'] as int,
    );
  }
}
