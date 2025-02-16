import 'package:flutter/material.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';

class FluidCard extends StatelessWidget {
  final double value;
  final String label;
  final String data;
  final Color color;

  const FluidCard({
    super.key,
    required this.value,
    required this.label,
    required this.data,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    bool isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Expanded(
      child: LiquidLinearProgressIndicator(
        value: value,
        valueColor: AlwaysStoppedAnimation(color),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderColor: color,
        borderWidth: 1.0,
        borderRadius: 6.0,
        direction: Axis.vertical,
        center: Padding(
          padding: const EdgeInsets.only(top: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isDark
                      ? Theme.of(context).colorScheme.onSurface
                      : Theme.of(context).colorScheme.onSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  height: 1.8,
                  letterSpacing: 0.025,
                ),
              ),
              Text(
                data,
                style: TextStyle(
                  color: isDark
                      ? Theme.of(context).colorScheme.onSurface
                      : Theme.of(context).colorScheme.onSecondary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  height: 1,
                  letterSpacing: 0.025,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
