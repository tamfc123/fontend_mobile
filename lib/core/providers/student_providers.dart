import 'package:mobile/core/di/service_locator.dart';
import 'package:mobile/domain/repositories/student/student_class_repository.dart';
import 'package:mobile/domain/repositories/student/student_lesson_repository.dart';
import 'package:mobile/domain/repositories/student/student_course_repository.dart';
import 'package:mobile/domain/repositories/student/student_flashcard_repository.dart';
import 'package:mobile/domain/repositories/student/student_gift_repository.dart';
import 'package:mobile/domain/repositories/student/student_grade_repository.dart';
import 'package:mobile/domain/repositories/student/student_leaderboard_repository.dart';
import 'package:mobile/domain/repositories/student/student_module_repository.dart';
import 'package:mobile/domain/repositories/student/student_profile_repository.dart';
import 'package:mobile/domain/repositories/student/student_quiz_repository.dart';
import 'package:mobile/domain/repositories/student/student_schedule_repository.dart';
import 'package:mobile/domain/repositories/student/student_vocabulary_lesson_repository.dart';
import 'package:mobile/domain/repositories/student/student_vocabulary_level_repository.dart';
import 'package:mobile/domain/repositories/student/student_vocabulary_module_repository.dart';
import 'package:mobile/screens/student/classes/student_class_detail_view_model.dart';
import 'package:mobile/screens/student/classes/student_classes_view_model.dart';
import 'package:mobile/screens/student/course/student_course_class_view_model.dart';
import 'package:mobile/screens/student/course/student_course_view_model.dart';
import 'package:mobile/screens/student/grades/student_grades_view_model.dart';
import 'package:mobile/screens/student/leaderboard/student_leaderboard_view_model.dart';
import 'package:mobile/screens/student/profile/student_profile_view_model.dart';
import 'package:mobile/screens/student/gift_store/student_gift_view_model.dart';
import 'package:mobile/screens/student/schedule/student_schedule_view_model.dart';
import 'package:mobile/screens/student/quiz/student_quiz_view_model.dart';
import 'package:mobile/screens/student/flashcards/student_flashcard_view_model.dart';
import 'package:mobile/screens/student/vocabulary/student_vocabulary_lesson_view_model.dart';
import 'package:mobile/screens/student/vocabulary/student_vocabulary_module_view_model.dart';
import 'package:mobile/screens/student/vocabulary/student_vocabulary_view_model.dart';
import 'package:mobile/services/student/student_lesson_service.dart';
import 'package:provider/provider.dart';

final studentProviders = [
  // ✅ Schedule Module ViewModel (MVVM Refactored)
  ChangeNotifierProvider<StudentScheduleViewModel>(
    create: (_) => StudentScheduleViewModel(getIt<StudentScheduleRepository>()),
  ),

  // ✅ Classes Module ViewModels (MVVM Refactored - Service removed)
  ChangeNotifierProvider<StudentClassesViewModel>(
    create: (_) => StudentClassesViewModel(getIt<StudentClassRepository>()),
  ),
  ChangeNotifierProvider<StudentClassDetailViewModel>(
    create:
        (_) => StudentClassDetailViewModel(getIt<StudentModuleRepository>()),
  ),

  // ✅ Course Module ViewModels (MVVM Refactored)
  ChangeNotifierProvider<StudentCourseViewModel>(
    create: (_) => StudentCourseViewModel(getIt<StudentCourseRepository>()),
  ),
  ChangeNotifierProvider<StudentCourseClassViewModel>(
    create:
        (_) => StudentCourseClassViewModel(
          getIt<StudentCourseRepository>(),
          getIt<StudentClassRepository>(),
        ),
  ),

  // ✅ Grades Module ViewModels (MVVM Refactored)
  ChangeNotifierProvider<StudentGradesViewModel>(
    create: (_) => StudentGradesViewModel(getIt<StudentGradeRepository>()),
  ),

  // ✅ Profile Module ViewModel (MVVM Refactored)
  ChangeNotifierProvider<StudentProfileViewModel>(
    create: (_) => StudentProfileViewModel(getIt<StudentProfileRepository>()),
  ),

  // ✅ Leaderboard Module ViewModel (MVVM Refactored)
  ChangeNotifierProvider<StudentLeaderboardViewModel>(
    create:
        (_) =>
            StudentLeaderboardViewModel(getIt<StudentLeaderboardRepository>()),
  ),

  // ✅ Vocabulary Module ViewModel (MVVM Refactored)
  ChangeNotifierProvider<StudentVocabularyViewModel>(
    create:
        (_) => StudentVocabularyViewModel(
          getIt<StudentVocabularyLevelRepository>(),
        ),
  ),

  // ✅ Vocabulary Lesson ViewModel (MVVM Refactored)
  ChangeNotifierProvider<StudentVocabularyLessonViewModel>(
    create:
        (_) => StudentVocabularyLessonViewModel(
          getIt<StudentVocabularyLessonRepository>(),
        ),
  ),

  // ✅ Vocabulary Module ViewModel (MVVM Refactored)
  ChangeNotifierProvider<StudentVocabularyModuleViewModel>(
    create:
        (_) => StudentVocabularyModuleViewModel(
          getIt<StudentVocabularyModuleRepository>(),
        ),
  ),

  // ✅ Flashcard ViewModel (MVVM Refactored)
  ChangeNotifierProvider<StudentFlashcardViewModel>(
    create:
        (_) => StudentFlashcardViewModel(getIt<StudentFlashcardRepository>()),
  ),

  // ✅ Gift Store ViewModel (MVVM Refactored)
  ChangeNotifierProvider<StudentGiftViewModel>(
    create: (_) => StudentGiftViewModel(getIt<StudentGiftRepository>()),
  ),

  // ✅ Quiz Module ViewModel (MVVM Refactored)
  ChangeNotifierProvider<StudentQuizViewModel>(
    create: (_) => StudentQuizViewModel(getIt<StudentQuizRepository>()),
  ),

  // Lesson Service (kept for ModuleExpansionItem widget)
  ChangeNotifierProvider<StudentLessonService>(
    create: (_) => StudentLessonService(getIt<StudentLessonRepository>()),
  ),
];
