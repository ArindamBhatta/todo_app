import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todo/task/task_page.dart';
import 'package:todo/features/home/presentation/page/home_screen.dart';
import 'package:todo/features/onboarding/presentation/logic/onboarding_manager.dart';
import 'package:todo/features/onboarding/presentation/page/onboarding_screen.dart';

main() {
  runApp(const ProviderScope(child: TodoApp()));
}

class TodoApp extends ConsumerWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final onboardingCompleted = ref.watch(onboardingProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Todo App",
      home: onboardingCompleted.when(
        data: (completed) => completed ? const OnBoardingPage() : const OnboardingScreen(),
        loading: () => const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
        error: (err, stack) => Scaffold(
          body: Center(
            child: Text('Error loading onboarding state: $err'),
          ),
        ),
      ),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5), // Indigo 600
          background: const Color(0xFFF8FAFC), // Slate 50
          primary: const Color(0xFF4F46E5),
          secondary: const Color(0xFF6366F1),
        ),
        textTheme: GoogleFonts.interTextTheme(textTheme),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({super.key});

  @override
  State<StatefulWidget> createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage>
    with SingleTickerProviderStateMixin {
  int currentPageIndex = 0;
  final List<String> pathOfIcons = ['assets/home.png', 'assets/add_todo.png'];

  final List<Widget> screens = [HomeScreen(), TaskPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: false,
      body: screens[currentPageIndex],
      bottomNavigationBar: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: CurvedNavigationBar(
          backgroundColor: Colors.transparent,
          color: const Color(0xFFEEF2F6), // Slate 100-ish
          buttonBackgroundColor: const Color(0xFF4F46E5), // Indigo 600
          height: 60,
          index: currentPageIndex,
          items: pathOfIcons.asMap().entries.map((entry) {
            final idx = entry.key;
            final iconPath = entry.value;
            final isActive = idx == currentPageIndex;
            return Padding(
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                iconPath,
                width: 20,
                height: 20,
                color: isActive ? Colors.white : const Color(0xFF475569),
              ),
            );
          }).toList(),
          onTap: (int index) {
            setState(() {
              currentPageIndex = index;
            });
          },
        ),
      ),
    );
  }
}
