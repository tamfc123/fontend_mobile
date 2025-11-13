import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/data/models/course_model.dart';
import 'package:mobile/services/student/student_course_service.dart';
import 'package:mobile/widgets/student/courseStudent/course_card.dart';
import 'package:mobile/widgets/student/courseStudent/course_filter_bar.dart';
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
    // Gọi load data ngay khi mở màn hình
    Future.microtask(
      () => context.read<StudentCourseService>().loadAvailableCourses(),
    );
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
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {
              // TODO: Implement search
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tính năng tìm kiếm đang phát triển'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),

      body: Consumer<StudentCourseService>(
        builder: (context, service, child) {
          // Loading state
          if (service.isLoading) {
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
          if (service.error != null) {
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
                    service.error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      service.loadAvailableCourses();
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

          final allCourses = service.courses;
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
                            await service.loadAvailableCourses();
                          },
                          color: Colors.blue.shade600,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                            itemCount: filteredCourses.length,
                            itemBuilder: (context, index) {
                              final course = filteredCourses[index];
                              return CourseCard(
                                course: course,
                                onTap:
                                    () => context.go(
                                      '/student/courses/class-in-course',
                                      extra: course,
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
