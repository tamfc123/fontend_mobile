import 'package:flutter/material.dart';

class ConfirmJoinClassDialog extends StatelessWidget {
  final String className;
  final Color levelColor;

  const ConfirmJoinClassDialog({
    super.key,
    required this.className,
    required this.levelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Icon (Hình tròn mờ theo màu Level)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: levelColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.school_rounded, size: 32, color: levelColor),
            ),
            const SizedBox(height: 20),

            // Title
            const Text(
              'Xác nhận tham gia',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),

            // Content
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
                children: [
                  const TextSpan(
                    text: 'Bạn có chắc chắn muốn đăng ký tham gia lớp ',
                  ),
                  TextSpan(
                    text: '"$className"',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const TextSpan(text: ' không?'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Actions Buttons
            Row(
              children: [
                // Nút Hủy
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      foregroundColor: Colors.grey.shade700,
                    ),
                    child: const Text(
                      'Hủy bỏ',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Nút Tham gia
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: levelColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      shadowColor: levelColor.withOpacity(0.4),
                    ),
                    child: const Text(
                      'Tham gia',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
