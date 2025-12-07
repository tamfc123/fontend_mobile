import 'package:get_it/get_it.dart';
import 'package:mobile/core/api/api_client.dart';
// Auth & Common
import 'package:mobile/domain/repositories/auth/auth_repository.dart';
import 'package:mobile/domain/repositories/common/upload_repository.dart';
// Admin
import 'package:mobile/domain/repositories/admin/admin_class_repository.dart';
import 'package:mobile/domain/repositories/admin/admin_course_repository.dart';
import 'package:mobile/domain/repositories/admin/admin_dashboard_repository.dart';
import 'package:mobile/domain/repositories/admin/admin_gift_repository.dart';
import 'package:mobile/domain/repositories/admin/admin_gift_redemption_repository.dart';
import 'package:mobile/domain/repositories/admin/admin_lesson_repository.dart';
import 'package:mobile/domain/repositories/admin/admin_media_repository.dart';
import 'package:mobile/domain/repositories/admin/admin_module_repository.dart';
import 'package:mobile/domain/repositories/admin/admin_quiz_repository.dart';
import 'package:mobile/domain/repositories/admin/admin_redemption_repository.dart';
import 'package:mobile/domain/repositories/admin/admin_room_repository.dart';
import 'package:mobile/domain/repositories/admin/admin_schedule_repository.dart';
import 'package:mobile/domain/repositories/admin/admin_user_repository.dart';
import 'package:mobile/domain/repositories/admin/admin_vocabulary_repository.dart';
// Teacher
import 'package:mobile/domain/repositories/teacher/teaacher_dashboard_repository.dart';
import 'package:mobile/domain/repositories/teacher/teacher_class_repository.dart';
import 'package:mobile/domain/repositories/teacher/teacher_quiz_repository.dart';
import 'package:mobile/domain/repositories/teacher/teacher_schedule_repository.dart';
// Student
import 'package:mobile/domain/repositories/student/student_class_repository.dart';
import 'package:mobile/domain/repositories/student/student_course_repository.dart';
import 'package:mobile/domain/repositories/student/student_flashcard_repository.dart';
import 'package:mobile/domain/repositories/student/student_gift_repository.dart';
import 'package:mobile/domain/repositories/student/student_grade_repository.dart';
import 'package:mobile/domain/repositories/student/student_leaderboard_repository.dart';
import 'package:mobile/domain/repositories/student/student_lesson_repository.dart';
import 'package:mobile/domain/repositories/student/student_module_repository.dart';
import 'package:mobile/domain/repositories/student/student_profile_repository.dart';
import 'package:mobile/domain/repositories/student/student_quiz_repository.dart';
import 'package:mobile/domain/repositories/student/student_schedule_repository.dart';
import 'package:mobile/domain/repositories/student/student_vocabulary_lesson_repository.dart';
import 'package:mobile/domain/repositories/student/student_vocabulary_level_repository.dart';
import 'package:mobile/domain/repositories/student/student_vocabulary_module_repository.dart';

final getIt = GetIt.instance;
void setupLocator() {
  // ===========================================================================
  // 1. CORE & EXTERNAL (Singleton)
  // ===========================================================================
  getIt.registerLazySingleton(() => ApiClient());

  // ===========================================================================
  // 2. AUTH & COMMON REPOSITORIES
  // ===========================================================================
  getIt.registerLazySingleton(() => AuthRepository(getIt<ApiClient>()));
  getIt.registerLazySingleton(() => UploadRepository(getIt<ApiClient>()));

  // ===========================================================================
  // 3. ADMIN REPOSITORIES
  // ===========================================================================
  getIt.registerLazySingleton(
    () => AdminDashboardRepository(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton(() => AdminUserRepository(getIt<ApiClient>()));
  getIt.registerLazySingleton(() => AdminCourseRepository(getIt<ApiClient>()));
  getIt.registerLazySingleton(() => AdminClassRepository(getIt<ApiClient>()));
  getIt.registerLazySingleton(() => AdminRoomRepository(getIt<ApiClient>()));
  getIt.registerLazySingleton(
    () => AdminScheduleRepository(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton(() => AdminModuleRepository(getIt<ApiClient>()));
  getIt.registerLazySingleton(() => AdminLessonRepository(getIt<ApiClient>()));
  getIt.registerLazySingleton(
    () => AdminVocabularyRepository(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton(() => AdminQuizRepository(getIt<ApiClient>()));
  getIt.registerLazySingleton(() => AdminMediaRepository(getIt<ApiClient>()));
  getIt.registerLazySingleton(() => AdminGiftRepository(getIt<ApiClient>()));
  getIt.registerLazySingleton(
    () => AdminRedemptionRepository(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton(
    () => AdminGiftRedemptionRepository(getIt<ApiClient>()),
  );

  // ===========================================================================
  // 4. TEACHER REPOSITORIES
  // ===========================================================================
  getIt.registerLazySingleton(
    () => TeaacherDashboardRepository(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton(() => TeacherClassRepository(getIt<ApiClient>()));
  getIt.registerLazySingleton(
    () => TeacherScheduleRepository(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton(() => TeacherQuizRepository(getIt<ApiClient>()));

  // ===========================================================================
  // 5. STUDENT REPOSITORIES
  // ===========================================================================
  getIt.registerLazySingleton(
    () => StudentProfileRepository(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton(
    () => StudentCourseRepository(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton(() => StudentClassRepository(getIt<ApiClient>()));
  getIt.registerLazySingleton(
    () => StudentScheduleRepository(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton(
    () => StudentModuleRepository(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton(
    () => StudentLessonRepository(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton(() => StudentQuizRepository(getIt<ApiClient>()));
  getIt.registerLazySingleton(() => StudentGradeRepository(getIt<ApiClient>()));
  getIt.registerLazySingleton(
    () => StudentLeaderboardRepository(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton(
    () => StudentFlashcardRepository(getIt<ApiClient>()),
  );

  // Student Vocabulary Group
  getIt.registerLazySingleton(
    () => StudentVocabularyLevelRepository(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton(
    () => StudentVocabularyModuleRepository(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton(
    () => StudentVocabularyLessonRepository(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton(() => StudentGiftRepository(getIt<ApiClient>()));

  // ===========================================================================
  // 6. SERVICES: ĐÃ XÓA
  // Lý do: Service (ChangeNotifier) được khởi tạo và quản lý vòng đời bởi
  // MultiProvider trong main.dart. Không đăng ký ở đây để tránh trùng lặp instance.
  // ===========================================================================
}
