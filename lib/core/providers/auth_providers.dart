import 'package:mobile/domain/repositories/auth_repository.dart';
import 'package:provider/provider.dart';
import 'package:mobile/services/auth/auth_service.dart';
import 'package:mobile/core/di/service_locator.dart';

final authProviders = [
  ChangeNotifierProvider<AuthService>(
    create: (_) => AuthService(getIt<AuthRepository>()),
  ),
];
