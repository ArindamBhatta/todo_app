import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo/features/onboarding/presentation/logic/onboarding_manager.dart';
import 'package:todo/features/onboarding/data/repositories/onboarding_repository.dart';
import 'package:todo/features/onboarding/data/datasources/onboarding_local_datasource.dart';

class MockOnboardingLocalDataSource implements OnboardingLocalDataSource {
  bool _completed = false;

  @override
  Future<bool> isOnboardingCompleted() async {
    return _completed;
  }

  @override
  Future<void> setOnboardingCompleted(bool completed) async {
    _completed = completed;
  }
}

void main() {
  group('OnboardingManager Tests', () {
    late MockOnboardingLocalDataSource mockDataSource;
    late ProviderContainer container;

    setUp(() {
      mockDataSource = MockOnboardingLocalDataSource();
      container = ProviderContainer(
        overrides: [
          onboardingLocalDataSourceProvider.overrideWithValue(mockDataSource),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is false (onboarding not completed)', () async {
      // Verify that the initial build retrieves false
      final stateFuture = container.read(onboardingProvider.future);
      expect(await stateFuture, isFalse);
    });

    test('completing onboarding updates state to true', () async {
      // Verify initial state
      expect(await container.read(onboardingProvider.future), isFalse);

      // Complete onboarding
      await container.read(onboardingProvider.notifier).completeOnboarding();

      // Verify updated state
      expect(await container.read(onboardingProvider.future), isTrue);
    });
  });
}
