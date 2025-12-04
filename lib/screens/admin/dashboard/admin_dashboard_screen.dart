import 'package:flutter/material.dart';

import 'package:mobile/screens/admin/dashboard/admin_dashboard_view_model.dart';
import 'package:mobile/screens/admin/dashboard/widgets/dashboard_stats_cards.dart';
import 'package:mobile/screens/admin/dashboard/widgets/recent_teachers_list.dart';
import 'package:mobile/screens/admin/dashboard/widgets/skill_distribution_chart.dart';
import 'package:mobile/screens/admin/dashboard/widgets/top_students_list.dart';
import 'package:mobile/screens/admin/dashboard/widgets/user_growth_chart.dart';
import 'package:mobile/shared_widgets/admin/base_dashboard_card.dart';
import 'package:mobile/shared_widgets/dashboard_header.dart';
import 'package:provider/provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  static const Color backgroundBlue = Color(0xFFF3F8FF);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminDashboardViewModel>().fetchDashboardStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundBlue,
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const DashboardHeader(
                  icon: Icons.dashboard_rounded,
                  title: 'Tổng quan',
                  subtitle: 'Thống kê tổng quan toàn bộ hệ thống',
                ),
                const SizedBox(height: 24),
                const DashboardStatsCards(),
                const SizedBox(height: 24),
                _buildChartsRow(),
                const SizedBox(height: 24),
                _buildListsRow(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChartsRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 800) {
          return Column(
            children: const [
              BaseDashboardCard(child: UserGrowthChart()),
              SizedBox(height: 24),
              BaseDashboardCard(child: SkillDistributionChart()),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Expanded(child: BaseDashboardCard(child: UserGrowthChart())),
            SizedBox(width: 24),
            SizedBox(
              width: 450,
              child: BaseDashboardCard(child: SkillDistributionChart()),
            ),
          ],
        );
      },
    );
  }

  Widget _buildListsRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 800) {
          return Column(
            children: const [
              BaseDashboardCard(
                padding: EdgeInsets.all(0),
                child: RecentTeachersList(),
              ),
              SizedBox(height: 24),
              BaseDashboardCard(
                padding: EdgeInsets.all(0),
                child: TopStudentsList(),
              ),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Expanded(
              child: BaseDashboardCard(
                padding: EdgeInsets.all(0),
                child: RecentTeachersList(),
              ),
            ),
            SizedBox(width: 24),
            Expanded(
              child: BaseDashboardCard(
                padding: EdgeInsets.all(0),
                child: TopStudentsList(),
              ),
            ),
          ],
        );
      },
    );
  }
}
