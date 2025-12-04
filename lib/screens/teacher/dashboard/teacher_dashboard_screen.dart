import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/services/auth/auth_service.dart';
import 'package:mobile/screens/teacher/dashboard/teacher_dashboard_view_model.dart';
import 'package:mobile/screens/teacher/dashboard/widgets/teacher_dashboard_charts.dart';
import 'package:mobile/screens/teacher/dashboard/widgets/teacher_dashboard_lists.dart';
import 'package:mobile/shared_widgets/dashboard_header.dart';
import 'package:mobile/shared_widgets/stat_card.dart';
import 'package:provider/provider.dart';

class DashboardTeacherScreen extends StatefulWidget {
  const DashboardTeacherScreen({super.key});
  @override
  State<DashboardTeacherScreen> createState() => _DashboardTeacherScreenState();
}

class _DashboardTeacherScreenState extends State<DashboardTeacherScreen> {
  // MÀU CHỦ ĐẠO
  static const Color backgroundBlue = Color(0xFFF8F9FA);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Đảm bảo local 'vi' đã được đăng ký cho intl
      Intl.defaultLocale = 'vi_VN';
      context.read<TeacherDashboardViewModel>().fetchDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TeacherDashboardViewModel>();
    final authService = context.watch<AuthService>();
    final teacherName = authService.currentUser?.name ?? 'Giảng viên';

    if (viewModel.isLoading && viewModel.stats == null) {
      return const Scaffold(
        backgroundColor: backgroundBlue,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final stats = viewModel.stats;

    return Scaffold(
      backgroundColor: backgroundBlue,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DashboardHeader(
                icon: Icons.school_rounded,
                title: 'Chào mừng trở lại, $teacherName!',
                subtitle: 'Đây là tổng quan nhanh về các hoạt động của bạn.',
              ),
              const SizedBox(height: 24),

              // Dãy StatCard (Responsive)
              LayoutBuilder(
                builder: (context, constraints) {
                  // Large screen: Use Row (cards expand to fill width)
                  if (constraints.maxWidth >= 1000) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: StatCard(
                            icon: Icons.class_,
                            title: 'Tổng số lớp',
                            value: stats?.totalClasses.toString() ?? '...',
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: StatCard(
                            icon: Icons.people,
                            title: 'Tổng số học viên',
                            value: stats?.totalStudents.toString() ?? '...',
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: StatCard(
                            icon: Icons.quiz,
                            title: 'Tổng số bài quiz',
                            value: stats?.totalQuizzes.toString() ?? '...',
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: StatCard(
                            icon: Icons.calendar_today,
                            title: 'Lịch dạy hôm nay',
                            value: stats?.todayClasses.toString() ?? '...',
                            color: Colors.purple,
                          ),
                        ),
                      ],
                    );
                  }

                  // Small screen: Use Wrap (cards wrap to new lines)
                  return Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: 200,
                          maxWidth:
                              constraints.maxWidth < 600
                                  ? double.infinity
                                  : (constraints.maxWidth - 20) / 2,
                        ),
                        child: StatCard(
                          icon: Icons.class_,
                          title: 'Tổng số lớp',
                          value: stats?.totalClasses.toString() ?? '...',
                          color: Colors.blue,
                        ),
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: 200,
                          maxWidth:
                              constraints.maxWidth < 600
                                  ? double.infinity
                                  : (constraints.maxWidth - 20) / 2,
                        ),
                        child: StatCard(
                          icon: Icons.people,
                          title: 'Tổng số học viên',
                          value: stats?.totalStudents.toString() ?? '...',
                          color: Colors.green,
                        ),
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: 200,
                          maxWidth:
                              constraints.maxWidth < 600
                                  ? double.infinity
                                  : (constraints.maxWidth - 20) / 2,
                        ),
                        child: StatCard(
                          icon: Icons.quiz,
                          title: 'Tổng số bài quiz',
                          value: stats?.totalQuizzes.toString() ?? '...',
                          color: Colors.orange,
                        ),
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: 200,
                          maxWidth:
                              constraints.maxWidth < 600
                                  ? double.infinity
                                  : (constraints.maxWidth - 20) / 2,
                        ),
                        child: StatCard(
                          icon: Icons.calendar_today,
                          title: 'Lịch dạy hôm nay',
                          value: stats?.todayClasses.toString() ?? '...',
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),

              // ✅ 2. LAYOUTBUILDER (Layout 2x2 Grid)
              LayoutBuilder(
                builder: (context, constraints) {
                  // Đặt breakpoint cho 2 cột
                  bool isSmallScreen = constraints.maxWidth < 900;

                  // NẾU MÀN HÌNH NHỎ: DÙNG COLUMN (Xếp chồng 4 mục)
                  if (isSmallScreen) {
                    return Column(
                      children: [
                        PassFailChart(viewModel: viewModel),
                        const SizedBox(height: 24),
                        GradeDistributionChart(viewModel: viewModel),
                        const SizedBox(height: 24),
                        UpcomingScheduleList(viewModel: viewModel),
                        const SizedBox(height: 24),
                        MyClassesList(viewModel: viewModel),
                      ],
                    );
                  }

                  // NẾU MÀN HÌNH LỚN: DÙNG LAYOUT 2x2
                  return Column(
                    children: [
                      // HÀNG 1: HAI BIỂU ĐỒ
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1, // 50%
                            child: PassFailChart(viewModel: viewModel),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 1, // 50%
                            child: GradeDistributionChart(viewModel: viewModel),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24), // Khoảng cách giữa 2 hàng
                      // HÀNG 2: HAI DANH SÁCH
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1, // 50%
                            child: UpcomingScheduleList(viewModel: viewModel),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 1, // 50%
                            child: MyClassesList(viewModel: viewModel),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
