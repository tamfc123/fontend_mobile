import 'package:flutter/material.dart';

// Một widget Avatar cơ bản để hiển thị ảnh mạng hoặc chữ cái đầu của tên
class AvatarWidget extends StatelessWidget {
  final String? avatarUrl;
  final String name;
  final double radius;

  const AvatarWidget({
    super.key,
    this.avatarUrl,
    required this.name,
    this.radius = 24, // Kích thước mặc định
  });

  @override
  Widget build(BuildContext context) {
    // Lấy ký tự đầu tiên của tên
    final String fallbackText = name.isNotEmpty ? name[0].toUpperCase() : '?';

    // Kiểm tra xem URL có hợp lệ không (phải là http/https)
    final bool hasValidUrl =
        avatarUrl != null &&
        avatarUrl!.isNotEmpty &&
        (avatarUrl!.startsWith('http') || avatarUrl!.startsWith('https'));

    ImageProvider? backgroundImage;
    if (hasValidUrl) {
      backgroundImage = NetworkImage(avatarUrl!);
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey.shade200, // Màu nền cho fallback
      backgroundImage: backgroundImage,
      // Hiển thị chữ cái đầu nếu không có ảnh
      child:
          (backgroundImage == null)
              ? Text(
                fallbackText,
                style: TextStyle(
                  fontSize: radius,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              )
              : null,
    );
  }
}
