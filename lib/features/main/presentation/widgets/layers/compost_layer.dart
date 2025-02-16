// lib/features/main/presentation/widgets/compost_layer.dart
import 'package:flutter/material.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';

import '../sensor_card_widget.dart';

class CompostLayer extends StatelessWidget {
  const CompostLayer({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Column(
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Compost Layer",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.025,
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Compost Layer
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // NPK Sensor
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                SensorCard(label: "Nitrogen (N)", value: "53 mg/kg"),
                SensorCard(label: "Phosphorus (P)", value: "120 mg/kg"),
                SensorCard(label: "Potassium (K)", value: "118 mg/kg"),
              ],
            ),

            const SizedBox(height: 12),
            // Produced Compost
            SizedBox(
              height: 150,
              child: LiquidLinearProgressIndicator(
                value: 0 / 48,
                valueColor: AlwaysStoppedAnimation(
                  Colors.brown.shade400,
                ),
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHigh,
                borderColor: Colors.brown.shade200,
                borderWidth: 1.0,
                borderRadius: 6.0,
                direction: Axis.vertical,
                center: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Compost Produced",
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
                      "No data available",
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
          ],
        ),
      ],
    );
  }
}
