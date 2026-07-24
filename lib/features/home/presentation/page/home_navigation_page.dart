import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:todo/core/router/app_router.dart';
import 'package:todo/features/Profile/profile.dart';
import 'package:todo/features/home/presentation/page/home_screen.dart';
import 'package:todo/features/pomodoro/pomodoro.dart';
import 'package:todo/features/tasks/tasks_page.dart';

class HomeNavigationPage extends StatefulWidget {
  final int initialIndex;

  const HomeNavigationPage({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<HomeNavigationPage> createState() => _HomeNavigationPageState();
}

class _HomeNavigationPageState extends State<HomeNavigationPage> {
  late int _currentIndex;

  static const List<Widget> _screens = [
    HomeScreen(),
    TasksPage(),
    Pomodoro(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  Widget _buildTabItem({
    required int index,
    required Widget icon,
  }) {
    final bool isActive = _currentIndex == index;

    return InkWell(
      onTap: () {
        if (_currentIndex != index) {
          setState(() {
            _currentIndex = index;
          });
        }
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: IconTheme(
          data: IconThemeData(
            size: 28,
            color: isActive
                ? const Color(0xFF6B4EFF) // Active purple
                : const Color(0xFFB4AEE8), // Inactive light purple
          ),
          child: icon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6B4EFF).withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: BottomAppBar(
            color: const Color(0xFFF2EFFF),
            elevation: 0,
            height: 80,
            padding: EdgeInsets.zero,
            shape: const CircularNotchedRectangle(),
            notchMargin: 12.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Tab 0: Home
                _buildTabItem(
                  index: 0,
                  icon: const FaIcon(FontAwesomeIcons.house),
                ),
                // Tab 1: Tasks
                _buildTabItem(
                  index: 1,
                  icon: const FaIcon(FontAwesomeIcons.calendar),
                ),
                // Center space for FAB
                const SizedBox(width: 48),
                // Tab 2: Pomodoro
                _buildTabItem(
                  index: 2,
                  icon: const FaIcon(FontAwesomeIcons.clock),
                ),
                // Tab 3: Profile
                _buildTabItem(
                  index: 3,
                  icon: const FaIcon(FontAwesomeIcons.user),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Container(
        height: 64,
        width: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6B4EFF).withValues(alpha: 0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            context.push(AppRoutes.addTodo);
          },
          backgroundColor: const Color(0xFF6B4EFF),
          elevation: 0,
          shape: const CircleBorder(),
          child: const Icon(Icons.add_rounded, size: 36, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
