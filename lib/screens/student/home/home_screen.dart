import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/screens/student/leaderboard/student_leaderboard_view_model.dart';
import 'package:mobile/services/auth/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

// THÊM MỚI: App Colors Theme
class AppColors {
  static const primary = Color(0xFF3B82F6);
  static const secondary = Color(0xFF8B5CF6);
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFEF4444);
  static const surface = Color(0xFFFFFFFF);
  static const background = Color(0xFFF5F7FA);
  static const textPrimary = Color(0xFF1F2937);
  static const textSecondary = Color(0xFF6B7280);
}

class HomeStudentScreen extends StatefulWidget {
  const HomeStudentScreen({super.key});

  @override
  State<HomeStudentScreen> createState() => _HomeStudentScreenState();
}

class _HomeStudentScreenState extends State<HomeStudentScreen> {
  final PageController _bannerController = PageController();
  int _currentBannerIndex = 0;
  Timer? _bannerTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ✅ Fetch data on init
      context.read<AuthService>().fetchCurrentUser();
      context.read<StudentLeaderboardViewModel>().loadLeaderboard();
    });
    _startBannerTimer();
  }

  @override
  void dispose() {
    _bannerTimer?.cancel(); // Hủy timer để tránh memory leak
    _bannerController.dispose();
    super.dispose();
  }

  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_bannerController.hasClients) {
        int nextPage = _currentBannerIndex + 1;
        // Nếu đã đến trang cuối cùng (ví dụ có 2 banner thì index cuối là 1)
        if (nextPage >= 2) {
          nextPage = 0;
        }
        _bannerController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  // IMPROVED: Quick Action Button với gradient background
  Widget _buildQuickActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    int? badge,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [color.withValues(alpha: 0.03), Colors.transparent],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon với badge
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(icon, color: color, size: 26),
                    ),
                    if (badge != null && badge > 0)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.danger,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 20,
                            minHeight: 20,
                          ),
                          child: Center(
                            child: Text(
                              badge > 9 ? '9+' : badge.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: color.withValues(alpha: 0.4),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0);
  }

  // THÊM MỚI: Banner Item
  Widget _buildBannerItem({
    required String title,
    required String subtitle,
    required String image,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.blue.shade900.withValues(alpha: 0.7),
                    Colors.blue.shade600.withValues(alpha: 0.3),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      shadows: [
                        Shadow(
                          offset: const Offset(0, 1),
                          blurRadius: 2,
                          color: Colors.black.withValues(alpha: 0.3),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      shadows: [
                        Shadow(
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                          color: Colors.black.withValues(alpha: 0.3),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue.shade600,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Xem ngay',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  @override
  Widget build(BuildContext context) {
    // Watch services for reactive updates
    final authService = context.watch<AuthService>();
    final leaderboardViewModel = context.watch<StudentLeaderboardViewModel>();

    // Get user from AuthService
    final user = authService.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 16),
              const Text(
                'Đang tải...',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // IMPROVED: AppBar với layout cân đối hơn
          SliverAppBar(
            expandedHeight: 130, // Tăng chiều cao chút cho thoáng
            floating: true,
            pinned: true,
            //backgroundColor: const Color(0xFF3B82F6), // Xanh chuẩn Tailwind
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF60A5FA)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        // 1. AVATAR (Có viền trắng + Bóng đổ)
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage:
                                user.avatarUrl != null &&
                                        user.avatarUrl!.isNotEmpty
                                    ? NetworkImage(user.avatarUrl!)
                                    : const AssetImage(
                                          "assets/images/avatar.png",
                                        )
                                        as ImageProvider,
                          ),
                        ),
                        const SizedBox(width: 16),

                        // 2. THÔNG TIN (Tên + Level Badge)
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Xin chào, ${user.name.split(' ').last}!", // Chỉ lấy tên cho thân mật
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),

                              // Level Badge (Màu cam nổi bật trên nền xanh)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.stars_rounded,
                                      color: Colors.amberAccent,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "Level ${user.level}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 3. CỤM STATS BÊN PHẢI (Coin + Streak)
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Coin Badge (Nền trắng, chữ vàng)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.monetization_on_rounded,
                                    color: Colors.amber,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "${user.coins}",
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Streak Badge (Lửa)
                            Row(
                              children: [
                                const Icon(
                                  Icons.local_fire_department_rounded,
                                  color: Colors.orangeAccent,
                                  size: 20,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "${user.currentStreak} ngày",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // IMPROVED: Banner với PageView và Dots Indicator
                SizedBox(
                  height: 200,
                  child: Stack(
                    children: [
                      PageView(
                        controller: _bannerController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentBannerIndex = index;
                          });
                        },
                        children: [
                          _buildBannerItem(
                            title: 'Khám phá khóa học',
                            subtitle: 'Nâng cao kỹ năng\ntiếng Anh của bạn',
                            image: 'assets/images/banner.jpg',
                            onTap: () => context.go('/student/courses'),
                          ),
                          _buildBannerItem(
                            title: 'Tính năng mới',
                            subtitle: 'Luyện phát âm AI\nChuẩn giọng bản xứ',
                            image: 'assets/images/banner2.jpg',
                            onTap: () => context.go('/student/vocabulary'),
                          ),
                        ],
                      ),
                      // Dots Indicator
                      Positioned(
                        bottom: 32,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            2,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: _currentBannerIndex == index ? 24 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color:
                                    _currentBannerIndex == index
                                        ? Colors.white
                                        : Colors.white.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 500.ms),

                // Quick Access Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Truy cập nhanh',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildQuickActionButton(
                        icon: Icons.class_rounded,
                        title: 'Lớp học của bạn',
                        subtitle: 'Xem danh sách lớp đã tham gia',
                        color: AppColors.secondary,
                        onTap: () => context.go('/student/student-class'),
                      ),
                      _buildQuickActionButton(
                        icon: Icons.calendar_month_rounded,
                        title: 'Lịch học',
                        subtitle: 'Thời khóa biểu và lịch học',
                        color: AppColors.primary,
                        onTap: () => context.go('/student/student-schedule'),
                      ),
                      _buildQuickActionButton(
                        icon: Icons.grade_rounded,
                        title: 'Kết quả học tập',
                        subtitle: 'Xem điểm và đánh giá',
                        color: AppColors.success,
                        onTap: () => context.go('/student/grades'),
                      ),
                      _buildQuickActionButton(
                        icon: Icons.store_rounded,
                        title: 'Đổi quà',
                        subtitle: 'Đổi xu thành vật phẩm',
                        color: Colors.pink.shade600,
                        onTap: () => context.go('/student/gift-store'),
                      ),
                      _buildQuickActionButton(
                        icon: Icons.leaderboard_rounded,
                        title: 'Bảng xếp hạng',
                        subtitle: 'So sánh với bạn bè',
                        color: Colors.teal.shade600,
                        onTap: () => context.go('/student/leader-board'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // THÊM MỚI: Mini Achievements Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Thành tích gần đây',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Tính toán rank của bạn dựa trên dữ liệu leaderboard
                      Builder(
                        builder: (context) {
                          final myRankData =
                              leaderboardViewModel.currentUserRank;

                          String rankTitle = 'Chưa xếp hạng';
                          double rankProgress = 0.0;

                          if (myRankData != null) {
                            final int myRank = myRankData.rank;
                            if (myRank > 0 && myRank <= 10) {
                              rankTitle = 'Top $myRank';
                              rankProgress = 1.0;
                            } else if (myRank > 10) {
                              rankTitle = 'Hạng $myRank';
                              rankProgress = (10 / myRank).clamp(0.0, 1.0);
                            } else {
                              rankTitle = 'Hạng $myRank';
                            }
                          }

                          return Row(
                            children: [
                              Expanded(
                                child: _buildAchievementCard(
                                  icon: Icons.local_fire_department,
                                  title: '${user.currentStreak} ngày',
                                  subtitle: 'Streak',
                                  color: AppColors.danger,
                                  progress: (user.currentStreak / 10).clamp(
                                    0.0,
                                    1.0,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildAchievementCard(
                                  icon: Icons.star_rounded,
                                  title: '${user.coins} Xu',
                                  subtitle: 'Tổng cộng',
                                  color: AppColors.warning,
                                  progress: 1,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildAchievementCard(
                                  icon: Icons.leaderboard_rounded,
                                  title: rankTitle,
                                  subtitle: 'XH tuần',
                                  color: AppColors.secondary,
                                  progress: rankProgress,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 500.ms, delay: 500.ms),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // THÊM MỚI: Achievement Card Widget
  Widget _buildAchievementCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required double progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}
