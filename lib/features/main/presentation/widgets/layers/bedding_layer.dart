import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/summary_card_widget.dart';

class BeddingLayer extends StatelessWidget {
  const BeddingLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: const Text(
            "Bedding Layer",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.025,
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Bedding Layer
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SummaryCard(
              label: "Temperature",
              value: "32°C",
              icon: FluentIcons.temperature_24_filled,
              color: Colors.red,
            ),
            const SizedBox(height: 12),
            SummaryCard(
              label: "Moisture",
              value: "64%",
              icon: FluentIcons.drop_24_filled,
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
            SummaryCard(
              label: "Soil Moisture",
              value: "32%",
              icon: FluentIcons.plant_grass_24_filled,
              color: Colors.lightGreen,
            ),
          ],
        ),
      ],
    );
  }
}
