import 'package:mobile/core/di/service_locator.dart';
import 'package:mobile/domain/repositories/teacher/teaacher_dashboard_repository.dart';
import 'package:mobile/domain/repositories/teacher/teacher_class_repository.dart';
import 'package:mobile/domain/repositories/teacher/teacher_quiz_repository.dart';
import 'package:mobile/domain/repositories/teacher/teacher_schedule_repository.dart';
import 'package:mobile/screens/teacher/manage_class/teacher_class_view_model.dart';
import 'package:mobile/screens/teacher/dashboard/teacher_dashboard_view_model.dart';
import 'package:mobile/screens/teacher/manage_class/teacher_quiz_view_model.dart';
import 'package:mobile/screens/teacher/manage_schedule/manage_teacher_schedule_view_model.dart';
import 'package:provider/provider.dart';

import 'package:provider/single_child_widget.dart';

final List<SingleChildWidget> teacherProviders = [
  // 1. Teacher Class ViewModel
  ChangeNotifierProvider<TeacherClassViewModel>(
    create: (_) => TeacherClassViewModel(getIt<TeacherClassRepository>()),
  ),

  // 2. Teacher Schedule ViewModel
  ChangeNotifierProvider<ManageTeacherScheduleViewModel>(
    create:
        (_) =>
            ManageTeacherScheduleViewModel(getIt<TeacherScheduleRepository>()),
  ),

  // 3. Teacher Dashboard ViewModel
  ChangeNotifierProvider<TeacherDashboardViewModel>(
    create:
        (_) => TeacherDashboardViewModel(getIt<TeaacherDashboardRepository>()),
  ),

  // 4. Teacher Quiz ViewModel
  ChangeNotifierProvider<TeacherQuizViewModel>(
    create: (_) => TeacherQuizViewModel(getIt<TeacherQuizRepository>()),
  ),
];
