import 'dart:async';
import 'dart:convert';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:flutter_vermicomposting/core/utils/string_extensions.dart';
import 'package:flutter_vermicomposting/features/main/data/models/sensor_values_model.dart';
import 'package:flutter_vermicomposting/features/main/domain/entities/sensor_values.dart';
import 'package:flutter_vermicomposting/mqtt_service.dart';
import 'package:google_fonts/google_fonts.dart';

// TODO: [✅] DONEEEEEE

class SensorReadingsWidget extends StatefulWidget {
  final MqttService mqttService;

  const SensorReadingsWidget({
    super.key,
    required this.mqttService,
  });

  @override
  State<SensorReadingsWidget> createState() => _SensorReadingsWidgetState();
}

class _SensorReadingsWidgetState extends State<SensorReadingsWidget> {
  late StreamSubscription<String> _beddingLayerSubscription;
  late StreamSubscription<String> _compostLayerSubscription;
  late StreamSubscription<String> _fluidLayerSubscription;

  Map<String, dynamic> _collectedData = {};

  SensorValues sensorValues = SensorValues(
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

    _beddingLayerSubscription =
        widget.mqttService.beddingLayerStream.listen(_onData);
    _compostLayerSubscription =
        widget.mqttService.compostLayerStream.listen(_onData);
    _fluidLayerSubscription =
        widget.mqttService.fluidLayerStream.listen(_onData);
  }

  void _onData(String? data) {
    if (data == null) return;
    try {
      final map = jsonDecode(data) as Map<String, dynamic>;
      _collectedData.addAll(map);
      setState(() {
        sensorValues = SensorValuesModel.fromJson(_collectedData);
      });
    } catch (_) {}
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
    final List<SensorReadings> sensorDisplayList = [
      SensorReadings(
        icon: FluentIcons.temperature_24_regular,
        label: "Temperature",
        value: sensorValues.temperature.toString(),
        unit: "°C",
        status: getSensorStatus(
            type: 'temperature', value: sensorValues.temperature),
      ),
      SensorReadings(
        icon: FluentIcons.drop_24_regular,
        label: "Humidity",
        value: sensorValues.humidity.toString(),
        unit: "%",
        status: getSensorStatus(type: 'humidity', value: sensorValues.humidity),
      ),
      SensorReadings(
        icon: FluentIcons.plant_grass_24_regular,
        label: "Soil Moisture",
        value: sensorValues.soilMoisture.toString(),
        unit: "%",
        status: getSensorStatus(
            type: 'soilMoisture', value: sensorValues.soilMoisture),
      ),
      SensorReadings(
        icon: FluentIcons.weather_blowing_snow_24_regular,
        label: "Nitrogen",
        value: sensorValues.nitrogen.toString(),
        unit: "%",
        status: getSensorStatus(type: 'nitrogen', value: sensorValues.nitrogen),
      ),
      SensorReadings(
        icon: FluentIcons.hexagon_sparkle_24_regular,
        label: "Phosphorus",
        value: sensorValues.phosphorus.toString(),
        unit: "%",
        status:
            getSensorStatus(type: 'phosphorus', value: sensorValues.phosphorus),
      ),
      SensorReadings(
        icon: FluentIcons.flash_24_regular,
        label: "Potassium",
        value: sensorValues.potassium.toString(),
        unit: "%",
        status:
            getSensorStatus(type: 'potassium', value: sensorValues.potassium),
      ),
    ];

    return SafeArea(
      child: GridView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        itemCount: sensorDisplayList.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (BuildContext context, int index) {
          final info = sensorDisplayList[index];
          final status = sensorDisplayList[index].status;

          return Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                width: 1,
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(info.icon, size: 20),
                    const SizedBox(height: 8),
                    Text(info.label,
                        style: const TextStyle(letterSpacing: 0.025)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          info.value,
                          style: GoogleFonts.spaceMono(
                            fontSize: 44,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.025,
                          ),
                        ),
                        const SizedBox(width: 2.5),
                        Text(
                          info.unit,
                          style: GoogleFonts.spaceMono(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withAlpha(124),
                            fontSize: 38,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.025,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: getSensorStatusColor(context, status).first,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 1,
                        horizontal: 8,
                      ),
                      child: Text(
                        status.name.firstLetterUpperCase(),
                        style: TextStyle(
                          color: getSensorStatusColor(context, status).last,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.025,
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

SensorStatus getSensorStatus({
  required String type,
  required String? value,
}) {
  if (value == null) return SensorStatus.bad;

  double? numValue = double.tryParse(value);
  if (numValue == null) return SensorStatus.bad;

  switch (type) {
    case 'temperature':
      if (numValue >= 15 && numValue <= 30) return SensorStatus.good;
      if (numValue >= 10 && numValue < 15 || numValue > 30 && numValue <= 35) {
        return SensorStatus.fair;
      }
      return SensorStatus.bad;
    case 'humidity':
      if (numValue >= 70 && numValue <= 80) return SensorStatus.good;
      if ((numValue >= 60 && numValue < 70) ||
          (numValue > 80 && numValue <= 85)) return SensorStatus.fair;
      return SensorStatus.bad;
    case 'soilMoisture':
      if (numValue >= 65 && numValue <= 80) return SensorStatus.good;
      if ((numValue >= 60 && numValue < 65) ||
          (numValue > 80 && numValue <= 90)) return SensorStatus.fair;
      return SensorStatus.bad;
    case 'nitrogen':
      if (numValue >= 20 && numValue <= 40) return SensorStatus.good;
      if (numValue >= 15 && numValue < 20 || numValue > 40 && numValue <= 50)
        return SensorStatus.fair;
      return SensorStatus.bad;
    case 'phosphorus':
      if (numValue >= 10 && numValue <= 30) return SensorStatus.good;
      if ((numValue >= 5 && numValue < 10) || (numValue > 30 && numValue <= 40))
        return SensorStatus.fair;
      return SensorStatus.bad;
    case 'potassium':
      if (numValue >= 15 && numValue <= 30) return SensorStatus.good;
      if ((numValue >= 10 && numValue < 15) ||
          (numValue > 30 && numValue <= 35)) return SensorStatus.fair;
      return SensorStatus.bad;
    case 'compost':
      if (numValue >= 1 && numValue <= 10) return SensorStatus.good;
      return SensorStatus.fair;
    case 'vermijuice':
      if (numValue >= 1 && numValue <= 10) return SensorStatus.good;
      return SensorStatus.fair;
    case 'reservoir':
      if (numValue > 1) return SensorStatus.good;
      return SensorStatus.bad;
    default:
      return SensorStatus.bad;
  }
}

List<Color> getSensorStatusColor(BuildContext context, SensorStatus status) {
  switch (status) {
    case SensorStatus.bad:
      return [Colors.redAccent, Colors.white];
    case SensorStatus.good:
      return [Colors.greenAccent, Colors.black];
    case SensorStatus.fair:
    default:
      return [
        Theme.of(context).colorScheme.onSurface,
        Theme.of(context).colorScheme.surface
      ];
  }
}
