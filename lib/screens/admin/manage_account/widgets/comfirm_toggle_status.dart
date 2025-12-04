import 'package:flutter/material.dart';
import 'package:mobile/data/models/user_model.dart';

Future<bool?> showToggleUserDialog({
  required BuildContext context,
  required UserModel user,
}) {
  final action = user.isActive ? 'khóa' : 'mở khóa';

  return showDialog<bool>(
    context: context,
    builder:
        (dialogContext) => AlertDialog(
          title: Text('Xác nhận $action'),
          content: Text('Bạn có chắc muốn $action tài khoản "${user.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: user.isActive ? Colors.orange : Colors.green,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(action, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
  );
}
