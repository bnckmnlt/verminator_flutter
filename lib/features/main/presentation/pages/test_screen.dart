import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vermicomposting/core/common/widgets/empty_display_widget.dart';
import 'package:flutter_vermicomposting/core/common/widgets/loader.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/home_screen_widgets/SensorReadingCard.dart';
import 'package:flutter_vermicomposting/features/sensor_reading/domain/entity/sensor_reading.dart';
import 'package:flutter_vermicomposting/features/sensor_reading/presentation/bloc/sensor_reading_bloc.dart';
import 'package:flutter_vermicomposting/main.dart';

import '../../../../core/constants/constants.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  @override
  void initState() {
    context.read<SensorReadingBloc>().add(SensorReadingList());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: BlocBuilder<SensorReadingBloc, SensorReadingState>(
        builder: (context, state) {
          if (state is SensorReadingLoading) {
            return Loader();
          } else if (state is SensorReadingFailure) {
            return EmptyDisplayWidget(
              title: "An error has occurred",
              description: state.error,
              icon: FluentIcons.cloud_error_24_regular,
            );
          } else if (state is SensorReadingListSuccess) {
            List<Map<String, dynamic>> parametersToMonitorList = [
              {
                "reading_key": "temperature",
                "layer": SystemLayer.bedding,
                "icon": FluentIcons.temperature_24_filled,
                "unit": "°C",
              },
              {
                "reading_key": "humidity",
                "layer": SystemLayer.bedding,
                "icon": FluentIcons.plant_grass_24_filled,
                "unit": "%",
              },
              {
                "reading_key": "soil_moisture",
                "layer": SystemLayer.bedding,
                "icon": FluentIcons.drop_24_filled,
                "unit": "%",
              },
              {
                "reading_key": "nitrogen",
                "layer": SystemLayer.compost,
                "icon": FluentIcons.weather_blowing_snow_24_filled,
                "unit": "%",
              },
              {
                "reading_key": "phosphorus",
                "layer": SystemLayer.compost,
                "icon": FluentIcons.hexagon_sparkle_24_filled,
                "unit": "%",
              },
              {
                "reading_key": "potassium",
                "layer": SystemLayer.compost,
                "icon": FluentIcons.flash_24_filled,
                "unit": "%",
              },
            ];

            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: 6,
              itemBuilder: (BuildContext context, int index) {
                final List<ChartData> readingList = (state.list
                        .where((reading) =>
                            reading.layer ==
                            parametersToMonitorList[index]['layer'])
                        .map((reading) {
                  return ChartData(
                    reading.createdAt,
                    (convertToReading(
                            parametersToMonitorList[index]['reading_key'],
                            reading) ??
                        0),
                  );
                }).toList()
                      ..sort((a, b) => b.x.compareTo(a.x)))
                    .sublist(0, 7);

                log.warning(readingList.first.y);

                return SensorReadingCard(
                  key: Key(index.toString()),
                  item: parametersToMonitorList[index],
                  readingValueList: readingList,
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

double? convertToReading(String sensor, SensorReading reading) {
  switch (sensor) {
    case "temperature":
      return reading.asBeddingReading?.temperature.value.toDouble();
    case "humidity":
      return reading.asBeddingReading?.humidity.value.toDouble();
    case "soil_moisture":
      return reading.asBeddingReading?.soilMoisture.value.toDouble();
    case "nitrogen":
      return reading.asCompostReading?.npk.nitrogen.toDouble();
    case "phosphorus":
      return reading.asCompostReading?.npk.phosphorus.toDouble();
    case "potassium":
      return reading.asCompostReading?.npk.potassium.toDouble();
    default:
  }

  return 0.0;
}
