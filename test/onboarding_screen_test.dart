import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/features/onboarding/presentation/page/onboarding_screen.dart';
import 'package:todo/features/onboarding/presentation/logic/onboarding_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OnboardingScreen Widget Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('renders all UI components correctly', (WidgetTester tester) async {
      // Build the onboarding screen inside a ProviderScope and MaterialApp
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: OnboardingScreen(),
          ),
        ),
      );

      // Verify page titles and text elements
      expect(find.text('Task Management & \nTo-Do List'), findsOneWidget);
      expect(
        find.text(
          'This productive tool is designed to help\nyou better manage your task\nproject-wise conveniently!',
        ),
        findsOneWidget,
      );

      // Verify Let's Start button is rendered
      expect(find.text("Let's Start"), findsOneWidget);
    });

    testWidgets('clicking Let\'s Start button triggers completion', (WidgetTester tester) async {
      // Prepare container to track provider state
      final container = ProviderContainer();
      
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: OnboardingScreen(),
          ),
        ),
      );

      // Verify initial state of onboarding is false
      expect(await container.read(onboardingProvider.future), isFalse);

      // Tap the Let's Start button
      await tester.tap(find.text("Let's Start"));
      await tester.pump(const Duration(milliseconds: 300));

      // Verify state was updated to true
      expect(await container.read(onboardingProvider.future), isTrue);
    });
  });
}
