import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo/task/task_page.dart';
import 'home/home_screen.dart';

main() {
  runApp(const ProviderScope(child: TodoApp()));
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Todo App",
      home: OnBoardingPage(),
      theme: ThemeData(primarySwatch: Colors.blue),
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
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: CurvedNavigationBar(
          backgroundColor: Colors.transparent,
          color: Colors.tealAccent,
          buttonBackgroundColor: Colors.teal,
          height: 60,
          index: currentPageIndex,
          items:
              pathOfIcons.map((iconPath) {
                return Padding(
                  padding: EdgeInsets.all(8),
                  child: Image.asset(
                    iconPath,
                    width: 20,
                    height: 20,
                    color: Colors.white,
                  ),
                );
              }).toList(),
          //
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
