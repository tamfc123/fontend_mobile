class GiftModel {
  final String id;
  final String name;
  final String? description;
  final int coinPrice;
  final int stockQuantity;
  final String? imageUrl;
  final bool isActive;

  GiftModel({
    required this.id,
    required this.name,
    this.description,
    required this.coinPrice,
    required this.stockQuantity,
    this.imageUrl,
    this.isActive = true,
  });

  factory GiftModel.fromJson(Map<String, dynamic> json) {
    return GiftModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      coinPrice: json['coinPrice'] ?? 0,
      stockQuantity: json['stockQuantity'] ?? 0,
      imageUrl: json['imageUrl'],
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'coinPrice': coinPrice,
      'stockQuantity': stockQuantity,
      'imageUrl': imageUrl,
      'isActive': isActive,
    };
  }
}
