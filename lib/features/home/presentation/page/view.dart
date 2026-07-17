import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo/features/home/presentation/page/home_screen.dart';
import 'package:todo/features/tasks/task_page.dart';

class AppNavigationPage extends ConsumerStatefulWidget {
  const AppNavigationPage({super.key});

  @override
  ConsumerState<AppNavigationPage> createState() => _AppNavigationPageState();
}

class _AppNavigationPageState extends ConsumerState<AppNavigationPage> {
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
          // Navigate to the AddTaskForm page
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
