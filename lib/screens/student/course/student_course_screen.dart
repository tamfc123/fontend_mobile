import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/data/models/course_model.dart';
import 'package:mobile/screens/student/course/student_course_view_model.dart';
import 'package:mobile/screens/student/course/widgets/course_card.dart';
import 'package:mobile/screens/student/course/widgets/course_filter_bar.dart';
import 'package:provider/provider.dart';

class CourseStudentScreen extends StatefulWidget {
  const CourseStudentScreen({super.key});

  @override
  State<CourseStudentScreen> createState() => _CourseStudentScreenState();
}

class _CourseStudentScreenState extends State<CourseStudentScreen> {
  String _selectedFilter = 'all'; // all, 1, 2, 3, 4, 5, 6

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentCourseViewModel>().loadAvailableCourses();
    });
  }

  // Filter courses based on selected filter
  List<CourseModel> _filterCourses(List<CourseModel> courses) {
    if (_selectedFilter == 'all') return courses;

    final filterLevel = int.tryParse(_selectedFilter);
    if (filterLevel != null) {
      return courses
          .where((course) => course.requiredLevel == filterLevel)
          .toList();
    }

    return courses;
  }

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
          "Khóa học",
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
      ),

      body: Consumer<StudentCourseViewModel>(
        builder: (context, viewModel, child) {
          // Loading state
          if (viewModel.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.blue.shade600),
                  const SizedBox(height: 16),
                  Text(
                    'Đang tải khóa học...',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
            );
          }

          // Error state
          if (viewModel.error != null) {
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
                  Text(
                    "Có lỗi xảy ra",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    viewModel.error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      viewModel.loadAvailableCourses();
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Thử lại'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final allCourses = viewModel.courses;
          final filteredCourses = _filterCourses(allCourses);

          // Empty state
          if (allCourses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Chưa có khóa học nào",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Các khóa học sẽ sớm được cập nhật",
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Filter chips
              CourseFilterBar(
                selectedFilter: _selectedFilter,
                totalCount: allCourses.length,
                levelCounts: {
                  for (var level in [1, 2, 3, 4, 5, 6])
                    level:
                        allCourses
                            .where((c) => c.requiredLevel == level)
                            .length,
                },
                onFilterChanged: (value) {
                  setState(() {
                    _selectedFilter = value;
                  });
                },
              ),

              // Course count
              if (filteredCourses.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Text(
                    '${filteredCourses.length} khóa học',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),

              // Course list
              Expanded(
                child:
                    filteredCourses.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.filter_list_off_rounded,
                                size: 64,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Không có khóa học phù hợp',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        )
                        : RefreshIndicator(
                          onRefresh: () async {
                            await viewModel.loadAvailableCourses();
                          },
                          color: Colors.blue.shade600,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                            itemCount: filteredCourses.length,
                            itemBuilder: (context, index) {
                              final course = filteredCourses[index];

                              // ✅ THÊM ANIMATION Ở ĐÂY
                              return _AnimatedListItem(
                                index: index,
                                child: CourseCard(
                                  course: course,
                                  onTap:
                                      () => context.push(
                                        // Dùng push để giữ stack
                                        '/student/courses/class-in-course',
                                        extra: course,
                                      ),
                                ),
                              );
                            },
                          ),
                        ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ✅ WIDGET ANIMATION (Tái sử dụng logic đã làm ở màn hình trước)
class _AnimatedListItem extends StatelessWidget {
  final int index;
  final Widget child;
  const _AnimatedListItem({required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      // Tạo hiệu ứng trễ nhẹ dựa theo index để các item không hiện ra cùng lúc
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutQuad,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)), // Trượt từ dưới lên 50px
          child: Opacity(
            opacity: value, // Mờ dần thành rõ
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(
          bottom: 0,
        ), // Padding do ListView quản lý
        child: child,
      ),
    );
  }
}
