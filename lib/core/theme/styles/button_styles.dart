import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/core/theme/styles/text_styles.dart';

enum AppButtonVariant { primary, secondary, outline, ghost, destructive }

final class AppButtonStyles {
  AppButtonStyles._();

  static ButtonStyle of({
    required BuildContext context,
    AppButtonVariant variant = AppButtonVariant.primary,
    double roundness = 8,
  }) {
    return switch (variant) {
      AppButtonVariant.primary => _primary(context, roundness),
      AppButtonVariant.secondary => _secondary(context, roundness),
      AppButtonVariant.outline => _outline(context, roundness),
      AppButtonVariant.ghost => _ghost(context, roundness),
      AppButtonVariant.destructive => _destructive(context, roundness),
    };
  }

  static ButtonStyle _primary(BuildContext context, double roundness) =>
      ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(roundness)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minimumSize: Size.zero,
      );

  static ButtonStyle _secondary(BuildContext context, double roundness) =>
      ElevatedButton.styleFrom(
        backgroundColor: Colors.grey.shade200,
        foregroundColor: Colors.black87,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(roundness)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minimumSize: Size.zero,
      );

  static ButtonStyle _outline(BuildContext context, double roundness) =>
      OutlinedButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.blueAccent,
        side: BorderSide(
            color: Theme.of(context).colorScheme.surfaceContainerHighest),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(roundness)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minimumSize: Size.zero,
      );

  static ButtonStyle _ghost(BuildContext context, double roundness) =>
      TextButton.styleFrom(
        foregroundColor: Colors.blueAccent,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(roundness)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minimumSize: Size.zero,
      );

  static ButtonStyle _destructive(BuildContext context, double roundness) =>
      ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(roundness)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minimumSize: Size.zero,
      );
}
