import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/core/utils/string_extensions.dart';
import 'package:flutter_vermicomposting/features/main/data/models/sensor_values_model.dart';
import 'package:flutter_vermicomposting/features/main/domain/entities/sensor_values.dart';
import 'package:flutter_vermicomposting/mqtt_service.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';

class LiquidAndCompostLevelWidget extends StatefulWidget {
  final MqttService mqttService;

  const LiquidAndCompostLevelWidget({
    super.key,
    required this.mqttService,
  });

  @override
  State<LiquidAndCompostLevelWidget> createState() =>
      _LiquidAndCompostLevelWidgetState();
}

class _LiquidAndCompostLevelWidgetState
    extends State<LiquidAndCompostLevelWidget> {
  late StreamSubscription<String> _compostLayerSubscription;
  late StreamSubscription<String> _liquidLayerSubscription;

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

    _compostLayerSubscription =
        widget.mqttService.compostLayerStream.listen(_onData);
    _liquidLayerSubscription =
        widget.mqttService.fluidLayerStream.listen(_onData);
  }

  @override
  void dispose() {
    _compostLayerSubscription.cancel();
    _liquidLayerSubscription.cancel();
    super.dispose();
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
  Widget build(BuildContext context) {
    final List<ContainerLevel> containerItems = [
      ContainerLevel(
          label: "Compost",
          color: Colors.brown,
          value: sensorValues.compost ?? "0",
          unit: "/48kg"),
      ContainerLevel(
          label: "Vermitea",
          color: Colors.amberAccent,
          value: sensorValues.vermijuice ?? "0",
          unit: "/28L"),
      ContainerLevel(
          label: "Reservoir",
          color: Colors.lightBlueAccent,
          value: sensorValues.reservoir ?? "0",
          unit: "/28L"),
    ];

    return Column(
      children: [
        Container(
          height: 160,
          width: 320,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                width: 1,
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
              )),
          child: LiquidLinearProgressIndicator(
            value: ((safeParseDouble(containerItems.first.value) ?? 0).clamp(0, 48)) / 48,
            valueColor: AlwaysStoppedAnimation(containerItems.first.color),
            backgroundColor: Colors.transparent,
            borderColor: Colors.transparent,
            borderWidth: 0,
            borderRadius: 12.0,
            direction: Axis.vertical,
            center: Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: 18, horizontal: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    containerItems[0].label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Occupied",
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withAlpha(164),
                            fontWeight: FontWeight.w500,
                          )),
                      Row(
                        spacing: 2,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "${containerItems.first.value}kg",
                            style: TextStyle(
                              height: 1.2,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            containerItems.first.unit,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withAlpha(164),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 240,
          width: 320,
          child: Row(
            spacing: 10,
            children: containerItems.sublist(1).map((item) {
              return Expanded(
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        width: 1,
                        color:
                            Theme.of(context).colorScheme.surfaceContainerHigh,
                      )),
                  child: LiquidLinearProgressIndicator(
                    value: ((safeParseDouble(item.value) ?? 0).clamp(0, 28)) / 28,
                    valueColor: AlwaysStoppedAnimation(item.color),
                    backgroundColor: Colors.transparent,
                    borderColor: Colors.transparent,
                    borderWidth: 0,
                    borderRadius: 12.0,
                    direction: Axis.vertical,
                    center: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 18, horizontal: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Occupied",
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withAlpha(164),
                                    fontWeight: FontWeight.w500,
                                  )),
                              Row(
                                spacing: 2,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "${item.value}L",
                                    style: TextStyle(
                                      height: 1.2,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    item.unit,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withAlpha(164),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class ContainerLevel {
  final String label;
  final Color color;
  final String value;
  final String unit;

  ContainerLevel({
    required this.label,
    required this.color,
    required this.value,
    required this.unit,
  });
}
