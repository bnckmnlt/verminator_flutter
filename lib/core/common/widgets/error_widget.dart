import 'package:flutter/material.dart';

class GeneralErrorWidget extends StatelessWidget {
  final String errorTitle;
  final String errorMessage;
  final IconData? errorIcon;

  const GeneralErrorWidget({
    super.key,
    required this.errorTitle,
    required this.errorMessage,
    this.errorIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(errorIcon ?? Icons.error, size: 48),
        const SizedBox(height: 8),
        Text(
          errorTitle,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          errorMessage,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withAlpha(168),
            fontSize: 14,
            letterSpacing: 0.025,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}
