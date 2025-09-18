import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:flutter_vermicomposting/core/utils/convert_to_reading.dart';
import 'package:flutter_vermicomposting/features/main/data/models/sensor_values_model.dart';
import 'package:flutter_vermicomposting/features/main/domain/entities/sensor_values.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/home_screen_widgets/SensorReadingCard.dart';
import 'package:flutter_vermicomposting/features/sensor_reading/domain/entity/sensor_reading.dart';
import 'package:flutter_vermicomposting/mqtt_service.dart';
import 'package:get_it/get_it.dart';

class EnvironmentalMetricsWidget extends StatefulWidget {
  final List<SensorReading> sensorReadingList;

  const EnvironmentalMetricsWidget({
    super.key,
    required this.sensorReadingList,
  });

  @override
  State<EnvironmentalMetricsWidget> createState() =>
      _EnvironmentalMetricsWidgetState();
}

class _EnvironmentalMetricsWidgetState
    extends State<EnvironmentalMetricsWidget> {
  late MqttService _mqttService;

  late List<SensorReading> _sensorReadingList;

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
    _mqttService = GetIt.instance<MqttService>();

    _mqttService.beddingLayerStream.listen(_onData);
    _mqttService.compostLayerStream.listen(_onData);

    _sensorReadingList = widget.sensorReadingList;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<int> realtimeMetricsValues = [
      int.parse(sensorValues.temperature ?? "0"),
      int.parse(sensorValues.humidity ?? "0"),
      int.parse(sensorValues.soilMoisture ?? "0"),
      int.parse(sensorValues.nitrogen ?? "0"),
      int.parse(sensorValues.phosphorus ?? "0"),
      int.parse(sensorValues.potassium ?? "0"),
    ];

    return SizedBox(
      child: Column(
        spacing: 16,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Environmental Metrics",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: 6,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (BuildContext context, int index) {
              final List<ChartData> readingList = (_sensorReadingList
                      .where((reading) =>
                          reading.layer ==
                          Constants.parametersToMonitorList[index]['layer'])
                      .map((reading) {
                return ChartData(
                  reading.createdAt,
                  (convertToReading(
                          Constants.parametersToMonitorList[index]
                              ['reading_key'],
                          reading) ??
                      0),
                );
              }).toList())
                  .sublist(0, 7);

              return SensorReadingCard(
                key: Key(index.toString()),
                item: Constants.parametersToMonitorList[index],
                readingValueList: readingList,
                realtimeValue: realtimeMetricsValues[index],
              );
            },
          ),
        ],
      ),
    );
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
}
