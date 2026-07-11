import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../logic/onboarding_manager.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Slate 50
      body: Stack(
        children: [
          // Background Blobs (Soft gradients)
          Positioned(
            top: -50,
            left: -50,
            child: _GlowBlob(
              size: 260,
              color: const Color(0xFF86EFAC), // Soft light green
            ),
          ),
          Positioned(
            top: 50,
            right: -60,
            child: _GlowBlob(
              size: 280,
              color: const Color(0xFFDDD6FE), // Soft light violet/purple
            ),
          ),
          Positioned(
            bottom: 120,
            left: -80,
            child: _GlowBlob(
              size: 320,
              color: const Color(0xFFBFDBFE), // Soft light blue
            ),
          ),
          Positioned(
            bottom: -40,
            right: -40,
            child: _GlowBlob(
              size: 240,
              color: const Color(0xFFFEF08A), // Soft light yellow
            ),
          ),

          // Corner circles (Stylized mockup border design)
          Positioned(
            top: 36,
            left: 24,
            child: _CornerRing(),
          ),
          Positioned(
            top: 36,
            right: 24,
            child: _CornerRing(),
          ),
          Positioned(
            bottom: 36,
            left: 24,
            child: _CornerRing(),
          ),
          Positioned(
            bottom: 36,
            right: 24,
            child: _CornerRing(),
          ),

          // Foreground Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // 3D Illustration with floating animation
                  Flexible(
                    flex: 8,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: size.height * 0.45,
                      ),
                      child: const _FloatingWidget(
                        child: Center(
                          child: Image(
                            image: AssetImage('assets/splash_illustration.png'),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 1),

                  // Title text
                  const Text(
                    'Task Management & \nTo-Do List',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A), // Slate 900
                      height: 1.3,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Subtitle/Description text
                  const Text(
                    'This productive tool is designed to help\nyou better manage your task\nproject-wise conveniently!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B), // Slate 500
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Let's Start button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF5B3DE2).withOpacity(0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          ref.read(onboardingProvider.notifier).completeOnboarding();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5B3DE2), // Purple color
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Text(
                              "Let's Start",
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
                                  color: Colors.white.withOpacity(0.2),
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
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Background soft glow blob widget
class _GlowBlob extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowBlob({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withOpacity(0.35),
            color.withOpacity(0.12),
            color.withOpacity(0),
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
    );
  }
}

// Corner ring widget
class _CornerRing extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF60A5FA).withOpacity(0.6), // Light blue border
          width: 1.5,
        ),
      ),
    );
  }
}

// Floating micro-animation widget
class _FloatingWidget extends StatefulWidget {
  final Widget child;
  const _FloatingWidget({required this.child});

  @override
  State<_FloatingWidget> createState() => _FloatingWidgetState();
}

class _FloatingWidgetState extends State<_FloatingWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 8 * _controller.value - 4),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
