import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/core/router/app_router.dart';
import 'package:todo/core/cubit/connectivity_manager.dart';
import 'package:todo/core/theme/theme_bloc.dart';
import 'package:todo/data/todo_repository.dart';
import 'package:todo/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:todo/features/auth/data/repositories/auth_repository.dart';
import 'package:todo/features/auth/presentation/logic/auth_manager.dart';
import 'package:todo/features/home/presentation/logic/todo_manager.dart';
import 'package:todo/features/onboarding/data/datasources/onboarding_local_datasource.dart';
import 'package:todo/features/onboarding/data/repositories/onboarding_repository.dart';
import 'package:todo/features/onboarding/presentation/logic/onboarding_manager.dart';
import 'package:todo/features/splash/presentation/logic/splash_manager.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepository = AuthRepository(AuthLocalDataSource());
    final onboardingRepository = OnboardingRepository(
      OnboardingLocalDataSource(),
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ThemeBloc(initialThemeMode: ThemeMode.light),
        ),
        BlocProvider(
          create:
              (_) => SplashManager(
                onboardingRepository: onboardingRepository,
                authRepository: authRepository,
              ),
        ),
        BlocProvider(create: (_) => AuthManager(authRepository)),
        BlocProvider(create: (_) => OnboardingManager(onboardingRepository)),
        BlocProvider(create: (_) => TaskManager(TodoRepository())),
        BlocProvider(create: (_) => ConnectivityManager()..startMonitoring()),
      ],
      child: BlocListener<ConnectivityManager, ConnectivityStatus>(
        listenWhen: (previous, current) => previous != current,
        listener: (context, status) {
          if (status == ConnectivityStatus.unknown) {
            return;
          }

          final ScaffoldMessengerState? messenger =
              rootScaffoldMessengerKey.currentState;

          messenger
            ?..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  status == ConnectivityStatus.offline
                      ? 'No internet connection.'
                      : 'Internet connection restored.',
                ),
                duration: const Duration(seconds: 2),
              ),
            );
        },
        child: BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, themeState) {
            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              title: 'Todo App',
              theme: themeState.themeData,
              routerConfig: appRouter,
              scaffoldMessengerKey: rootScaffoldMessengerKey,
            );
          },
        ),
      ),
    );
  }
}
