import 'package:flutter/material.dart';
import 'package:mobile/core/di/service_locator.dart';
import 'package:mobile/data/models/course_model.dart';
import 'package:mobile/domain/repositories/admin/admin_course_repository.dart';
import 'package:mobile/screens/admin/manage_quiz/quiz_detail_screen.dart';

class CourseDataLoaderForQuiz extends StatelessWidget {
  final String courseId;
  final String quizId;
  final CourseModel? initialCourse;

  const CourseDataLoaderForQuiz({
    super.key,
    required this.courseId,
    required this.quizId,
    this.initialCourse,
  });

  @override
  Widget build(BuildContext context) {
    // If we already have course data, use it
    if (initialCourse != null) {
      return QuizDetailScreen(course: initialCourse!, quizId: quizId);
    }

    // Otherwise, fetch from API
    return FutureBuilder<CourseModel>(
      future: getIt<AdminCourseRepository>().getCourseById(courseId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Không thể tải thông tin khóa học',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(snapshot.error.toString(), textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        }

        return QuizDetailScreen(course: snapshot.data!, quizId: quizId);
      },
    );
  }
}
