class StudentRedemptionModel {
  final String id;
  final String giftName;
  final String? giftImage;
  final int coinCost;
  final String status; // "PENDING", "COMPLETED"
  final DateTime redeemedAt;
  final DateTime? completedAt;

  StudentRedemptionModel({
    required this.id,
    required this.giftName,
    this.giftImage,
    required this.coinCost,
    required this.status,
    required this.redeemedAt,
    this.completedAt,
  });

  factory StudentRedemptionModel.fromJson(Map<String, dynamic> json) {
    return StudentRedemptionModel(
      id: json['id'] ?? '',
      giftName: json['giftName'] ?? 'Quà tặng',
      giftImage: json['giftImage'],
      coinCost: json['coinCost'] ?? 0,
      status: json['status'] ?? 'PENDING',
      redeemedAt: DateTime.tryParse(json['redeemedAt'] ?? '') ?? DateTime.now(),
      completedAt:
          json['completedAt'] != null
              ? DateTime.tryParse(json['completedAt'])
              : null,
    );
  }
}
