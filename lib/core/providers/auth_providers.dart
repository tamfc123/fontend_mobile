import 'package:mobile/domain/repositories/auth/auth_repository.dart';
import 'package:mobile/screens/auth/splash/splash_view_model.dart';
import 'package:provider/provider.dart';
import 'package:mobile/services/auth/auth_service.dart';
import 'package:mobile/core/di/service_locator.dart';

final authProviders = [
  ChangeNotifierProvider<AuthService>(
    create: (_) => AuthService(getIt<AuthRepository>())..tryAutoLogin(),
  ),
  ChangeNotifierProxyProvider<AuthService, SplashViewModel>(
    create:
        (context) =>
            SplashViewModel(Provider.of<AuthService>(context, listen: false)),
    update:
        (context, authService, previous) =>
            previous ?? SplashViewModel(authService),
  ),
];
