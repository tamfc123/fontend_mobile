import 'package:mobile/core/di/service_locator.dart';
import 'package:mobile/core/providers/auth_providers.dart';
import 'package:mobile/domain/repositories/common/upload_repository.dart';
import 'package:provider/provider.dart';
import 'admin_providers.dart';
import 'teacher_providers.dart';
import 'student_providers.dart';

final appProviders = [
  Provider<UploadRepository>(create: (_) => getIt<UploadRepository>()),
  ...authProviders,
  ...adminProviders,
  ...teacherProviders,
  ...studentProviders,
];
