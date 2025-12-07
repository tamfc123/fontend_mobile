import 'package:flutter/material.dart';
import 'package:mobile/core/di/service_locator.dart';
import 'package:mobile/data/models/class_model.dart';
import 'package:mobile/data/models/teacher_class_model.dart';
import 'package:mobile/domain/repositories/teacher/teacher_class_repository.dart';
import 'package:mobile/screens/teacher/manage_class/teacher_quiz_list_screen.dart';

class TeacherClassDataLoader extends StatelessWidget {
  final String classId;
  final dynamic initialClass;

  const TeacherClassDataLoader({
    super.key,
    required this.classId,
    this.initialClass,
  });

  ClassModel _convertToClassModel(dynamic data) {
    if (data is ClassModel) {
      return data;
    } else if (data is TeacherClassModel) {
      return ClassModel(
        id: data.id,
        name: data.name,
        teacherId: '',
        courseId: '',
        courseName: data.courseName ?? '',
      );
    }
    throw Exception('Invalid class data type');
  }

  @override
  Widget build(BuildContext context) {
    // If we already have class data, use it
    if (initialClass != null) {
      try {
        final classModel = _convertToClassModel(initialClass);
        return TeacherQuizListScreen(classModel: classModel);
      } catch (e) {
        // If conversion fails, fetch from API
      }
    }

    // Otherwise, fetch from API
    return FutureBuilder<TeacherClassModel>(
      future: getIt<TeacherClassRepository>().getClassById(classId),
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
                    'Không thể tải thông tin lớp học',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(snapshot.error.toString(), textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        }

        final classModel = _convertToClassModel(snapshot.data!);
        return TeacherQuizListScreen(classModel: classModel);
      },
    );
  }
}
