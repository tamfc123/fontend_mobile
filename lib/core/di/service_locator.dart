import 'package:get_it/get_it.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/domain/repositories/admin_dashboard_repository.dart';
import 'package:mobile/domain/repositories/admin_lesson_repository.dart';
import 'package:mobile/domain/repositories/admin_quiz_repository.dart';
import 'package:mobile/domain/repositories/admin_vocabulary_repository.dart';
import 'package:mobile/domain/repositories/auth_repository.dart';
import 'package:mobile/domain/repositories/admin_class_repository.dart';
import 'package:mobile/domain/repositories/admin_course_repository.dart';
import 'package:mobile/domain/repositories/student_leaderboard_repository.dart';
import 'package:mobile/domain/repositories/student_profile_repository.dart';
import 'package:mobile/domain/repositories/teaacher_dashboard_repository.dart';
import 'package:mobile/domain/repositories/admin_room_repository.dart';
import 'package:mobile/domain/repositories/admin_schedule_repository.dart';
import 'package:mobile/domain/repositories/student_class_repository.dart';
import 'package:mobile/domain/repositories/student_course_repository.dart';
import 'package:mobile/domain/repositories/student_flashcard_repository.dart';
import 'package:mobile/domain/repositories/student_grade_repository.dart';
import 'package:mobile/domain/repositories/student_lesson_repository.dart';
import 'package:mobile/domain/repositories/student_module_repository.dart';
import 'package:mobile/domain/repositories/student_quiz_repository.dart';
import 'package:mobile/domain/repositories/student_schedule_repository.dart';
import 'package:mobile/domain/repositories/admin_module_repository.dart';
import 'package:mobile/domain/repositories/student_vocabulary_lesson_repository.dart';
import 'package:mobile/domain/repositories/student_vocabulary_level_repository.dart';
import 'package:mobile/domain/repositories/student_vocabulary_module_repository.dart';
import 'package:mobile/domain/repositories/teacher_class_repository.dart';
import 'package:mobile/domain/repositories/teacher_schedule_repository.dart';
import 'package:mobile/domain/repositories/upload_repository.dart';
import 'package:mobile/domain/repositories/admin_user_repository.dart';
import 'package:mobile/services/auth/auth_service.dart';
import 'package:mobile/services/student/student_class_service.dart';
import 'package:mobile/services/student/student_course_class_service.dart';

final getIt = GetIt.instance;

void setupLocator() {
  getIt.registerLazySingleton(() => ApiClient());

  getIt.registerLazySingleton(() => AuthRepository(getIt<ApiClient>()));
  getIt.registerLazySingleton(() => AdminUserRepository(getIt<ApiClient>()));
  getIt.registerLazySingleton(() => AdminCourseRepository(getIt<ApiClient>()));
  getIt.registerLazySingleton(() => AdminClassRepository(getIt<ApiClient>()));
  getIt.registerLazySingleton(() => AdminRoomRepository(getIt<ApiClient>()));
  getIt.registerLazySingleton(
    () => AdminScheduleRepository(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton(() => AdminLessonRepository(getIt<ApiClient>()));
  getIt.registerLazySingleton(
    () => AdminVocabularyRepository(getIt<ApiClient>()),
  );

  getIt.registerLazySingleton(() => TeacherClassRepository(getIt<ApiClient>()));
  getIt.registerLazySingleton(
    () => TeacherScheduleRepository(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton(() => AdminModuleRepository(getIt<ApiClient>()));
  getIt.registerLazySingleton(
    () => TeaacherDashboardRepository(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton(
    () => StudentScheduleRepository(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton(
    () => StudentModuleRepository(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton(
    () => StudentCourseRepository(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton(() => StudentClassRepository(getIt<ApiClient>()));
  getIt.registerLazySingleton(
    () => StudentProfileRepository(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton(() => UploadRepository(getIt<ApiClient>()));
  getIt.registerLazySingleton(() => AdminQuizRepository(getIt<ApiClient>()));
  getIt.registerLazySingleton(() => StudentQuizRepository(getIt<ApiClient>()));
  getIt.registerLazySingleton(
    () => StudentLessonRepository(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton(
    () => StudentVocabularyLevelRepository(getIt<ApiClient>()),
  );

  getIt.registerLazySingleton(
    () => StudentVocabularyModuleRepository(getIt<ApiClient>()),
  );

  getIt.registerLazySingleton(
    () => StudentVocabularyLessonRepository(getIt<ApiClient>()),
  );

  getIt.registerLazySingleton(
    () => StudentFlashcardRepository(getIt<ApiClient>()),
  );

  getIt.registerLazySingleton(() => StudentGradeRepository(getIt<ApiClient>()));

  getIt.registerLazySingleton(
    () => StudentLeaderboardRepository(getIt<ApiClient>()),
  );
  // Đăng ký AuthService dùng AuthRepository
  getIt.registerLazySingleton<AuthService>(
    () => AuthService(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton(
    () => AdminDashboardRepository(getIt<ApiClient>()),
  );
  getIt.registerFactory<StudentCourseClassService>(
    () => StudentCourseClassService(getIt<StudentCourseRepository>()),
  );

  getIt.registerFactory<StudentClassService>(
    () => StudentClassService(getIt<StudentClassRepository>()),
  );
}
