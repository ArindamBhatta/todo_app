import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todo/task/task_page.dart';
import 'package:todo/features/home/presentation/page/home_screen.dart';
import 'package:todo/features/splash/presentation/page/splash_screen.dart';
import 'package:todo/features/home/presentation/page/add_task_form.dart';
import 'package:todo/features/home/presentation/logic/todo_manager.dart';

main() {
  runApp(const ProviderScope(child: TodoApp()));
}

class TodoApp extends ConsumerWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Todo App",
      home: const SplashScreen(),
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

class OnBoardingPage extends ConsumerStatefulWidget {
  const OnBoardingPage({super.key});

  @override
  ConsumerState<OnBoardingPage> createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends ConsumerState<OnBoardingPage> {
  int currentPageIndex = 0;

  final List<Widget> screens = [
    const HomeScreen(),
    const TaskPage(),
    const Scaffold(
      body: Center(
        child: Text(
          'Documents Screen\n(Coming soon!)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
        ),
      ),
    ),
    const Scaffold(
      body: Center(
        child: Text(
          'Teams Screen\n(Coming soon!)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
        ),
      ),
    ),
  ];

  Widget _buildTabItem({
    required int index,
    required IconData icon,
    required bool isActive,
  }) {
    return InkWell(
      onTap: () {
        setState(() {
          currentPageIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Icon(
          icon,
          size: 26,
          color: isActive ? const Color(0xFF5E42EB) : const Color(0xFF94A3B8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentPageIndex],
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFFEEF2FB), // Soft lavender/light-purple background
        elevation: 8,
        height: 70,
        padding: EdgeInsets.zero,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Tab 0: Home
            _buildTabItem(
              index: 0,
              icon: Icons.home_rounded,
              isActive: currentPageIndex == 0,
            ),
            // Tab 1: TaskPage (Calendar / List)
            _buildTabItem(
              index: 1,
              icon: Icons.calendar_month_rounded,
              isActive: currentPageIndex == 1,
            ),
            const SizedBox(width: 48), // Space for floating button
            // Tab 2: Reports Placeholder
            _buildTabItem(
              index: 2,
              icon: Icons.description_rounded,
              isActive: currentPageIndex == 2,
            ),
            // Tab 3: Group/Profile Placeholder
            _buildTabItem(
              index: 3,
              icon: Icons.people_alt_rounded,
              isActive: currentPageIndex == 3,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTaskForm(
                onAdd: (newTask) async {
                  await ref.read(taskListProvider.notifier).addTask(newTask);
                },
              ),
            ),
          );
        },
        backgroundColor: const Color(0xFF5E42EB),
        shape: const CircleBorder(),
        elevation: 4,
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
