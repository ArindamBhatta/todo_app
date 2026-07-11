import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/features/onboarding/presentation/page/view.dart';
import 'package:todo/features/onboarding/presentation/logic/onboarding_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OnBoardingScreen Widget Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('renders all UI components correctly', (WidgetTester tester) async {
      // Build the onboarding screen inside a ProviderScope and MaterialApp
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: OnBoardingScreen(),
          ),
        ),
      );

      // Verify page captions and text elements
      expect(find.text('Explore the new to \n find good places'), findsOneWidget);
      expect(
        find.text(
          'Travel around the world with just a tap and enjoy your best holiday',
        ),
        findsOneWidget,
      );

      // Verify Get Started button is rendered
      expect(find.text("Get Started"), findsOneWidget);
    });

    testWidgets('clicking Get Started button triggers completion', (WidgetTester tester) async {
      // Prepare container to track provider state
      final container = ProviderContainer();
      
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: OnBoardingScreen(),
          ),
        ),
      );

      // Tap the Get Started button
      await tester.tap(find.text("Get Started"));
      await tester.pump(const Duration(milliseconds: 300));

      // Verify state was updated to true
      expect(await container.read(onboardingProvider.future), isTrue);
    });
  });
}
