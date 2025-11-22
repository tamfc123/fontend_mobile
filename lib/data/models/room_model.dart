class RoomModel {
  final String id;
  final String name;
  final int capactity;
  final String status;

  RoomModel({
    required this.id,
    required this.name,
    required this.capactity,
    required this.status,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'],
      name: json['name'],
      capactity: json['capactity'], // lưu ý backend đang để Capactity
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'capactity': capactity, 'status': status};
  }
}
