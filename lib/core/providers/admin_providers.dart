import 'package:mobile/core/di/service_locator.dart';
import 'package:mobile/domain/repositories/admin_class_repository.dart';
import 'package:mobile/domain/repositories/admin_course_repository.dart';
import 'package:mobile/domain/repositories/admin_dashboard_repository.dart';
import 'package:mobile/domain/repositories/admin_gift_repository.dart';
import 'package:mobile/domain/repositories/admin_lesson_repository.dart';
import 'package:mobile/domain/repositories/admin_media_repository.dart'
    show AdminMediaRepository;
import 'package:mobile/domain/repositories/admin_module_repository.dart';
import 'package:mobile/domain/repositories/admin_quiz_repository.dart';
import 'package:mobile/domain/repositories/admin_redemption_repository.dart';
import 'package:mobile/domain/repositories/admin_room_repository.dart';
import 'package:mobile/domain/repositories/admin_schedule_repository.dart';
import 'package:mobile/domain/repositories/admin_user_repository.dart';
import 'package:mobile/domain/repositories/admin_vocabulary_repository.dart';
import 'package:mobile/services/admin/admin_class_service.dart';
import 'package:mobile/services/admin/admin_course_service.dart';
import 'package:mobile/services/admin/admin_dashboard_service.dart';
import 'package:mobile/services/admin/admin_gift_service.dart';
import 'package:mobile/services/admin/admin_lesson_service.dart';
import 'package:mobile/services/admin/admin_media_service.dart';
import 'package:mobile/services/admin/admin_module_service.dart';
import 'package:mobile/services/admin/admin_quiz_service.dart';
import 'package:mobile/services/admin/admin_redemption_service.dart';
import 'package:mobile/services/admin/admin_room_service.dart';
import 'package:mobile/services/admin/admin_schedule_service.dart';
import 'package:mobile/services/admin/admin_user_service.dart';
import 'package:mobile/services/admin/admin_vocabulary_service.dart';
import 'package:provider/provider.dart';

final adminProviders = [
  // User Service
  ChangeNotifierProvider<AdminUserService>(
    create: (_) => AdminUserService(getIt<AdminUserRepository>()),
  ),

  // Course Service
  ChangeNotifierProvider<AdminCourseService>(
    create: (_) => AdminCourseService(getIt<AdminCourseRepository>()),
  ),

  // Module Service
  ChangeNotifierProvider<AdminModuleService>(
    create: (_) => AdminModuleService(getIt<AdminModuleRepository>()),
  ),

  // Class Service
  ChangeNotifierProvider<AdminClassService>(
    create: (_) => AdminClassService(getIt<AdminClassRepository>()),
  ),

  // Room Service
  ChangeNotifierProvider<AdminRoomService>(
    create: (_) => AdminRoomService(getIt<AdminRoomRepository>()),
  ),

  // Schedule Service
  ChangeNotifierProvider<AdminScheduleService>(
    create: (_) => AdminScheduleService(getIt<AdminScheduleRepository>()),
  ),

  // Lesson Service
  ChangeNotifierProvider<AdminLessonService>(
    create: (_) => AdminLessonService(getIt<AdminLessonRepository>()),
  ),

  // Vocabulary Service
  ChangeNotifierProvider<AdminVocabularyService>(
    create: (_) => AdminVocabularyService(getIt<AdminVocabularyRepository>()),
  ),

  // Quiz Service
  ChangeNotifierProvider<AdminQuizService>(
    create: (_) => AdminQuizService(getIt<AdminQuizRepository>()),
  ),

  // Media Service
  ChangeNotifierProvider<AdminMediaService>(
    create: (_) => AdminMediaService(getIt<AdminMediaRepository>()),
  ),

  // Gift Service
  ChangeNotifierProvider<AdminGiftService>(
    create: (_) => AdminGiftService(getIt<AdminGiftRepository>()),
  ),

  // Redemption Service
  ChangeNotifierProvider<AdminRedemptionService>(
    create: (_) => AdminRedemptionService(getIt<AdminRedemptionRepository>()),
  ),

  // Dashboard Service (Đã fix)
  ChangeNotifierProvider<AdminDashboardService>(
    create: (_) => AdminDashboardService(getIt<AdminDashboardRepository>()),
  ),
];
