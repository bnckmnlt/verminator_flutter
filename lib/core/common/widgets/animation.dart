import 'package:flutter/material.dart';

class BounceWithFadeAnimation extends StatefulWidget {
  const BounceWithFadeAnimation({
    super.key,
    required this.child,
    required this.delay,
  });

  final Widget child;
  final double delay;

  @override
  _BounceWithFadeAnimationState createState() =>
      _BounceWithFadeAnimationState();
}

class _BounceWithFadeAnimationState extends State<BounceWithFadeAnimation>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> bounceAnimation;
  late Animation<double> fadeAnimation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: Duration(milliseconds: (1000 * widget.delay).round()),
      vsync: this,
    );

    // Bounce effect with smaller range
    final bounceCurve =
        CurvedAnimation(parent: controller, curve: Curves.easeInOutQuint);
    bounceAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(bounceCurve);

    // Fade-in effect from 0 to 1
    final fadeCurve =
        CurvedAnimation(parent: controller, curve: Curves.easeInOut);
    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(fadeCurve);

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Opacity(
          opacity: fadeAnimation.value,
          child: Transform.translate(
            offset: Offset(0, bounceAnimation.value),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
