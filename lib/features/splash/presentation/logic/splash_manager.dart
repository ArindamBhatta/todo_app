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
  })  : _onboardingRepository = onboardingRepository,
        _authRepository = authRepository,
        super(SplashLoading());

  Future<void> initialize() async {
    // Keep splash visible for at least 2.5 seconds
    final results = await Future.wait([
      Future.delayed(const Duration(milliseconds: 2500)),
      _onboardingRepository.isOnboardingCompleted(),
      _authRepository.isLoggedIn(),
    ]);

    final bool onboardingCompleted = results[1] as bool;
    final bool isLoggedIn = results[2] as bool;

    if (!onboardingCompleted) {
      emit(SplashNavigateToOnboarding());
    } else if (!isLoggedIn) {
      emit(SplashNavigateToLogin());
    } else {
      emit(SplashNavigateToHome());
    }
  }
}
