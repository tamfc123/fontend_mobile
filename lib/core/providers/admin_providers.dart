import 'package:provider/provider.dart';
import 'package:mobile/core/di/service_locator.dart';

// Repositories
import 'package:mobile/domain/repositories/admin/admin_dashboard_repository.dart';
import 'package:mobile/domain/repositories/admin/admin_user_repository.dart';
import 'package:mobile/domain/repositories/admin/admin_course_repository.dart';
import 'package:mobile/domain/repositories/admin/admin_class_repository.dart';
import 'package:mobile/domain/repositories/admin/admin_room_repository.dart';
import 'package:mobile/domain/repositories/admin/admin_schedule_repository.dart';
import 'package:mobile/domain/repositories/admin/admin_module_repository.dart';
import 'package:mobile/domain/repositories/admin/admin_lesson_repository.dart';
import 'package:mobile/domain/repositories/admin/admin_vocabulary_repository.dart';
import 'package:mobile/domain/repositories/admin/admin_quiz_repository.dart';
import 'package:mobile/domain/repositories/admin/admin_media_repository.dart';
import 'package:mobile/domain/repositories/admin/admin_gift_repository.dart';
import 'package:mobile/domain/repositories/admin/admin_gift_redemption_repository.dart';
import 'package:mobile/domain/repositories/admin/admin_redemption_repository.dart';

// ViewModels
import 'package:mobile/screens/admin/dashboard/admin_dashboard_view_model.dart';
import 'package:mobile/screens/admin/manage_account/manage_account_view_model.dart';
import 'package:mobile/screens/admin/manage_class/manage_class_view_model.dart';
import 'package:mobile/screens/admin/manage_course/manage_course_view_model.dart';
import 'package:mobile/screens/admin/manage_gift/manage_gift_view_model.dart';
import 'package:mobile/screens/admin/gift_redemption/gift_redemption_view_model.dart';
import 'package:mobile/screens/admin/gift_redemption/user_redemption_view_model.dart';
import 'package:mobile/screens/admin/manage_lesson/manage_lesson_view_model.dart';
import 'package:mobile/screens/admin/manage_media/manage_media_view_model.dart';
import 'package:mobile/screens/admin/manage_module/manage_module_view_model.dart';
import 'package:mobile/screens/admin/manage_quiz/manage_quiz_view_model.dart';
import 'package:mobile/screens/admin/manage_quiz/quiz_detail_view_model.dart';
import 'package:mobile/screens/admin/manage_room/manage_room_view_model.dart';
import 'package:mobile/screens/admin/manage_schedule/manage_schedule_view_model.dart';
import 'package:mobile/screens/admin/manage_schedule/bulk_schedule_view_model.dart';
import 'package:mobile/screens/admin/manage_vocabulary/manage_vocabulary_view_model.dart';

final adminProviders = [
  // Repositories (needed by screens)
  Provider<AdminUserRepository>(create: (_) => getIt<AdminUserRepository>()),

  // Dashboard
  ChangeNotifierProvider<AdminDashboardViewModel>(
    create: (_) => AdminDashboardViewModel(getIt<AdminDashboardRepository>()),
  ),

  // Account
  ChangeNotifierProvider<ManageAccountViewModel>(
    create: (_) => ManageAccountViewModel(getIt<AdminUserRepository>()),
  ),

  // Course & Class
  ChangeNotifierProvider<ManageCourseViewModel>(
    create: (_) => ManageCourseViewModel(getIt<AdminCourseRepository>()),
  ),
  ChangeNotifierProvider<ManageClassViewModel>(
    create:
        (_) => ManageClassViewModel(
          getIt<AdminClassRepository>(),
          getIt<AdminUserRepository>(),
          getIt<AdminCourseRepository>(),
        ),
  ),

  // Module & Lesson & Vocabulary
  ChangeNotifierProvider<ManageModuleViewModel>(
    create: (_) => ManageModuleViewModel(getIt<AdminModuleRepository>()),
  ),
  ChangeNotifierProvider<ManageLessonViewModel>(
    create: (_) => ManageLessonViewModel(getIt<AdminLessonRepository>()),
  ),
  ChangeNotifierProvider<ManageVocabularyViewModel>(
    create:
        (_) => ManageVocabularyViewModel(getIt<AdminVocabularyRepository>()),
  ),

  // Quiz
  ChangeNotifierProvider<ManageQuizViewModel>(
    create: (_) => ManageQuizViewModel(getIt<AdminQuizRepository>()),
  ),
  ChangeNotifierProvider<QuizDetailViewModel>(
    create: (_) => QuizDetailViewModel(getIt<AdminQuizRepository>()),
  ),

  // Room & Schedule
  ChangeNotifierProvider<ManageRoomViewModel>(
    create: (_) => ManageRoomViewModel(getIt<AdminRoomRepository>()),
  ),
  ChangeNotifierProvider<ManageScheduleViewModel>(
    create:
        (_) => ManageScheduleViewModel(
          getIt<AdminScheduleRepository>(),
          getIt<AdminRoomRepository>(),
          getIt<AdminClassRepository>(),
        ),
  ),
  ChangeNotifierProvider<BulkScheduleViewModel>(
    create:
        (_) => BulkScheduleViewModel(
          getIt<AdminScheduleRepository>(),
          getIt<AdminClassRepository>(),
          getIt<AdminRoomRepository>(),
        ),
  ),

  // Media & Gift
  ChangeNotifierProvider<ManageMediaViewModel>(
    create: (_) => ManageMediaViewModel(getIt<AdminMediaRepository>()),
  ),
  ChangeNotifierProvider<ManageGiftViewModel>(
    create: (_) => ManageGiftViewModel(getIt<AdminGiftRepository>()),
  ),
  ChangeNotifierProvider<GiftRedemptionViewModel>(
    create:
        (_) => GiftRedemptionViewModel(
          getIt<AdminUserRepository>(),
          getIt<AdminGiftRedemptionRepository>(),
        ),
  ),
  ChangeNotifierProvider<UserRedemptionViewModel>(
    create: (_) => UserRedemptionViewModel(getIt<AdminRedemptionRepository>()),
  ),
];
