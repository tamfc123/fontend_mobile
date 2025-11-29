import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/services/auth/auth_service.dart';
import 'package:provider/provider.dart';

class AdminHomeScreen extends StatelessWidget {
  final Widget child;
  const AdminHomeScreen({super.key, required this.child});

  // HÀM ĐÃ SỬA ĐÚNG
  void _handleLogout(BuildContext context) async {
    final authService = context.read<AuthService>();
    await authService.logout();
    if (context.mounted) {
      context.go('/login/web');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar:
          isDesktop
              ? null
              : AppBar(
                title: const Text('Admin Dashboard'),
                backgroundColor: Colors.white,
                leading: Builder(
                  builder:
                      (context) => IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                ),
              ),
      drawer:
          isDesktop
              ? null
              : _SidebarMenu(onLogout: () => _handleLogout(context)),
      body: Row(
        children: [
          if (isDesktop)
            SizedBox(
              width: 260,
              child: _SidebarMenu(onLogout: () => _handleLogout(context)),
            ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _SidebarMenu extends StatelessWidget {
  final VoidCallback onLogout;
  const _SidebarMenu({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    Widget item({
      required IconData icon,
      required String label,
      required String path,
      bool exact = false,
    }) {
      final selected =
          exact
              ? location == path
              : location == path || location.startsWith('$path/');
      return ListTile(
        leading: Icon(icon, color: selected ? Colors.blue : Colors.black),
        title: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.blue : Colors.black,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: selected,
        selectedTileColor: Colors.blue.shade50,
        onTap: () => context.go(path),
      );
    }

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  accountName: const Text(
                    "Trang quản trị",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  accountEmail: Text(
                    context.watch<AuthService>().currentUser?.email ??
                        "admin@example.com",
                  ),
                  currentAccountPicture: const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.admin_panel_settings,
                      size: 40,
                      color: Colors.blue,
                    ),
                  ),
                ),
                item(
                  icon: Icons.dashboard,
                  label: 'Tổng quan',
                  path: '/admin',
                  exact: true,
                ),
                item(
                  icon: Icons.people,
                  label: 'Tài khoản',
                  path: '/admin/users',
                ),
                item(
                  icon: Icons.book,
                  label: 'Khóa học',
                  path: '/admin/courses',
                ),
                item(
                  icon: Icons.class_,
                  label: 'Lớp học',
                  path: '/admin/classes',
                ),
                item(
                  icon: Icons.schedule,
                  label: 'Lịch học',
                  path: '/admin/schedules',
                ),
                item(
                  icon: Icons.meeting_room,
                  label: 'Phòng học',
                  path: '/admin/rooms',
                ),
                item(
                  icon: Icons.library_music_rounded, // Icon Media
                  label: 'Thư viện Media',
                  path: '/admin/media', // 👈 Đường dẫn mới của Admin
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}
