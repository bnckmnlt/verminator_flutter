import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:flutter_vermicomposting/core/utils/string_extensions.dart';

class SensorReadingsWidget extends StatefulWidget {
  const SensorReadingsWidget({super.key});

  @override
  State<SensorReadingsWidget> createState() => _SensorReadingsWidgetState();
}

class _SensorReadingsWidgetState extends State<SensorReadingsWidget> {
  final List<SensorReadings> _sensorReadings = [
    SensorReadings(
      icon: FluentIcons.temperature_24_regular,
      label: "Temperature",
      value: "32",
      unit: "°C",
      status: SensorStatus.good,
    ),
    SensorReadings(
      icon: FluentIcons.drop_24_regular,
      label: "Humidity",
      value: "64",
      unit: "%",
      status: SensorStatus.good,
    ),
    SensorReadings(
      icon: FluentIcons.plant_grass_24_regular,
      label: "Soil Moisture",
      value: "69",
      unit: "%",
      status: SensorStatus.good,
    ),
    SensorReadings(
      icon: FluentIcons.weather_blowing_snow_24_regular,
      label: "Nitrogen",
      value: "64",
      unit: "%",
      status: SensorStatus.good,
    ),
    SensorReadings(
      icon: FluentIcons.hexagon_sparkle_24_regular,
      label: "Phosphorus",
      value: "32",
      unit: "°C",
      status: SensorStatus.good,
    ),
    SensorReadings(
      icon: FluentIcons.flash_24_regular,
      label: "Potassium",
      value: "64",
      unit: "%",
      status: SensorStatus.good,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      shrinkWrap: true,
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (BuildContext context, int index) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.blueGrey.withAlpha(6),
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
                  Icon(
                    _sensorReadings[index].icon,
                    size: 20,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _sensorReadings[index].label,
                    style: const TextStyle(
                      letterSpacing: 0.025,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _sensorReadings[index].value,
                        style: const TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.025,
                        ),
                      ),
                      const SizedBox(width: 2.5),
                      Text(
                        _sensorReadings[index].unit,
                        style: TextStyle(
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
                      color: Theme.of(context).colorScheme.onSurface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 1,
                      horizontal: 8,
                    ),
                    child: Text(
                      _sensorReadings[index].status.name.firstLetterUpperCase(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.surface,
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
    );
  }
}
