import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/features/auth/data/repositories/auth_repository.dart';
import 'package:todo/features/onboarding/data/repositories/onboarding_repository.dart';

part 'splash_state.dart';

class SplashManager extends Cubit<SplashState> {
  final OnboardingRepository _onboardingRepository;

  final AuthRepository _authRepository;

  SplashManager({
    required OnboardingRepository onboardingRepository,
    required AuthRepository authRepository,
  }) : _onboardingRepository = onboardingRepository,
       _authRepository = authRepository,
       super(SplashLoading());

  Future<void> initialize() async {
    await _resolveNavigationState(includeSplashDelay: true);
  }

  Future<void> refreshRoutingState() async {
    await _resolveNavigationState(includeSplashDelay: false);
  }

  Future<void> _resolveNavigationState({
    required bool includeSplashDelay,
  }) async {
    // Keep splash visible for at least 2.5 seconds
    final List<Future<dynamic>> tasks = <Future<dynamic>>[
      _onboardingRepository.isOnboardingCompleted(),
      _authRepository.isLoggedIn(),
    ];

    if (includeSplashDelay) {
      tasks.insert(0, Future.delayed(const Duration(milliseconds: 2500)));
    }

    final List<dynamic> results = await Future.wait<dynamic>(tasks);

    final int onboardingIndex = includeSplashDelay ? 1 : 0;

    // final int loginIndex = includeSplashDelay ? 2 : 1;

    final bool onboardingCompleted = results[onboardingIndex] as bool;
    // final bool isLoggedIn = results[loginIndex] as bool;

    if (!onboardingCompleted) {
      emit(SplashNavigateToOnboarding());
    }
    // Todo: User already authenticated directly ask for biometric if biometric fail then password if wrong password kick out from app.
    //  else if (!isLoggedIn) {
    //   emit(SplashNavigateToLogin());
    // }
    else {
      emit(SplashNavigateToLogin());
    }
  }
}
