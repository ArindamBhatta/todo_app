import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import 'package:todo/features/onboarding/presentation/page/widgets/scrollable_screen.dart';
import 'package:todo/features/onboarding/presentation/logic/onboarding_manager.dart';
import 'package:todo/features/auth/presentation/logic/auth_manager.dart';
import 'package:todo/features/auth/presentation/pages/login_screen.dart';

class OnBoardingScreen extends ConsumerStatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  ConsumerState<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends ConsumerState<OnBoardingScreen> {
  List<Map<String, String>> list = [
    {
      'caption': 'Explore the new to \n find good places',
      'subCaption':
          'Travel around the world with just a tap and enjoy your best holiday',
      'imageUrl': 'assets/images/onboarding_img_one.png',
    },
    {
      'caption': 'Adventure awaits \n ✈️ ',
      'subCaption':
          "Pack your bags, book your flight, and let's explore the world together",
      'imageUrl': 'assets/images/onboarding_img_two.png',
    },
    {
      'caption': 'Lost in the beauty of nature',
      'subCaption': "Let's explore the world, one destination at a time.",
      'imageUrl': 'assets/images/onboarding_img_three.png',
    },
    {
      'caption': 'Relax, Refresh, Recharge',
      'subCaption': "Find your perfect getaway and unwind in style.",
      'imageUrl': 'assets/images/onboarding_img_four.png',
    },
  ];

  late PageController _pageController;
  late Timer _timer;
  int currentPage = 0; //* Update the dot indicator
  int nextPage = 0; //* Update the page Image
  late int _actualListLength;

  @override
  void initState() {
    super.initState();
    _actualListLength = list.length;
    _pageController = PageController();

    //Listening Event of  scrolling
    _pageController.addListener(() {
      setState(() {
        currentPage = _pageController.page!.toInt(); //* Update the current page
      });
    });

    _timer = Timer.periodic(const Duration(seconds: 4), (timer) async {
      nextPage = currentPage + 1;

      //* Check if we reached the last page
      if (nextPage == list.length) {
        setState(() {
          list.add(list[0]); //* Temporarily add the first item at the end
        }); //* Update the UI with the new list

        //* Animate to the temporary page smoothly
        await _pageController.animateToPage(
          nextPage,
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut,
        );

        //* Reset to the actual first page without animation
        _pageController.jumpToPage(0);

        //* reset the page controller animation page
        nextPage = 0;

        //* Remove the temporary item
        list.removeLast();
      } else {
        //* Continue with normal page transition
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  int get dotsLength => _actualListLength;
  int get currentDot => _actualListLength == currentPage ? 0 : currentPage;

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: height * 0.75,
            child: Stack(
              children: [
                PageView(
                  controller: _pageController,
                  children:
                      list.map((iterateItem) {
                        return ScrollableScreen(
                          caption: iterateItem['caption'] ?? '',
                          subCaption: iterateItem['subCaption'] ?? '',
                          imageUrl: iterateItem['imageUrl'] ?? '',
                        );
                      }).toList(),
                ),
                Positioned(
                  bottom: height * 0.15,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: DotsIndicator(
                      dotsCount: dotsLength,
                      position: (currentDot).toDouble(),
                      //* Limit to original items
                      decorator: DotsDecorator(
                        shape: const CircleBorder(
                          side: BorderSide(color: Colors.teal, width: 0.8),
                        ),
                        color: Colors.white,
                        spacing: const EdgeInsets.all(8.0),
                        activeColor: Colors.white,
                        size: const Size(8.0, 8.0), // Size of inactive dots
                        activeSize: const Size(
                          40.0,
                          12.0,
                        ), // Size of active dot
                        activeShape: RoundedRectangleBorder(
                          side: const BorderSide(
                            color: Colors.black,
                            width: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4F46E5).withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    await ref
                        .read(onboardingProvider.notifier)
                        .completeOnboarding();
                    final isLoggedIn = ref.read(authProvider).value ?? false;
                    if (isLoggedIn) {
                      navigator.pushReplacement(
                        MaterialPageRoute(builder: (context) => Placeholder()),
                      );
                    } else {
                      navigator.pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5), // Indigo 600
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Text(
                        "Get Started",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
