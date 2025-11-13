import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:mobile/core/di/service_locator.dart'; // 👈 2. IMPORT
import 'package:mobile/domain/repositories/admin_lesson_repository.dart';
import 'package:mobile/domain/repositories/admin_vocabulary_repository.dart';
import 'package:mobile/domain/repositories/auth_repository.dart';
import 'package:mobile/domain/repositories/class_repository.dart';
import 'package:mobile/domain/repositories/course_repository.dart';
import 'package:mobile/domain/repositories/leaderboard_repository.dart';
import 'package:mobile/domain/repositories/module_repository.dart';
import 'package:mobile/domain/repositories/profile_repository.dart';
import 'package:mobile/domain/repositories/quiz_repository.dart';
import 'package:mobile/domain/repositories/room_repository.dart';
import 'package:mobile/domain/repositories/schedule_repository.dart';
import 'package:mobile/domain/repositories/student_class_repository.dart';
import 'package:mobile/domain/repositories/student_course_repository.dart';
import 'package:mobile/domain/repositories/student_flashcard_repository.dart';
import 'package:mobile/domain/repositories/student_grade_repository.dart';
import 'package:mobile/domain/repositories/student_lesson_repository.dart';
import 'package:mobile/domain/repositories/student_module_repository.dart';
import 'package:mobile/domain/repositories/student_quiz_repository.dart';
import 'package:mobile/domain/repositories/student_schedule_repository.dart';
import 'package:mobile/domain/repositories/student_vocabulary_lesson_repository.dart';
import 'package:mobile/domain/repositories/student_vocabulary_level_repository.dart';
import 'package:mobile/domain/repositories/student_vocabulary_module_repository.dart';
import 'package:mobile/domain/repositories/teacher_class_repository.dart';
import 'package:mobile/domain/repositories/teacher_schedule_repository.dart';
import 'package:mobile/domain/repositories/upload_repository.dart';
import 'package:mobile/domain/repositories/user_repository.dart';
import 'package:mobile/services/admin/admin_lesson_service.dart';
import 'package:mobile/services/admin/admin_vocabulary_service.dart';
import 'package:mobile/services/admin/course_service.dart';
import 'package:mobile/services/admin/module_service.dart';
import 'package:mobile/services/admin/room_service.dart';
import 'package:mobile/services/student/leaderboard_service.dart';
import 'package:mobile/services/student/student_flashcard_service.dart';
import 'package:mobile/services/student/student_grade_service.dart';
import 'package:mobile/services/student/student_lesson_service.dart';
import 'package:mobile/services/student/student_profile_service.dart';
import 'package:mobile/services/student/student_class_service.dart';
import 'package:mobile/services/student/student_course_class_service.dart';
import 'package:mobile/services/student/student_course_service.dart';
import 'package:mobile/services/student/student_quiz_service.dart';
import 'package:mobile/services/student/student_vocabulary_lesson_service.dart';
import 'package:mobile/services/student/student_vocabulary_level_service.dart';
import 'package:mobile/services/student/student_vocabulary_module_service.dart';
import 'package:mobile/services/teacher/teacher_media_service.dart';
import 'package:mobile/services/teacher/teacher_quiz_service.dart';
import 'package:provider/provider.dart';
import 'package:mobile/services/admin/schedule_service.dart';
import 'package:mobile/services/auth/auth_service.dart';
import 'package:mobile/services/admin/class_service.dart';
import 'package:mobile/services/student/student_module_service.dart';
import 'package:mobile/services/student/student_schedule_service.dart';
import 'package:mobile/services/teacher/teacher_class_service.dart';
import 'package:mobile/services/admin/user_service.dart';
import 'package:mobile/services/teacher/teacher_schedule_service.dart';
import 'package:mobile/core/router/app_router.dart';

