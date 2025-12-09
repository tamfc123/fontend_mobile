import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/shared_widgets/logout_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      // Modern AppBar
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F2937),
        centerTitle: true,
        title: const Text(
          "Cài đặt",
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          // Account Section
          _buildSectionHeader("Tài khoản"),
          const SizedBox(height: 12),

          _buildSettingCard(
            context,
            items: [
              _SettingItem(
                icon: Icons.person_outline_rounded,
                title: "Thông tin cá nhân",
                subtitle: "Chỉnh sửa thông tin của bạn",
                color: Colors.blue,
                onTap: () async {
                  final result = await context.push(
                    '/student/profile/settings/edit-profile',
                  );
                  // If profile was updated, return true to settings caller
                  if (result == true && context.mounted) {
                    Navigator.pop(context, true);
                  }
                },
              ),
              _SettingItem(
                icon: Icons.lock_outline_rounded,
                title: "Đổi mật khẩu",
                subtitle: "Cập nhật mật khẩu của bạn",
                color: Colors.orange,
                onTap:
                    () =>
                        context.go('/student/profile/settings/change-password'),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Support Section
          _buildSectionHeader("Hỗ trợ"),
          const SizedBox(height: 12),

          _buildSettingCard(
            context,
            items: [
              _SettingItem(
                icon: Icons.help_outline_rounded,
                title: "Trợ giúp",
                subtitle: "Câu hỏi thường gặp",
                color: Colors.cyan,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tính năng đang phát triển'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              _SettingItem(
                icon: Icons.info_outline_rounded,
                title: "Về ứng dụng",
                subtitle: "Phiên bản 1.0.0",
                color: Colors.grey,
                onTap: () {
                  _showAboutDialog(context);
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Logout Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap:
                    () => showLogoutDialog(
                      context,
                      message: 'Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng?',
                    ),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red.shade100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.logout_rounded,
                          color: Colors.red,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Đăng xuất',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: Colors.red.shade200,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // Section header widget
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1F2937),
        ),
      ),
    );
  }

  // Setting card container
  Widget _buildSettingCard(
    BuildContext context, {
    required List<_SettingItem> items,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _buildSettingTile(items[i]),
            if (i < items.length - 1)
              Divider(height: 1, indent: 68, color: Colors.grey.shade200),
          ],
        ],
      ),
    );
  }

  // Individual setting tile
  Widget _buildSettingTile(_SettingItem item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon container
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: item.color, size: 24),
              ),
              const SizedBox(width: 16),
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    if (item.subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Trailing widget
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // About dialog
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Về ứng dụng',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'English Learning Center',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('Phiên bản: 1.0.0'),
                SizedBox(height: 4),
                Text('© 2025 English Learning Center'),
                SizedBox(height: 12),
                Text(
                  'Ứng dụng học tiếng Anh với các tính năng tham gia lớp học, học từ vựng và phát âm.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đóng'),
              ),
            ],
          ),
    );
  }
}

// Setting item model
class _SettingItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color color;
  final VoidCallback? onTap;

  _SettingItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.color,
    this.onTap,
  });
}
