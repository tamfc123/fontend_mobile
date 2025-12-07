import 'package:go_router/go_router.dart';
import 'package:mobile/screens/auth/forgotpassword/forgotpassword_screen.dart';
import 'package:mobile/screens/auth/resetpassword/resetpassword_screen.dart';
import 'package:mobile/screens/auth/signup/signup_screen.dart';
import 'package:mobile/screens/auth/splash/splash_screen.dart';
import 'package:mobile/screens/auth/login/login_screen.dart';
import 'package:mobile/screens/auth/loginweb/web_login_screen.dart';

/// Authentication routes configuration
class AuthRoutes {
  static List<RouteBase> routes = [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/login/web',
      builder: (context, state) => const WebLoginScreen(),
    ),
    GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
    GoRoute(
      path: '/forgotpassword',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/resetpassword',
      builder: (context, state) => const ResetpasswordScreen(),
    ),
  ];
}
