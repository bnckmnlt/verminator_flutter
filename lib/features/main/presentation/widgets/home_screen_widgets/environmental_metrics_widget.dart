import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:flutter_vermicomposting/core/utils/convert_to_reading.dart';
import 'package:flutter_vermicomposting/core/utils/string_extensions.dart';
import 'package:flutter_vermicomposting/features/main/data/models/sensor_values_model.dart';
import 'package:flutter_vermicomposting/features/main/domain/entities/sensor_values.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/home_screen_widgets/sensor_reading_card_widget.dart';
import 'package:flutter_vermicomposting/features/sensor_reading/domain/entity/sensor_reading.dart';
import 'package:flutter_vermicomposting/mqtt_service.dart';
import 'package:get_it/get_it.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';

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

    final List<ContainerLevel> containerItems = [
      ContainerLevel(
        label: "Compost",
        color: Colors.brown,
        value: sensorValues.compost ?? "0",
        unit: "kg",
        capacity: 48,
      ),
      ContainerLevel(
        label: "Vermitea",
        color: Colors.amberAccent,
        value: sensorValues.vermijuice ?? "0",
        unit: "L",
        capacity: 28,
      ),
      ContainerLevel(
        label: "Reservoir",
        color: Colors.lightBlueAccent,
        value: sensorValues.reservoir ?? "0",
        unit: "L",
        capacity: 28,
      ),
    ];

    return SizedBox(
      child: Column(
        spacing: 20,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Composting Conditions",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 12,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.51855,
                  child: GridView.builder(
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
                      }).toList());

                      return SensorReadingCard(
                        key: Key(index.toString()),
                        item: Constants.parametersToMonitorList[index],
                        readingValueList: readingList,
                        realtimeValue: realtimeMetricsValues[index],
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: 516,
                  width: 364,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 12,
                    children: [
                      Expanded(
                          child:
                              _buildContainerLevelIndicator(containerItems[0])),
                      Expanded(
                        child: Row(
                          spacing: 12,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: containerItems
                              .asMap()
                              .entries
                              .where((entry) => entry.key != 0)
                              .map((entry) {
                            final ContainerLevel data = entry.value;

                            return Expanded(
                                child: _buildContainerLevelIndicator(data));
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContainerLevelIndicator(ContainerLevel containerData) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color:
            Theme.of(context).colorScheme.surfaceContainerHigh.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.surfaceContainer,
          width: 1.5,
        ),
      ),
      child: LiquidLinearProgressIndicator(
        value: ((safeParseDouble(containerData.value) ?? 0).clamp(0, 28)) /
            containerData.capacity,
        valueColor: AlwaysStoppedAnimation(containerData.color.withAlpha(24)),
        backgroundColor: Colors.transparent,
        borderColor: Colors.transparent,
        borderWidth: 0,
        borderRadius: 12.0,
        direction: Axis.vertical,
        center: Container(
          padding: EdgeInsets.symmetric(vertical: 24, horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Text(containerData.label.toUpperCase(),
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: "Zenbones Mono",
                      fontWeight: FontWeight.bold,
                    )),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: 6,
                children: [
                  Text("Capacity",
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withAlpha(164),
                        fontSize: 16,
                        fontFamily: "Zenbones Mono",
                      )),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    spacing: 2.5,
                    children: [
                      Text("${containerData.value}${containerData.unit}",
                          style: TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.025,
                            height: 0.99,
                          )),
                      Text("/${containerData.capacity}${containerData.unit}",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.025,
                          )),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
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

class ContainerLevel {
  final String label;
  final Color color;
  final String value;
  final String unit;
  final int capacity;

  ContainerLevel({
    required this.label,
    required this.color,
    required this.value,
    required this.unit,
    required this.capacity,
  });
}
