import 'package:go_router/go_router.dart';
import 'package:mobile/core/router/utils/route_error_handler.dart';
import 'package:mobile/core/router/utils/course_data_loader.dart';
import 'package:mobile/core/router/utils/module_data_loader.dart';
import 'package:mobile/core/router/utils/lesson_data_loader.dart';
import 'package:mobile/core/router/utils/course_data_loader_for_quiz.dart';
import 'package:mobile/core/router/utils/course_data_loader_for_quiz_list.dart';
import 'package:mobile/data/models/course_model.dart';
import 'package:mobile/data/models/lesson_model.dart';
import 'package:mobile/data/models/module_model.dart';
import 'package:mobile/data/models/user_model.dart';
import 'package:mobile/screens/admin/dashboard/admin_dashboard_screen.dart';
import 'package:mobile/screens/admin/manage_media/manage_media_screen.dart';
import 'package:mobile/screens/admin/manage_course/manage_course_screen.dart';
import 'package:mobile/screens/admin/manage_gift/manage_gift_screen.dart';
import 'package:mobile/screens/admin/manage_room/manage_room_screen.dart';
import 'package:mobile/screens/admin/manage_schedule/bulk_schedule_screen.dart';
import 'package:mobile/screens/admin/manage_schedule/manage_schedule_screen.dart';
import 'package:mobile/screens/admin/admin_layout.dart';
import 'package:mobile/screens/admin/manage_account/manage_account_screen.dart';
import 'package:mobile/screens/admin/manage_class/manage_class_screen.dart';
import 'package:mobile/screens/admin/manage_account/user_form_screen.dart';
import 'package:mobile/screens/admin/gift_redemption/gift_redemption_screen.dart';

/// Admin routes configuration with ShellRoute for layout
class AdminRoutes {
  static ShellRoute shellRoute = ShellRoute(
    builder: (context, state, child) => AdminLayout(child: child),
    routes: [
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
        routes: [
          // User management routes
          GoRoute(
            path: 'users',
            builder: (context, state) => const ManageAccountScreen(),
            routes: [
              GoRoute(
                path: 'create',
                name: 'adminCreateUser',
                builder: (context, state) => const UserFormScreen(),
              ),
              GoRoute(
                path: 'update',
                name: 'adminUpdateUser',
                builder: (context, state) {
                  final user = RouteErrorHandler.validateExtra<UserModel>(
                    state.extra,
                    'Không tìm thấy người dùng để sửa.',
                  );

                  if (user == null) {
                    return RouteErrorHandler.buildMissingDataError(
                      'Không tìm thấy người dùng để sửa.',
                    );
                  }

                  return UserFormScreen(user: user);
                },
              ),
            ],
          ),
          // Course management routes
          GoRoute(
            path: 'courses',
            builder: (context, state) => const ManageCourseScreen(),
            routes: [
              // Module management
              GoRoute(
                path: ':courseId/modules',
                builder: (context, state) {
                  final courseId = state.pathParameters['courseId']!;
                  // Only use extra if it's actually a CourseModel
                  final course =
                      state.extra is CourseModel
                          ? state.extra as CourseModel
                          : null;

                  return CourseDataLoader(
                    courseId: courseId,
                    initialCourse: course,
                  );
                },
                routes: [
                  // Lesson management
                  GoRoute(
                    path: ':moduleId/lessons',
                    builder: (context, state) {
                      final courseId = state.pathParameters['courseId']!;
                      final moduleId = state.pathParameters['moduleId']!;
                      // Only use extra if it's actually a ModuleModel
                      final module =
                          state.extra is ModuleModel
                              ? state.extra as ModuleModel
                              : null;

                      return ModuleDataLoader(
                        courseId: courseId,
                        moduleId: moduleId,
                        initialModule: module,
                      );
                    },
                    routes: [
                      // Vocabulary management
                      GoRoute(
                        path: ':lessonId/vocabularies',
                        builder: (context, state) {
                          final courseId = state.pathParameters['courseId']!;
                          final moduleId = state.pathParameters['moduleId']!;
                          final lessonId = state.pathParameters['lessonId']!;
                          // Only use extra if it's actually a LessonModel
                          final lesson =
                              state.extra is LessonModel
                                  ? state.extra as LessonModel
                                  : null;

                          return LessonDataLoader(
                            courseId: courseId,
                            moduleId: moduleId,
                            lessonId: lessonId,
                            initialLesson: lesson,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              // Quiz management
              GoRoute(
                path: ':courseId/quizzes',
                builder: (context, state) {
                  final courseId = state.pathParameters['courseId']!;
                  // Only use extra if it's actually a CourseModel
                  final course =
                      state.extra is CourseModel
                          ? state.extra as CourseModel
                          : null;

                  return CourseDataLoaderForQuizList(
                    courseId: courseId,
                    initialCourse: course,
                  );
                },
                routes: [
                  // Quiz detail
                  GoRoute(
                    path: ':quizId',
                    builder: (context, state) {
                      final courseId = state.pathParameters['courseId']!;
                      final quizId = state.pathParameters['quizId']!;

                      // Check if extra is CourseModel or Map
                      CourseModel? course;
                      if (state.extra is CourseModel) {
                        course = state.extra as CourseModel;
                      } else if (state.extra is Map<String, dynamic>) {
                        final extras = state.extra as Map<String, dynamic>;
                        course = extras['course'] as CourseModel?;
                      }

                      return CourseDataLoaderForQuiz(
                        courseId: courseId,
                        quizId: quizId,
                        initialCourse: course,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          // Class management
          GoRoute(
            path: 'classes',
            builder: (context, state) => const ManageClassScreen(),
          ),
          // Schedule management
          GoRoute(
            path: 'schedules',
            builder: (context, state) => const ManageScheduleScreen(),
            routes: [
              GoRoute(
                path: 'bulk-create',
                builder: (context, state) => const BulkScheduleScreen(),
              ),
            ],
          ),
          // Room management
          GoRoute(
            path: 'rooms',
            builder: (context, state) => const ManageRoomScreen(),
          ),
          // Media management
          GoRoute(
            path: 'media',
            builder: (context, state) => const ManageMediaScreen(),
          ),
          // Gift management
          GoRoute(
            path: 'gifts',
            builder: (context, state) => const ManageGiftScreen(),
          ),
          // Gift redemption (for staff to confirm delivery)
          GoRoute(
            path: 'gift-redemption',
            builder: (context, state) => const GiftRedemptionScreen(),
          ),
        ],
      ),
    ],
  );
}