// 3. SỬA LẠI HÀM MAIN
void main() async {
  // Đảm bảo Flutter bindings đã sẵn sàng
  WidgetsFlutterBinding.ensureInitialized();

  // 4. GỌI setupLocator() TRƯỚC KHI CHẠY APP
  // Hàm này sẽ đăng ký ApiClient vào 'getIt'
  setupLocator();

  // 5. CHẠY APP VỚI MULTIPROVIDER
  runApp(
    MultiProvider(
      providers: [
        // 6. SỬA LẠI TẤT CẢ CÁC HÀM 'create'
        // Truyền ApiClient (lấy từ getIt) vào hàm khởi tạo của Service
        Provider(create: (_) => getIt<UploadRepository>()),
        ChangeNotifierProvider(
          create: (_) => AuthService(getIt<AuthRepository>()),
        ),
        ChangeNotifierProvider(
          create: (_) => UserService(getIt<UserRepository>()),
        ),
        ChangeNotifierProvider(
          create: (_) => CourseService(getIt<CourseRepository>()),
        ),
        ChangeNotifierProvider(
          create: (_) => ModuleService(getIt<ModuleRepository>()),
        ),
        ChangeNotifierProvider(
          create: (_) => ClassService(getIt<ClassRepository>()),
        ),
        ChangeNotifierProvider(
          create: (_) => RoomService(getIt<RoomRepository>()),
        ),
        ChangeNotifierProvider(
          create: (_) => ScheduleService(getIt<ScheduleRepository>()),
        ),
        ChangeNotifierProvider(
          create: (_) => AdminLessonService(getIt<AdminLessonRepository>()),
        ),
        ChangeNotifierProvider(
          create:
              (_) => AdminVocabularyService(getIt<AdminVocabularyRepository>()),
        ),
        ChangeNotifierProvider(
          create: (_) => TeacherClassService(getIt<TeacherClassRepository>()),
        ),
        ChangeNotifierProvider(
          create:
              (_) => TeacherScheduleService(getIt<TeacherScheduleRepository>()),
        ),

        ChangeNotifierProvider(
          create: (_) => QuizService(getIt<QuizRepository>()),
        ),

        ChangeNotifierProvider(
          create:
              (_) => StudentScheduleService(getIt<StudentScheduleRepository>()),
        ),

        ChangeNotifierProvider(
          create: (_) => StudentModuleService(getIt<StudentModuleRepository>()),
        ),
        ChangeNotifierProvider(
          create: (_) => StudentCourseService(getIt<StudentCourseRepository>()),
        ),
        ChangeNotifierProvider(
          create:
              (_) =>
                  StudentCourseClassService(getIt<StudentCourseRepository>()),
        ),
        ChangeNotifierProvider(
          create: (_) => StudentClassService(getIt<StudentClassRepository>()),
        ),
        ChangeNotifierProvider(
          create: (_) => StudentProfileService(getIt<ProfileRepository>()),
        ),
        ChangeNotifierProvider(
          create: (_) => StudentQuizService(getIt<StudentQuizRepository>()),
        ),
        ChangeNotifierProvider(
          create: (_) => StudentLessonService(getIt<StudentLessonRepository>()),
        ),
        ChangeNotifierProvider(
          create:
              (_) => StudentVocabularyLevelService(
                getIt<StudentVocabularyLevelRepository>(),
              ),
        ),
        ChangeNotifierProvider(
          create:
              (_) => StudentVocabularyModuleService(
                getIt<StudentVocabularyModuleRepository>(),
              ),
        ),
        ChangeNotifierProvider(
          create:
              (_) => StudentVocabularyLessonService(
                getIt<StudentVocabularyLessonRepository>(),
              ),
        ),
        ChangeNotifierProvider(
          create:
              (_) =>
                  StudentFlashcardService(getIt<StudentFlashcardRepository>()),
        ),
        ChangeNotifierProvider(
          create: (_) => StudentGradeService(getIt<StudentGradeRepository>()),
        ),
        ChangeNotifierProvider(
          create:
              (_) => LeaderboardService(
                getIt<LeaderboardRepository>(),
                getIt<AuthService>(),
              ),
        ),
        ChangeNotifierProvider(
          create: (_) => TeacherMediaService(getIt<UploadRepository>()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

// Class MyApp không có gì thay đổi
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        scaffoldBackgroundColor: Colors.white,
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        quill.FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: const [Locale('vi')],
    );
  }
}
