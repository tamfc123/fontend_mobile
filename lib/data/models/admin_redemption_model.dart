class AdminRedemptionModel {
  final String id;
  final String giftName;
  final int coinAmount;
  final String status; // "PENDING", "COMPLETED"
  final DateTime redeemedAt;
  final DateTime? completedAt;

  AdminRedemptionModel({
    required this.id,
    required this.giftName,
    required this.coinAmount,
    required this.status,
    required this.redeemedAt,
    this.completedAt,
  });

  factory AdminRedemptionModel.fromJson(Map<String, dynamic> json) {
    return AdminRedemptionModel(
      id: json['id'] ?? '',
      giftName: json['giftName'] ?? 'Quà tặng',
      coinAmount: json['coinAmount'] ?? 0,
      status: json['status'] ?? 'PENDING',
      redeemedAt: DateTime.tryParse(json['redeemedAt'] ?? '') ?? DateTime.now(),
      completedAt:
          json['completedAt'] != null
              ? DateTime.tryParse(json['completedAt'])
              : null,
    );
  }
}
