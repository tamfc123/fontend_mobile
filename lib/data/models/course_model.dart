class CourseModel {
  final int? id;
  final String name;
  final String? description;
  final int durationInWeeks;

  // Gamification
  final int requiredLevel;
  final int? rewardExp; // để optional vì backend tự tính
  final int rewardCoins;

  CourseModel({
    this.id,
    required this.name,
    this.description,
    required this.durationInWeeks,
    required this.requiredLevel,
    this.rewardExp, // không required
    required this.rewardCoins,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      durationInWeeks: json['durationInWeeks'],
      requiredLevel: json['requiredLevel'],
      rewardExp: json['rewardExp'], // có thể null
      rewardCoins: json['rewardCoins'],
    );
  }

  Map<String, dynamic> toJson({bool includeId = true}) {
    final data = <String, dynamic>{
      "name": name,
      "description": description,
      "durationInWeeks": durationInWeeks,
      "requiredLevel": requiredLevel,
      "rewardCoins": rewardCoins,
      // KHÔNG gửi rewardExp khi tạo/sửa, vì backend tự tính
    };
    if (includeId && id != null) {
      data["id"] = id;
    }
    return data;
  }
}
