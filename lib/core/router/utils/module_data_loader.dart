import 'package:flutter/material.dart';
import 'package:mobile/core/di/service_locator.dart';
import 'package:mobile/data/models/module_model.dart';
import 'package:mobile/domain/repositories/admin/admin_module_repository.dart';
import 'package:mobile/screens/admin/manage_lesson/manage_lesson_screen.dart';

class ModuleDataLoader extends StatelessWidget {
  final String courseId;
  final String moduleId;
  final ModuleModel? initialModule;

  const ModuleDataLoader({
    super.key,
    required this.courseId,
    required this.moduleId,
    this.initialModule,
  });

  @override
  Widget build(BuildContext context) {
    // If we already have module data, use it
    if (initialModule != null) {
      return ManageLessonScreen(module: initialModule!);
    }

    // Otherwise, fetch from API
    return FutureBuilder<ModuleModel>(
      future: getIt<AdminModuleRepository>().getModuleById(moduleId),
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
                    'Không thể tải thông tin chương học',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(snapshot.error.toString(), textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        }

        return ManageLessonScreen(module: snapshot.data!);
      },
    );
  }
}
