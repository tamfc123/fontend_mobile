class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final DateTime? birthday;
  final String role; // 'admin', 'teacher', 'student'
  final bool isActive;
  final int experiencePoints;
  final int level;
  final int coins;
  final String? avatarUrl; // thêm avatar
  final int currentStreak;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.birthday,
    required this.role,
    required this.isActive,
    required this.experiencePoints,
    required this.level,
    required this.coins,
    this.avatarUrl,
    required this.currentStreak,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      birthday:
          json['birthday'] != null && json['birthday'] != ''
              ? DateTime.tryParse(json['birthday'])
              : null,
      role: json['role'] as String? ?? 'unknown',
      isActive: json['isActive'] as bool? ?? false,
      experiencePoints: (json['experiencePoints'] as int?) ?? 0,
      level: (json['level'] as int?) ?? 1,
      coins: (json['coins'] as int?) ?? 0,
      avatarUrl: json['avatarUrl'] as String?, // map từ API
      currentStreak: (json['currentStreak'] as int?) ?? 0,
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    DateTime? birthday,
    String? role,
    bool? isActive,
    int? experiencePoints,
    int? level,
    int? coins,
    String? avatarUrl,
    int? currentStreak,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      birthday: birthday ?? this.birthday,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      experiencePoints: experiencePoints ?? this.experiencePoints,
      level: level ?? this.level,
      coins: coins ?? this.coins,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      currentStreak: currentStreak ?? this.currentStreak,
    );
  }
}
