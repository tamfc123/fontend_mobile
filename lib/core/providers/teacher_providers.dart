import 'package:mobile/core/di/service_locator.dart';
import 'package:mobile/domain/repositories/teaacher_dashboard_repository.dart';
import 'package:mobile/domain/repositories/teacher_class_repository.dart';
import 'package:mobile/domain/repositories/teacher_quiz_repository.dart';
import 'package:mobile/domain/repositories/teacher_schedule_repository.dart';
import 'package:mobile/services/teacher/teacher_class_service.dart';
import 'package:mobile/services/teacher/teacher_dashboard_service.dart';
import 'package:mobile/services/teacher/teacher_quiz_service.dart';
import 'package:mobile/services/teacher/teacher_schedule_service.dart';
import 'package:provider/provider.dart';

final teacherProviders = [
  // 1. Teacher Class Service
  ChangeNotifierProvider<TeacherAdminClassService>(
    create: (_) => TeacherAdminClassService(getIt<TeacherClassRepository>()),
  ),

  // 2. Teacher Schedule Service
  ChangeNotifierProvider<TeacherScheduleService>(
    create: (_) => TeacherScheduleService(getIt<TeacherScheduleRepository>()),
  ),

  // 3. Teacher Dashboard Service
  ChangeNotifierProvider<TeacherDashboardService>(
    create:
        (_) => TeacherDashboardService(getIt<TeaacherDashboardRepository>()),
  ),

  // 4. Teacher Quiz Service
  ChangeNotifierProvider<TeacherQuizService>(
    create: (_) => TeacherQuizService(getIt<TeacherQuizRepository>()),
  ),
];
