import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/features/main/data/models/sensor_values_model.dart';
import 'package:flutter_vermicomposting/features/main/domain/entities/sensor_values.dart';
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

  late StreamSubscription<String> _beddingLayerSubscription;
  late StreamSubscription<String> _compostLayerSubscription;
  late StreamSubscription<String> _fluidLayerSubscription;

  // Local storage for each layer's latest parsed JSON
  Map<String, dynamic> _beddingData = {};
  Map<String, dynamic> _compostData = {};
  Map<String, dynamic> _fluidData = {};

  late SensorValues sensorValues = SensorValues(
    temperature: "0",
    humidity: "0",
    soilMoisture: "0",
    nitrogen: "0",
    phosphorus: "0",
    potassium: "0",
    compost: "0",
    vermijuice: "0",
    reservoir: "0",
  );

  @override
  void initState() {
    super.initState();

    _mqttService = GetIt.I<MqttService>();
    _mqttService.connect();

    // Listen on bedding layer
    _beddingLayerSubscription = _mqttService.beddingLayerStream.listen((event) {
      _beddingData = _safeJson(event);
      _updateSensorValues();
    });

    _compostLayerSubscription = _mqttService.compostLayerStream.listen((event) {
      _compostData = _safeJson(event);
      _updateSensorValues();
    });

    _fluidLayerSubscription = _mqttService.fluidLayerStream.listen((event) {
      _fluidData = _safeJson(event);
      _updateSensorValues();
    });
  }

  Map<String, dynamic> _safeJson(String? source) {
    if (source == null) return {};
    try {
      return jsonDecode(source) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  /// Merge and update the SensorValuesModel for the UI
  void _updateSensorValues() {
    // Combine the maps. Later maps overwrite previous values.
    final merged = <String, dynamic>{}
      ..addAll(_beddingData)
      ..addAll(_compostData)
      ..addAll(_fluidData);
    setState(() {
      sensorValues = SensorValuesModel.fromJson(merged);
    });
  }

  @override
  void dispose() {
    _beddingLayerSubscription.cancel();
    _compostLayerSubscription.cancel();
    _fluidLayerSubscription.cancel();
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
              child: BeddingLayer(
                sensorValue: sensorValues,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: CompostLayer(
                sensorValue: sensorValues,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: LiquidLayer(
                sensorValue: sensorValues,
              ),
            ),
          ],
        );
      },
    );
  }
}
