import 'package:flutter/material.dart';

class EmptyDisplayWidget extends StatelessWidget {
  final String title;
  final String description;
  final IconData? icon;

  const EmptyDisplayWidget({
    super.key,
    required this.title,
    required this.description,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon ?? Icons.error,
          size: 48,
          color: Theme.of(context).colorScheme.onSurface.withAlpha(124),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          description,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withAlpha(124),
            fontSize: 12,
            letterSpacing: 0.025,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}
