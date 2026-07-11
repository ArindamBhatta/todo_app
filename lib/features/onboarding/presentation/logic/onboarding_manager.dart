import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/onboarding_repository.dart';

class OnboardingManager extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final repository = ref.watch(onboardingRepositoryProvider);
    return repository.isOnboardingCompleted();
  }

  Future<void> completeOnboarding() async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(onboardingRepositoryProvider);
      await repository.setOnboardingCompleted(true);
      state = const AsyncData(true);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final onboardingProvider = AsyncNotifierProvider<OnboardingManager, bool>(() {
  return OnboardingManager();
});
