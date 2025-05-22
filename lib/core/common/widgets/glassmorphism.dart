import 'dart:ui';

import 'package:flutter/material.dart';

class Glassmorphism extends StatelessWidget {
  final double blur;
  final double opacity;
  final Widget child;

  const Glassmorphism({
    super.key,
    required this.blur,
    required this.opacity,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withValues(alpha: opacity),
            borderRadius: const BorderRadius.all(
              Radius.circular(8),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
