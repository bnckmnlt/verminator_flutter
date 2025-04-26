import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/features/main/domain/entities/sensor_values.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/fluid_card_widget.dart';

class LiquidLayer extends StatefulWidget {
  const LiquidLayer({
    super.key,
    required this.sensorValue,
  });

  final SensorValues sensorValue;

  @override
  State<LiquidLayer> createState() => _LiquidLayerState();
}

class _LiquidLayerState extends State<LiquidLayer> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Fluids Layer",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.025,
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Fluids Layer
        SizedBox(
          height: 246,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              FluidCard(
                value: 4 / 28,
                label: "Compost Juice",
                data: "No data available",
                color: Colors.orangeAccent,
              ),
              SizedBox(width: 12),
              FluidCard(
                value: 28 / 28,
                label: "Water Reservoir",
                data: "No data available",
                color: Colors.lightBlueAccent,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
