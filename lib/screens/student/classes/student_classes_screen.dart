import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/data/models/student_class_model.dart';
import 'package:mobile/screens/student/classes/student_classes_view_model.dart';
import 'package:mobile/screens/student/classes/widgets/class_card.dart';
import 'package:provider/provider.dart';

class StudentClassesScreen extends StatefulWidget {
  const StudentClassesScreen({super.key});

  @override
  State<StudentClassesScreen> createState() => _StudentClassesScreenState();
}

class _StudentClassesScreenState extends State<StudentClassesScreen> {
  // Palette màu
  static const Color primaryBlue = Color(0xFF3B82F6);
  static const Color textDark = Color(0xFF1E293B);
  static const Color bgLight = Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentClassesViewModel>().loadClasses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentClassesViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: bgLight,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            centerTitle: true,
            title: const Text(
              "Lớp học của tôi",
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                color: textDark,
              ),
            ),
          ),
          body: Builder(
            builder: (context) {
              if (viewModel.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: primaryBlue),
                );
              }

              if (viewModel.error != null) {
                return _buildErrorState(viewModel);
              }

              if (viewModel.joinedClasses.isEmpty) {
                return _buildEmptyState(context);
              }

              return RefreshIndicator(
                onRefresh: () async {
                  await viewModel.refresh();
                },
                color: primaryBlue,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // 1. Header Thống kê (Dashboard Style)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2563EB), Color(0xFF60A5FA)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: primaryBlue.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.school_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${viewModel.joinedClasses.length}',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      height: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Lớp đang tham gia',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ✅ 2. Tiêu đề danh sách (Bổ sung theo yêu cầu)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 10, 24, 12),
                        child: Text(
                          "Danh sách lớp học",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: textDark,
                          ),
                        ),
                      ),
                    ),

                    // 3. Danh sách lớp (Animated List)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final classModel = viewModel.joinedClasses[index];

                          return _AnimatedListItem(
                            index: index,
                            child: ClassCard(
                              classModel: classModel,
                              levelConfig: const {},
                              onTap:
                                  () => context.push(
                                    '/student/student-class/module-class',
                                    extra: classModel,
                                  ),
                              onLeave:
                                  () => _confirmLeaveClass(
                                    context,
                                    viewModel,
                                    classModel,
                                  ),
                            ),
                          );
                        }, childCount: viewModel.joinedClasses.length),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _confirmLeaveClass(
    BuildContext context,
    StudentClassesViewModel viewModel,
    StudentClassModel classModel,
  ) async {
    return showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.logout_rounded,
                      color: Colors.red.shade400,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Rời lớp học?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Bạn có chắc muốn rời khỏi lớp "${classModel.className}"?\nMọi tiến độ học tập trong lớp này sẽ bị ẩn.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            foregroundColor: Colors.grey.shade700,
                          ),
                          child: const Text(
                            'Hủy',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            await viewModel.leaveClass(classModel.classId);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade500,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Rời lớp',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primaryBlue.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.class_outlined,
              size: 64,
              color: primaryBlue,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Chưa tham gia lớp nào",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Hãy đăng ký khóa học để bắt đầu hành trình",
            style: TextStyle(color: Colors.grey.shade500),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => context.go('/student/courses'),
            icon: const Icon(Icons.explore_rounded),
            label: const Text('Khám phá Khóa học'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              shadowColor: primaryBlue.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(StudentClassesViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: Colors.red.shade300,
          ),
          const SizedBox(height: 16),
          const Text(
            "Có lỗi xảy ra",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              viewModel.error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => viewModel.loadClasses(),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Thử lại'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// Animation Widget (Staggered List Animation)
class _AnimatedListItem extends StatelessWidget {
  final int index;
  final Widget child;
  const _AnimatedListItem({required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOutQuad,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
        );
      },
      child: child,
    );
  }
}
