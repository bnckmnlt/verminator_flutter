import 'package:flutter/material.dart';

import 'app_background.dart';
import 'glassmorphism.dart';

class GlassmorphicCardWidget extends StatelessWidget {
  final Widget child;

  const GlassmorphicCardWidget({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Glassmorphism(
      blur: 64,
      opacity: 0.3,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(
              Radius.circular(8),
            ),
            border: Border.all(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              width: 1,
            )),
        child: ClipPath(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 44.0, horizontal: 44.0),
            child: AppBackground(
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
