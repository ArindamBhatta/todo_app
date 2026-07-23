import 'dart:math' as math;

import 'package:flutter/widgets.dart';

class ShakeWidget extends StatefulWidget {
  final Widget child;
  final bool shake;

  const ShakeWidget({required this.child, required this.shake, super.key});

  @override
  State<ShakeWidget> createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<ShakeWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    if (widget.shake) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant ShakeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shake != oldWidget.shake) {
      if (widget.shake) {
        _controller.repeat();
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
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
        if (!widget.shake) return child!;
        final double progress = _controller.value;
        final double offset = math.sin(progress * 4 * math.pi) * 1.5;
        final double rotation = math.sin(progress * 4 * math.pi) * 0.012;

        return Transform.translate(
          offset: Offset(offset, 0),
          child: Transform.rotate(angle: rotation, child: child),
        );
      },
      child: widget.child,
    );
  }
}
