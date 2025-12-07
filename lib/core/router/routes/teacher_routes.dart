import 'package:go_router/go_router.dart';
import 'package:mobile/core/router/utils/teacher_class_data_loader.dart';
import 'package:mobile/data/models/class_model.dart';
import 'package:mobile/data/models/teacher_class_model.dart';
import 'package:mobile/screens/teacher/dashboard/teacher_dashboard_screen.dart';
import 'package:mobile/screens/teacher/teacher_layout.dart';
import 'package:mobile/screens/teacher/manage_class/manage_teacher_class_screen.dart';
import 'package:mobile/screens/teacher/manage_schedule/manage_teacher_schedule_screen.dart';
import 'package:mobile/screens/teacher/manage_class/student_list_screen.dart';

/// Teacher routes configuration with ShellRoute for layout
class TeacherRoutes {
  static ShellRoute shellRoute = ShellRoute(
    builder: (context, state, child) => TeacherLayout(child: child),
    routes: [
      GoRoute(
        path: '/teacher',
        builder: (context, state) => const DashboardTeacherScreen(),
        routes: [
          // Teacher classes management
          GoRoute(
            path: 'teacherClasses',
            builder: (context, state) => const ManageTeacherClassScreen(),
            routes: [
              // Student list
              GoRoute(
                path: ':classId/students',
                builder: (context, state) {
                  final classId = state.pathParameters['classId']!;
                  final className = state.extra as String;

                  return StudentListScreen(
                    classId: classId,
                    className: className,
                  );
                },
              ),
              // Quiz list
              GoRoute(
                path: ':classId/quizzes',
                builder: (context, state) {
                  final classId = state.pathParameters['classId']!;
                  final extra = state.extra;

                  // Check if extra is valid class data
                  dynamic initialClass;
                  if (extra is TeacherClassModel || extra is ClassModel) {
                    initialClass = extra;
                  }

                  return TeacherClassDataLoader(
                    classId: classId,
                    initialClass: initialClass,
                  );
                },
              ),
            ],
          ),
          // Teacher schedule
          GoRoute(
            path: 'schedules',
            builder: (context, state) => const TeacherScheduleScreen(),
          ),
        ],
      ),
    ],
  );
}
