import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainHomeScreen extends StatefulWidget {
  final Widget child;
  final int currentIndex;
  const MainHomeScreen({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: widget.child, // GoRouter sẽ render child
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: widget.currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/student');
              break;
            case 1:
              context.go('/student/courses');
              break;
            case 2:
              context.go('/student/vocabulary');
              break;
            case 3:
              context.go('/student/profile');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: "Trang chủ",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_rounded),
            label: "Khóa học",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.translate_rounded),
            label: "Từ vựng",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: "Tôi",
          ),
        ],
      ),
    );
  }
}
