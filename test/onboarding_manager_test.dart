import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/features/onboarding/presentation/logic/onboarding_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OnboardingManager Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('initial state is false (onboarding not completed)', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Verify that the initial build retrieves false
      final stateFuture = container.read(onboardingProvider.future);
      expect(await stateFuture, isFalse);
    });

    test('completing onboarding updates state to true', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Verify initial state
      expect(await container.read(onboardingProvider.future), isFalse);

      // Complete onboarding
      await container.read(onboardingProvider.notifier).completeOnboarding();

      // Verify updated state
      expect(await container.read(onboardingProvider.future), isTrue);
    });
  });
}
