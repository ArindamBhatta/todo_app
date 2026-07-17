import 'package:go_router/go_router.dart';
import 'package:todo/features/splash/presentation/page/splash_screen.dart';
import 'package:todo/features/onboarding/presentation/page/view.dart';
import 'package:todo/features/auth/presentation/pages/login_screen.dart';
import 'package:todo/features/home/presentation/page/view.dart';

abstract final class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const home = '/home';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnBoardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const AppNavigationPage(),
    ),
  ],
);
