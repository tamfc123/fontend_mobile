import 'package:mobile/core/di/service_locator.dart';
import 'package:mobile/domain/repositories/student_class_repository.dart';
import 'package:mobile/domain/repositories/student_course_repository.dart';
import 'package:mobile/domain/repositories/student_flashcard_repository.dart';
import 'package:mobile/domain/repositories/student_gift_repository.dart';
import 'package:mobile/domain/repositories/student_grade_repository.dart';
import 'package:mobile/domain/repositories/student_leaderboard_repository.dart';
import 'package:mobile/domain/repositories/student_lesson_repository.dart';
import 'package:mobile/domain/repositories/student_module_repository.dart';
import 'package:mobile/domain/repositories/student_profile_repository.dart';
import 'package:mobile/domain/repositories/student_quiz_repository.dart';
import 'package:mobile/domain/repositories/student_schedule_repository.dart';
import 'package:mobile/domain/repositories/student_vocabulary_lesson_repository.dart';
import 'package:mobile/domain/repositories/student_vocabulary_level_repository.dart';
import 'package:mobile/domain/repositories/student_vocabulary_module_repository.dart';
import 'package:mobile/services/student/student_class_service.dart';
import 'package:mobile/services/student/student_course_class_service.dart';
import 'package:mobile/services/student/student_course_service.dart';
import 'package:mobile/services/student/student_flashcard_service.dart';
import 'package:mobile/services/student/student_gift_service.dart';
import 'package:mobile/services/student/student_grade_service.dart';
import 'package:mobile/services/student/student_leaderboard_service.dart';
import 'package:mobile/services/student/student_lesson_service.dart';
import 'package:mobile/services/student/student_module_service.dart';
import 'package:mobile/services/student/student_profile_service.dart';
import 'package:mobile/services/student/student_quiz_service.dart';
import 'package:mobile/services/student/student_schedule_service.dart';
import 'package:mobile/services/student/student_vocabulary_lesson_service.dart';
import 'package:mobile/services/student/student_vocabulary_level_service.dart';
import 'package:mobile/services/student/student_vocabulary_module_service.dart';
import 'package:provider/provider.dart';

final studentProviders = [
  // 1. Schedule Service
  ChangeNotifierProvider<StudentScheduleService>(
    create: (_) => StudentScheduleService(getIt<StudentScheduleRepository>()),
  ),

  // 2. Module Service
  ChangeNotifierProvider<StudentModuleService>(
    create: (_) => StudentModuleService(getIt<StudentModuleRepository>()),
  ),

  // 3. Course Service
  ChangeNotifierProvider<StudentCourseService>(
    create: (_) => StudentCourseService(getIt<StudentCourseRepository>()),
  ),

  // 4. Course Class Service (Lấy trực tiếp từ GetIt)
  ChangeNotifierProvider<StudentCourseClassService>(
    create: (_) => StudentCourseClassService(getIt<StudentCourseRepository>()),
  ),

  // 5. Class Service (Lấy trực tiếp từ GetIt)
  ChangeNotifierProvider<StudentClassService>(
    create: (_) => StudentClassService(getIt<StudentClassRepository>()),
  ),

  // 6. Gift Service
  ChangeNotifierProvider<StudentGiftService>(
    create: (_) => StudentGiftService(getIt<StudentGiftRepository>()),
  ),

  // 7. Profile Service
  ChangeNotifierProvider<StudentProfileService>(
    create: (_) => StudentProfileService(getIt<StudentProfileRepository>()),
  ),

  // 8. Quiz Service
  ChangeNotifierProvider<StudentQuizService>(
    create: (_) => StudentQuizService(getIt<StudentQuizRepository>()),
  ),

  // 9. Lesson Service
  ChangeNotifierProvider<StudentLessonService>(
    create: (_) => StudentLessonService(getIt<StudentLessonRepository>()),
  ),

  // 10. Vocabulary Level Service
  ChangeNotifierProvider<StudentVocabularyLevelService>(
    create:
        (_) => StudentVocabularyLevelService(
          getIt<StudentVocabularyLevelRepository>(),
        ),
  ),

  // 11. Vocabulary Module Service
  ChangeNotifierProvider<StudentVocabularyModuleService>(
    create:
        (_) => StudentVocabularyModuleService(
          getIt<StudentVocabularyModuleRepository>(),
        ),
  ),

  // 12. Vocabulary Lesson Service
  ChangeNotifierProvider<StudentVocabularyLessonService>(
    create:
        (_) => StudentVocabularyLessonService(
          getIt<StudentVocabularyLessonRepository>(),
        ),
  ),

  // 13. Flashcard Service
  ChangeNotifierProvider<StudentFlashcardService>(
    create: (_) => StudentFlashcardService(getIt<StudentFlashcardRepository>()),
  ),

  // 14. Grade Service
  ChangeNotifierProvider<StudentGradeService>(
    create: (_) => StudentGradeService(getIt<StudentGradeRepository>()),
  ),

  // 15. Leaderboard Service
  ChangeNotifierProvider<StudentLeaderboardService>(
    create:
        (_) => StudentLeaderboardService(getIt<StudentLeaderboardRepository>()),
  ),
];
