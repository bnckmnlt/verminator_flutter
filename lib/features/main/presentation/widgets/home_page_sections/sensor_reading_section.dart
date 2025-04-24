import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/layers/bedding_layer.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/layers/compost_layer.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/layers/liquid_layer.dart';
import 'package:flutter_vermicomposting/mqtt_service.dart';
import 'package:get_it/get_it.dart';

class SensorReadingSection extends StatefulWidget {
  const SensorReadingSection({super.key});

  @override
  State<SensorReadingSection> createState() => _SensorReadingSectionState();
}

class _SensorReadingSectionState extends State<SensorReadingSection> {
  late MqttService _mqttService;

  @override
  void initState() {
    super.initState();

    _mqttService = GetIt.I<MqttService>();
    _mqttService.connect();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int columns = 3;
        double itemWidth = constraints.maxWidth / columns - 16;

        return Wrap(
          spacing: 16,
          runSpacing: 0,
          children: [
            SizedBox(
              width: itemWidth,
              child: BeddingLayer(),
            ),
            SizedBox(
              width: itemWidth,
              child: CompostLayer(),
            ),
            SizedBox(
              width: itemWidth,
              child: LiquidLayer(),
            ),
          ],
        );
      },
    );
  }
}
