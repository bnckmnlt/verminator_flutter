import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/features/main/domain/entities/sensor_values.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/summary_card_widget.dart';

class BeddingLayer extends StatefulWidget {
  const BeddingLayer({
    super.key,
    required this.sensorValue,
  });

  final SensorValues sensorValue;

  @override
  State<BeddingLayer> createState() => _BeddingLayerState();
}

class _BeddingLayerState extends State<BeddingLayer> {
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
              value: widget.sensorValue.temperature.toString() + "°C",
              icon: FluentIcons.temperature_24_filled,
              color: Colors.red,
            ),
            const SizedBox(height: 12),
            SummaryCard(
              label: "Humidity",
              value: widget.sensorValue.humidity.toString() + "%",
              icon: FluentIcons.drop_24_filled,
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
            SummaryCard(
              label: "Soil Moisture",
              value: widget.sensorValue.soilMoisture.toString() + "%",
              icon: FluentIcons.plant_grass_24_filled,
              color: Colors.lightGreen,
            ),
          ],
        ),
      ],
    );
  }
}
