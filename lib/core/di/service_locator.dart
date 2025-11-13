import 'package:get_it/get_it.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/domain/repositories/admin_lesson_repository.dart';
import 'package:mobile/domain/repositories/admin_vocabulary_repository.dart';
import 'package:mobile/domain/repositories/auth_repository.dart';
import 'package:mobile/domain/repositories/class_repository.dart';
import 'package:mobile/domain/repositories/course_repository.dart';
import 'package:mobile/domain/repositories/leaderboard_repository.dart';
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
import 'package:mobile/domain/repositories/module_repository.dart';
import 'package:mobile/domain/repositories/student_vocabulary_lesson_repository.dart';
import 'package:mobile/domain/repositories/student_vocabulary_level_repository.dart';
import 'package:mobile/domain/repositories/student_vocabulary_module_repository.dart';
import 'package:mobile/domain/repositories/teacher_class_repository.dart';
import 'package:mobile/domain/repositories/teacher_schedule_repository.dart';
import 'package:mobile/domain/repositories/upload_repository.dart';
import 'package:mobile/domain/repositories/user_repository.dart';
import 'package:mobile/services/auth/auth_service.dart';

final getIt = GetIt.instance;

void setupLocator() {
  getIt.registerLazySingleton(() => ApiClient());

  getIt.registerLazySingleton(() => AuthRepository(getIt<ApiClient>()));
  getIt.registerLazySingleton(() => UserRepository(getIt<ApiClient>()));
  getIt.registerLazySingleton(() => CourseRepository(getIt<ApiClient>()));
  getIt.registerLazySingleton(() => ClassRepository(getIt<ApiClient>()));
  getIt.registerLazySingleton(() => RoomRepository(getIt<ApiClient>()));
  getIt.registerLazySingleton(() => ScheduleRepository(getIt<ApiClient>()));
  getIt.registerLazySingleton(() => AdminLessonRepository(getIt<ApiClient>()));
  getIt.registerLazySingleton(
    () => AdminVocabularyRepository(getIt<ApiClient>()),
  );

  getIt.registerLazySingleton(() => TeacherClassRepository(getIt<ApiClient>()));
  getIt.registerLazySingleton(
    () => TeacherScheduleRepository(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton(() => ModuleRepository(getIt<ApiClient>()));

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
  getIt.registerLazySingleton(() => ProfileRepository(getIt<ApiClient>()));
  getIt.registerLazySingleton(() => UploadRepository(getIt<ApiClient>()));
  getIt.registerLazySingleton(() => QuizRepository(getIt<ApiClient>()));
  getIt.registerLazySingleton(() => StudentQuizRepository(getIt<ApiClient>()));
  getIt.registerLazySingleton(
    () => StudentLessonRepository(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton(
    () => StudentVocabularyLevelRepository(getIt<ApiClient>()),
  );

  // ✅ ĐĂNG KÝ REPOSITORY MỚI (MODULE)
  getIt.registerLazySingleton(
    () => StudentVocabularyModuleRepository(getIt<ApiClient>()),
  );
  // ✅ ĐĂNG KÝ REPOSITORY MỚI (LESSON)
  getIt.registerLazySingleton(
    () => StudentVocabularyLessonRepository(getIt<ApiClient>()),
  );

  getIt.registerLazySingleton(
    () => StudentFlashcardRepository(getIt<ApiClient>()),
  );

  getIt.registerLazySingleton(() => StudentGradeRepository(getIt<ApiClient>()));

  getIt.registerLazySingleton(() => LeaderboardRepository(getIt<ApiClient>()));
  // Đăng ký AuthService dùng AuthRepository
  getIt.registerLazySingleton<AuthService>(
    () => AuthService(getIt<AuthRepository>()),
  );
}
