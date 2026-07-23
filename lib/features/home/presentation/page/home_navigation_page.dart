import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:todo/core/router/app_router.dart';
import 'package:todo/features/home/presentation/page/home_screen.dart';
import 'package:todo/features/pomodoro/pomodoro.dart';
import 'package:todo/features/tasks/tasks_page.dart';
import 'package:todo/features/Profile/profile.dart';

enum HomeTab { home, tasks, pomodoro, profile }

extension HomeTabExtends on HomeTab {
  String get queryValue => switch (this) {
    HomeTab.home => 'home',
    HomeTab.tasks => 'tasks',
    HomeTab.pomodoro => 'pomodoro',
    HomeTab.profile => 'profile',
  };

  static HomeTab fromQueryValue(String? value) {
    return switch (value) {
      'tasks' => HomeTab.tasks,
      'pomodoro' => HomeTab.pomodoro,
      'profile' => HomeTab.profile,
      _ => HomeTab.home,
    };
  }
}

class HomeNavigationPage extends StatelessWidget {
  final HomeTab tab;
  const HomeNavigationPage({super.key, required this.tab});

  static const List<Widget> screens = [
    HomeScreen(),
    TasksPage(),
    Pomodoro(),
    Profile(),
  ];

  Widget _buildTabItem({
    required BuildContext context,
    required int index,
    required HomeTab targetTab,
    required Widget icon,
    required bool isActive,
  }) {
    return InkWell(
      onTap: () {
        context.go(AppRoutes.homeWithTab(targetTab));
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: IconTheme(
          data: IconThemeData(
            size: 28,
            color:
                isActive
                    ? const Color(0xFF6B4EFF) // Vibrant purple for active state
                    : const Color(
                      0xFFB4AEE8,
                    ), // Muted light purple for inactive state
          ),
          child: icon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int currentPageIndex = tab.index;

    return Scaffold(
      extendBody: true,
      body: screens[currentPageIndex],
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
            color: const Color(
              0xFFF2EFFF,
            ), // Soft lavender background matching the image
            elevation: 0,
            height: 80,
            padding: EdgeInsets.zero,
            shape: const CircularNotchedRectangle(),
            // Creates a comfortable gap around the floating button
            notchMargin: 12.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Tab 0: Home
                _buildTabItem(
                  context: context,
                  index: 0,
                  targetTab: HomeTab.home,
                  icon: FaIcon(FontAwesomeIcons.house),
                  isActive: currentPageIndex == 0,
                ),
                // Tab 1: Tasks (Calendar)
                _buildTabItem(
                  context: context,
                  index: 1,
                  targetTab: HomeTab.tasks,
                  icon: FaIcon(FontAwesomeIcons.calendar),
                  isActive: currentPageIndex == 1,
                ),
                // Empty space for the floating action button
                const SizedBox(width: 48),

                // Tab 2: Pomodoro (Document/Reports)
                _buildTabItem(
                  context: context,
                  index: 2,
                  targetTab: HomeTab.pomodoro,
                  icon: FaIcon(FontAwesomeIcons.clock),
                  isActive: currentPageIndex == 2,
                ),
                // Tab 3: Profile (Person)
                _buildTabItem(
                  context: context,
                  index: 3,
                  targetTab: HomeTab.profile,
                  icon: FaIcon(FontAwesomeIcons.user),
                  isActive: currentPageIndex == 3,
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
          elevation:
              0, // Set to 0 because the Container handles the custom glowing shadow
          shape: const CircleBorder(),
          child: const Icon(Icons.add_rounded, size: 36, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
