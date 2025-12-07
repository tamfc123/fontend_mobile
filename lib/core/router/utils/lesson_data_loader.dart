import 'package:flutter/material.dart';
import 'package:mobile/core/di/service_locator.dart';
import 'package:mobile/data/models/lesson_model.dart';
import 'package:mobile/domain/repositories/admin/admin_lesson_repository.dart';
import 'package:mobile/screens/admin/manage_vocabulary/manage_vocabulary_screen.dart';

class LessonDataLoader extends StatelessWidget {
  final String courseId;
  final String moduleId;
  final String lessonId;
  final LessonModel? initialLesson;

  const LessonDataLoader({
    super.key,
    required this.courseId,
    required this.moduleId,
    required this.lessonId,
    this.initialLesson,
  });

  @override
  Widget build(BuildContext context) {
    // If we already have lesson data, use it
    if (initialLesson != null) {
      return ManageVocabularyScreen(lesson: initialLesson!);
    }

    // Otherwise, fetch from API
    return FutureBuilder<LessonModel>(
      future: getIt<AdminLessonRepository>().getLessonById(lessonId),
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
                    'Không thể tải thông tin bài học',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(snapshot.error.toString(), textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        }

        return ManageVocabularyScreen(lesson: snapshot.data!);
      },
    );
  }
}
