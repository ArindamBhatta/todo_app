import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/features/onboarding/data/repositories/onboarding_repository.dart';

part 'splash_state.dart';

class SplashManager extends Cubit<SplashState> {
  final OnboardingRepository _onboardingRepository;

  SplashManager({required OnboardingRepository onboardingRepository})
    : _onboardingRepository = onboardingRepository,
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
    ];

    if (includeSplashDelay) {
      tasks.insert(0, Future.delayed(const Duration(milliseconds: 2500)));
    }

    final List<dynamic> results = await Future.wait<dynamic>(tasks);

    final int onboardingIndex = includeSplashDelay ? 1 : 0;
    final bool onboardingCompleted = results[onboardingIndex] as bool;

    if (!onboardingCompleted) {
      emit(SplashNavigateToOnboarding());
    } else {
      emit(SplashNavigateToLogin());
    }
  }
}
