import 'package:go_router/go_router.dart';
import 'package:mobile/data/models/course_model.dart';
import 'package:mobile/data/models/module_details_model.dart';
import 'package:mobile/data/models/student_class_model.dart';
import 'package:mobile/data/models/vocabulary_levels_model.dart';
import 'package:mobile/data/models/vocabulary_modules_model.dart';
import 'package:mobile/screens/student/flashcards/lesson_flashcards_screen.dart';
import 'package:mobile/screens/student/grades/student_grades_screen.dart';
import 'package:mobile/screens/student/leaderboard/student_leader_board_screen.dart';
import 'package:mobile/screens/student/home/home_screen.dart';
import 'package:mobile/screens/student/profile/change_password_screen.dart';
import 'package:mobile/screens/student/profile/settings_screen.dart';
import 'package:mobile/screens/student/profile/student_edit_profile_screen.dart';
import 'package:mobile/screens/student/profile/student_profile_screen.dart';
import 'package:mobile/screens/student/student_layout.dart';
import 'package:mobile/screens/student/gift_store/student_gift_store_screen.dart';
import 'package:mobile/screens/student/classes/student_classes_screen.dart';
import 'package:mobile/screens/student/course/student_course_class_screen.dart';
import 'package:mobile/screens/student/classes/student_class_detail_screen.dart';
import 'package:mobile/screens/student/quiz/student_quiz_list_screen.dart';
import 'package:mobile/screens/student/quiz/student_quiz_review_screen.dart';
import 'package:mobile/screens/student/quiz/student_quiz_taking_screen.dart';
import 'package:mobile/screens/student/schedule/student_schedule_screen.dart';
import 'package:mobile/screens/student/course/student_course_screen.dart';
import 'package:mobile/screens/student/vocabulary/student_vocabulary_screen.dart';
import 'package:mobile/screens/student/vocabulary/vocabulary_level_content_screen.dart';
import 'package:mobile/screens/student/vocabulary/vocabulary_module_details_screen.dart';

/// Student routes configuration with ShellRoute for layout
class StudentRoutes {
  static ShellRoute shellRoute = ShellRoute(
    builder: (context, state, child) {
      final location = state.uri.toString();
      int currentIndex = 0;

      if (location.startsWith('/student/courses')) {
        currentIndex = 1;
      } else if (location.startsWith('/student/vocabulary')) {
        currentIndex = 2;
      } else if (location.startsWith('/student/profile')) {
        currentIndex = 3;
      }

      return StudentLayout(currentIndex: currentIndex, child: child);
    },
    routes: [
      // Home route
      GoRoute(
        path: '/student',
        builder: (context, state) => const HomeStudentScreen(),
        routes: [
          // Classes routes
          GoRoute(
            path: 'student-class',
            builder: (context, state) => const StudentClassesScreen(),
            routes: [
              GoRoute(
                path: 'module-class',
                builder: (context, state) {
                  final module = state.extra as StudentClassModel;
                  return StudentClassDetailScreen(studentClassModel: module);
                },
                routes: [
                  // Quizzes routes
                  GoRoute(
                    path: 'quizzes',
                    name: 'student-quiz-list',
                    builder: (context, state) {
                      final classModel = state.extra as StudentClassModel;
                      return StudentQuizListScreen(
                        classId: classModel.classId,
                        className: classModel.className,
                      );
                    },
                    routes: [
                      // Quiz taking
                      GoRoute(
                        path: 'take',
                        name: 'student-quiz-taking',
                        builder: (context, state) {
                          final params = state.extra as Map<String, dynamic>;
                          return StudentQuizTakingScreen(
                            classId: params['classId'] as String,
                            quizId: params['quizId'] as String,
                            quizTitle: params['quizTitle'] as String,
                          );
                        },
                      ),
                      // Quiz review
                      GoRoute(
                        path: 'review',
                        name: 'student-quiz-review',
                        builder: (context, state) {
                          final params = state.extra as Map<String, dynamic>;
                          return StudentQuizReviewScreen(
                            classId: params['classId'] as String,
                            quizId: params['quizId'] as String,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          // Schedule route
          GoRoute(
            path: 'student-schedule',
            builder: (context, state) => const StudentScheduleScreen(),
          ),
          // Leaderboard route
          GoRoute(
            path: 'leader-board',
            builder: (context, state) => const StudentLeaderboardScreen(),
          ),
          // Gift store route
          GoRoute(
            path: 'gift-store',
            builder: (context, state) => const StudentGiftStoreScreen(),
          ),
          // Grades route
          GoRoute(
            path: 'grades',
            builder: (context, state) => const StudentGradesScreen(),
          ),
        ],
      ),
      // Courses routes
      GoRoute(
        path: '/student/courses',
        builder: (context, state) => const CourseStudentScreen(),
        routes: [
          GoRoute(
            path: 'class-in-course',
            builder: (context, state) {
              final course = state.extra as CourseModel;
              return CourseClassesScreen(course: course);
            },
          ),
        ],
      ),
      // Vocabulary routes
      GoRoute(
        path: '/student/vocabulary',
        builder: (context, state) => const VocabularyStudentScreen(),
        routes: [
          GoRoute(
            name: 'levelContent',
            path: 'level',
            builder: (context, state) {
              final level = state.extra as LevelInfoModel;
              return VocabularyLevelContentScreen(level: level);
            },
            routes: [
              GoRoute(
                name: 'moduleDetails',
                path: 'module',
                builder: (context, state) {
                  final module = state.extra as ModuleInfoModel;
                  return VocabularyModuleDetailsScreen(module: module);
                },
                routes: [
                  GoRoute(
                    name: 'lessonFlashcards',
                    path: 'lesson',
                    builder: (context, state) {
                      final lesson = state.extra as LessonInfoModel;
                      return LessonFlashcardsScreen(lesson: lesson);
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      // Profile routes
      GoRoute(
        path: '/student/profile',
        builder: (context, state) => const ProfileStudentScreen(),
        routes: [
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingsScreen(),
            routes: [
              GoRoute(
                path: 'edit-profile',
                builder: (context, state) => const EditProfileStudentScreen(),
              ),
              GoRoute(
                path: 'change-password',
                builder: (context, state) => const ChangePasswordScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
