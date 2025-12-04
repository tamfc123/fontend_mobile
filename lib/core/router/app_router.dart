import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/data/models/class_model.dart';
import 'package:mobile/data/models/course_model.dart';
import 'package:mobile/data/models/lesson_model.dart';
import 'package:mobile/data/models/module_details_model.dart';
import 'package:mobile/data/models/module_model.dart';
import 'package:mobile/data/models/student_class_model.dart';
import 'package:mobile/data/models/teacher_class_model.dart';
import 'package:mobile/data/models/user_model.dart';
import 'package:mobile/data/models/vocabulary_levels_model.dart';
import 'package:mobile/data/models/vocabulary_modules_model.dart';
import 'package:mobile/screens/admin/dashboard/admin_dashboard_screen.dart';
import 'package:mobile/screens/admin/manage_media/manage_media_screen.dart';
import 'package:mobile/screens/admin/manage_quiz/manage_quiz_screen.dart';
import 'package:mobile/screens/admin/manage_quiz/quiz_detail_screen.dart';
import 'package:mobile/screens/admin/manage_course/manage_course_screen.dart';
import 'package:mobile/screens/admin/manage_gift/manage_gift_screen.dart';
import 'package:mobile/screens/admin/manage_lesson/manage_lesson_screen.dart';
import 'package:mobile/screens/admin/manage_module/manage_module_screen.dart';
import 'package:mobile/screens/admin/manage_room/manage_room_screen.dart';
import 'package:mobile/screens/admin/manage_schedule/bulk_schedule_screen.dart';
import 'package:mobile/screens/admin/manage_schedule/manage_schedule_screen.dart';
import 'package:mobile/screens/admin/manage_vocabulary/manage_vocabulary_screen.dart';
import 'package:mobile/screens/auth/forgotpassword/forgotpassword_screen.dart';
import 'package:mobile/screens/auth/resetpassword/resetpassword_screen.dart';
import 'package:mobile/screens/auth/signup/signup_screen.dart';
import 'package:mobile/screens/auth/splash/splash_screen.dart';
import 'package:mobile/screens/auth/login/login_screen.dart';
import 'package:mobile/screens/auth/loginweb/web_login_screen.dart';
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
import 'package:mobile/screens/teacher/dashboard/teacher_dashboard_screen.dart';
import 'package:mobile/screens/teacher/teacher_layout.dart';
import 'package:mobile/screens/admin/admin_layout.dart';
import 'package:mobile/screens/admin/manage_account/manage_account_screen.dart';
import 'package:mobile/screens/admin/manage_class/manage_class_screen.dart';
import 'package:mobile/screens/teacher/manage_class/manage_teacher_class_screen.dart';
import 'package:mobile/screens/teacher/manage_schedule/manage_teacher_schedule_screen.dart';
import 'package:mobile/screens/teacher/manage_class/student_list_screen.dart';
import 'package:mobile/screens/teacher/manage_class/teacher_quiz_list_screen.dart';
import 'package:mobile/screens/admin/manage_account/create_user_screen.dart';
import 'package:mobile/screens/admin/manage_account/admin_edit_user_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/login/web',
      builder: (context, state) => const WebLoginScreen(),
    ),
    GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
    GoRoute(
      path: '/forgotpassword',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/resetpassword',
      builder: (context, state) => const ResetpasswordScreen(),
    ),

    ShellRoute(
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
        GoRoute(
          path: '/student',
          builder: (context, state) => const HomeStudentScreen(),
          routes: [
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
                    GoRoute(
                      path: 'quizzes', // Path sẽ là /module-class/quizzes
                      name: 'student-quiz-list', // Đặt tên để gọi cho dễ
                      builder: (context, state) {
                        // Nhận StudentClassModel từ 'extra'
                        final classModel = state.extra as StudentClassModel;
                        return StudentQuizListScreen(
                          classId: classModel.classId,
                          className: classModel.className,
                        );
                      },
                      routes: [
                        GoRoute(
                          path: 'take', // Path sẽ là /module-class/quizzes/take
                          name: 'student-quiz-taking',
                          builder: (context, state) {
                            // Chúng ta sẽ gửi một Map chứa 3 giá trị qua 'extra'
                            final params = state.extra as Map<String, dynamic>;

                            return StudentQuizTakingScreen(
                              classId: params['classId'] as String,
                              quizId: params['quizId'] as String,
                              quizTitle: params['quizTitle'] as String,
                            );
                          },
                        ),
                        GoRoute(
                          path: 'review', // Path: /.../quizzes/review
                          name: 'student-quiz-review',
                          builder: (context, state) {
                            // Gửi Map {classId, quizId} qua 'extra'
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
            GoRoute(
              path: 'student-schedule',
              builder: (context, state) => const StudentScheduleScreen(),
            ),
            GoRoute(
              path: 'leader-board',
              builder: (context, state) => const StudentLeaderboardScreen(),
            ),
            GoRoute(
              path: 'gift-store',
              builder: (context, state) => const StudentGiftStoreScreen(),
            ),
            GoRoute(
              path: 'grades',
              builder: (context, state) => const StudentGradesScreen(),
            ),
          ],
        ),
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
        GoRoute(
          path: '/student/vocabulary',
          builder: (context, state) => const VocabularyStudentScreen(),
          routes: [
            GoRoute(
              name:
                  'levelContent', // Khớp với tên dùng trong VocabularyStudentScreen
              path: 'level', // Ví dụ: /student/vocabulary/level
              builder: (context, state) {
                // Lấy 'extra' được truyền từ màn hình trước
                final level = state.extra as LevelInfoModel;
                return VocabularyLevelContentScreen(level: level);
              },
              routes: [
                GoRoute(
                  name:
                      'moduleDetails', // Khớp với tên dùng trong VocabularyLevelContentScreen
                  path: 'module', // Ví dụ: /student/vocabulary/level/module
                  builder: (context, state) {
                    final module = state.extra as ModuleInfoModel;
                    return VocabularyModuleDetailsScreen(module: module);
                  },
                  routes: [
                    // ✅ THÊM MỚI: Route 3 (Màn hình học Flashcard)
                    GoRoute(
                      name:
                          'lessonFlashcards', // Khớp với tên dùng trong VocabularyModuleDetailsScreen
                      path:
                          'lesson', // Ví dụ: /student/vocabulary/level/module/lesson
                      builder: (context, state) {
                        final lesson = state.extra as LessonInfoModel;

                        // Trả về màn hình Flashcard thật sự
                        return LessonFlashcardsScreen(lesson: lesson);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
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
    ),

    // Khu vực Admin dùng ShellRoute để giữ layout chung
    ShellRoute(
      builder: (context, state, child) => AdminLayout(child: child),
      routes: [
        GoRoute(
          path: '/admin', // ShellRoute root
          builder: (context, state) => const AdminDashboardScreen(),
          routes: [
            GoRoute(
              path: 'users',
              builder: (context, state) => const ManageAccountScreen(),
              routes: [
                GoRoute(
                  path: 'create', // Sẽ khớp với /admin/users/create
                  name:
                      'adminCreateUser', // Tên bạn dùng trong context.pushNamed
                  builder: (context, state) => const CreateUserScreen(),
                ),
                GoRoute(
                  path: 'update', // Path: /admin/users/update
                  name: 'adminUpdateUser',
                  builder: (context, state) {
                    // 1. Lấy user object được gửi qua 'extra'
                    final user = state.extra as UserModel?;

                    // 2. Báo lỗi nếu không có user
                    if (user == null) {
                      return const Scaffold(
                        body: Center(
                          child: Text('Lỗi: Không tìm thấy người dùng để sửa.'),
                        ),
                      );
                    }
                    // 3. Nếu có, mở màn hình Edit
                    return EditUserScreen(user: user);
                  },
                ),
              ],
            ),
            GoRoute(
              path: 'courses',
              builder: (context, state) => const ManageCourseScreen(),
              routes: [
                GoRoute(
                  path: ':courseId/modules',
                  builder: (context, state) {
                    final course = state.extra as CourseModel?;
                    if (course == null) {
                      return const Scaffold(
                        body: Center(
                          child: Text('Lỗi: Không tìm thấy khóa học'),
                        ),
                      );
                    }
                    return ManageModuleScreen(course: course);
                  },
                  routes: [
                    GoRoute(
                      path: ':moduleId/lessons',

                      builder: (context, state) {
                        final module = state.extra as ModuleModel?;
                        if (module == null) {
                          return const Scaffold(
                            body: Center(
                              child: Text('Lỗi: Không tìm thấy chương học'),
                            ),
                          );
                        }
                        return ManageLessonScreen(module: module);
                      },
                      routes: [
                        GoRoute(
                          path: ':lessonId/vocabularies',

                          builder: (context, state) {
                            final lesson = state.extra as LessonModel?;
                            if (lesson == null) {
                              return const Scaffold(
                                body: Center(
                                  child: Text('Lỗi: Không tìm thấy bài học'),
                                ),
                              );
                            }
                            return ManageVocabularyScreen(lesson: lesson);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                GoRoute(
                  path: ':courseId/quizzes', // Path: /admin/courses/123/quizzes
                  builder: (context, state) {
                    final course = state.extra as CourseModel?;
                    if (course == null) {
                      return const Scaffold(
                        body: Center(child: Text('Lỗi: Data khóa học bị null')),
                      );
                    }

                    return ManageQuizScreen(course: course);
                  },
                  routes: [
                    // Route xem chi tiết/sửa Quiz
                    GoRoute(
                      path: ':quizId', // Path: /admin/courses/123/quizzes/456
                      builder: (context, state) {
                        // Lấy dữ liệu truyền qua
                        final extras = state.extra as Map<String, dynamic>;
                        final course = extras['course'] as CourseModel;
                        final quizId = state.pathParameters['quizId']!;
                        return QuizDetailScreen(course: course, quizId: quizId);
                      },
                    ),
                  ],
                ),
              ],
            ),
            GoRoute(
              path: 'classes',
              builder: (context, state) => const ManageClassScreen(),
            ),
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
            GoRoute(
              path: 'rooms',
              builder: (context, state) => const ManageRoomScreen(),
            ),
            GoRoute(
              path: 'media', // Path: /admin/media
              builder:
                  (context, state) =>
                      const ManageMediaScreen(), // 👈 Màn hình này ta sẽ tạo ở bước sau
            ),
            GoRoute(
              path: 'gifts', // /admin/gifts
              builder: (context, state) => const ManageGiftScreen(),
            ),
          ],
        ),
      ],
    ),
    // Khu vực Teacher dùng ShellRoute để giữ layout chung
    ShellRoute(
      builder: (context, state, child) => TeacherLayout(child: child),
      routes: [
        GoRoute(
          path: '/teacher', // ShellRoute root
          builder: (context, state) => const DashboardTeacherScreen(),
          routes: [
            GoRoute(
              path: 'teacherClasses',
              builder: (context, state) => const ManageTeacherClassScreen(),
              routes: [
                GoRoute(
                  path:
                      ':classId/students', // Path: /teacher/teacherClasses/123/students
                  builder: (context, state) {
                    final classId = state.pathParameters['classId']!;
                    final className = state.extra as String;

                    return StudentListScreen(
                      classId: classId,
                      className: className,
                    );
                  },
                ),
                GoRoute(
                  path:
                      ':classId/quizzes', // Path: /teacher/teacherClasses/123/quizzes
                  builder: (context, state) {
                    final extra = state.extra;
                    ClassModel classModel;

                    // ✅ FIX LỖI TYPE ERROR TẠI ĐÂY
                    if (extra is TeacherClassModel) {
                      // Convert TeacherClassModel -> ClassModel (Map dữ liệu cần thiết)
                      classModel = ClassModel(
                        id: extra.id,
                        name: extra.name,
                        teacherId: '',
                        courseId: '',
                        // ✅ Thêm courseName lấy từ TeacherClassModel (hoặc chuỗi rỗng nếu null)
                        courseName: extra.courseName ?? '',
                      );
                    } else {
                      classModel = extra as ClassModel;
                    }

                    return TeacherQuizListScreen(classModel: classModel);
                  },
                ),
              ],
            ),
            GoRoute(
              path: 'schedules',
              builder: (context, state) => const TeacherScheduleScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
