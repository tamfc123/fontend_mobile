import 'package:flutter/material.dart';

class DashboardTeacherScreen extends StatelessWidget {
  const DashboardTeacherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.dashboard, size: 80, color: Colors.blue),
            SizedBox(height: 20),
            Text(
              "Chào mừng đến với trang quản lý giáo viên",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text("Hãy chọn một chức năng ở menu bên cạnh"),
          ],
        ),
      ),
    );
  }
}
