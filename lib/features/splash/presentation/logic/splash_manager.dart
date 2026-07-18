import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/features/auth/data/repositories/auth_repository.dart';
import 'package:todo/features/auth/presentation/logic/biometric_auth_service.dart';
import 'package:todo/features/onboarding/data/repositories/onboarding_repository.dart';

part 'splash_state.dart';

class SplashManager extends Cubit<SplashState> {
  final OnboardingRepository _onboardingRepository;
  final AuthRepository _authRepository;
  final BiometricAuthService _biometricAuthService;

  SplashManager({
    required OnboardingRepository onboardingRepository,
    required AuthRepository authRepository,
    BiometricAuthService? biometricAuthService,
  }) : _onboardingRepository = onboardingRepository,
       _authRepository = authRepository,
       _biometricAuthService = biometricAuthService ?? BiometricAuthService(),
       super(SplashLoading());

  Future<void> initialize() async {
    // Keep splash visible for at least 2.5 seconds
    final List<dynamic> results = await Future.wait([
      Future.delayed(const Duration(milliseconds: 2500)),
      _onboardingRepository.isOnboardingCompleted(),
      _authRepository.isLoggedIn(),
      _authRepository.isBiometricEnabled(),
    ]);

    final bool onboardingCompleted = results[1] as bool;
    final bool isLoggedIn = results[2] as bool;
    final bool isBiometricEnabled = results[3] as bool;

    if (!onboardingCompleted) {
      emit(SplashNavigateToOnboarding());
    } else if (!isLoggedIn) {
      emit(SplashNavigateToLogin());
    } else if (!isBiometricEnabled) {
      // Biometric enrollment is mandatory for signed-in sessions.
      emit(SplashNavigateToLogin());
    } else {
      final bool authenticated = await _biometricAuthService.authenticate();
      if (authenticated) {
        emit(SplashNavigateToHome());
      } else {
        emit(SplashNavigateToLogin());
      }
    }
  }
}
