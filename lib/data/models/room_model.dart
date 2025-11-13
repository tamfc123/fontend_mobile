class RoomModel {
  final int id;
  final String name;
  final int capacity;
  final String status;

  RoomModel({
    required this.id,
    required this.name,
    required this.capacity,
    required this.status,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'],
      name: json['name'],
      capacity: json['capactity'], // lưu ý backend đang để Capactity
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'capactity': capacity, 'status': status};
  }
}
