import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/screens/student/profile/student_profile_view_model.dart';
import 'package:mobile/screens/student/quiz/student_quiz_view_model.dart';
import 'package:provider/provider.dart';

class StudentLayout extends StatefulWidget {
  final Widget child;
  final int currentIndex;
  const StudentLayout({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  @override
  State<StudentLayout> createState() => _StudentLayoutState();
}

class _StudentLayoutState extends State<StudentLayout> {
  @override
  Widget build(BuildContext context) {
    // Check if current route should hide bottom nav
    final location = GoRouterState.of(context).uri.toString();
    final isQuizTaking = location.contains('/quizzes/take');
    final isQuizReview = location.contains('/quizzes/review');
    final isEditProfile = location.contains('/edit-profile');
    final isChangePassword = location.contains('/change-password');
    final isVocabularyLevel = location.contains('/vocabulary/level');
    final isClassList = location.contains('/student-class');
    final isSchedule = location.contains('/student-schedule');
    final isGrades = location.contains('/grades');
    final isLeaderboard = location.contains('/leader-board');
    final isGiftStore = location.contains('/gift-store');

    final shouldHideBottomNav =
        isQuizTaking ||
        isQuizReview ||
        isEditProfile ||
        isChangePassword ||
        isVocabularyLevel ||
        isClassList ||
        isSchedule ||
        isGrades ||
        isLeaderboard ||
        isGiftStore;

    // Check if we're on profile page to show loading overlay
    final isProfilePage = location.contains('/student/profile');
    final profileViewModel =
        isProfilePage ? context.watch<StudentProfileViewModel>() : null;

    // Check if we're on quiz taking page to show submit overlay
    final quizViewModel =
        isQuizTaking ? context.watch<StudentQuizViewModel>() : null;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          body: widget.child,
          bottomNavigationBar:
              shouldHideBottomNav
                  ? null
                  : Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: BottomNavigationBar(
                      backgroundColor: Colors.transparent,
                      currentIndex: widget.currentIndex,
                      type: BottomNavigationBarType.fixed,
                      selectedItemColor: const Color(0xFF3B82F6),
                      unselectedItemColor: Colors.grey.shade400,
                      selectedFontSize: 12,
                      unselectedFontSize: 11,
                      elevation: 0,
                      selectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
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
                      items: [
                        _buildNavItem(
                          icon: Icons.home_rounded,
                          label: "Trang chủ",
                          isSelected: widget.currentIndex == 0,
                        ),
                        _buildNavItem(
                          icon: Icons.menu_book_rounded,
                          label: "Khóa học",
                          isSelected: widget.currentIndex == 1,
                        ),
                        _buildNavItem(
                          icon: Icons.translate_rounded,
                          label: "Từ vựng",
                          isSelected: widget.currentIndex == 2,
                        ),
                        _buildNavItem(
                          icon: Icons.person_rounded,
                          label: "Tôi",
                          isSelected: widget.currentIndex == 3,
                        ),
                      ],
                    ),
                  ),
        ),

        // Full-screen loading overlay (covers everything including bottom nav)
        if (profileViewModel?.isUploading == true)
          Positioned.fill(
            child: Material(
              color: Colors.black.withValues(alpha: 0.7),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 70,
                      height: 70,
                      child: CircularProgressIndicator(
                        strokeWidth: 4,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Đang tải ảnh lên...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Quiz submit loading overlay
        if (quizViewModel?.isSubmitting == true)
          Positioned.fill(
            child: Material(
              color: Colors.black.withValues(alpha: 0.7),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 70,
                      height: 70,
                      child: CircularProgressIndicator(
                        strokeWidth: 4,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Đang chấm điểm...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  BottomNavigationBarItem _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          gradient:
              isSelected
                  ? const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                  : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: isSelected ? 26 : 24,
          color: isSelected ? Colors.white : Colors.grey.shade400,
        ),
      ),
      label: label,
    );
  }
}
