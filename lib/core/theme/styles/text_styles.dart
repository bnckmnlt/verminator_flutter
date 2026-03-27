import 'package:flutter/material.dart';

final class AppTextStyles {
  AppTextStyles._();

  static const TextStyle h2 = TextStyle(
    fontSize: 68,
    fontWeight: FontWeight.bold,
    height: 1,
    letterSpacing: -1,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 16 / 12,
    letterSpacing: -1,
  );

  static const TextStyle h4 = TextStyle(
    fontSize: 22,
    height: 16 / 12,
    letterSpacing: -0.25,
  );

  static TextStyle paragraph({
    required BuildContext context,
    double size = 16,
  }) {
    return TextStyle(
      fontSize: size,
      color: Theme.of(context).colorScheme.onSurface.withAlpha(124),
      letterSpacing: -0.5,
    );
  }

  static TextStyle paragraphMedium({
    required BuildContext context,
    double size = 16,
  }) {
    return TextStyle(
      fontSize: size,
      color: Theme.of(context).colorScheme.onSurface.withAlpha(124),
      fontWeight: FontWeight.w500,
      letterSpacing: -0.5,
    );
  }

  static TextStyle paragraphSemibold({
    required BuildContext context,
    double size = 16,
  }) {
    return TextStyle(
      fontSize: size,
      color: Theme.of(context).colorScheme.onSurface.withAlpha(124),
      fontWeight: FontWeight.w600,
      letterSpacing: -0.5,
    );
  }
}
