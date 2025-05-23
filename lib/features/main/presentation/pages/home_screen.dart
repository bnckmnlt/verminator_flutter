import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:flutter_vermicomposting/core/utils/string_extensions.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DateTime now = DateTime.now();

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

  List<SummaryCardItem> _summaryItems = [
    SummaryCardItem(
      label: "Total Food Processed",
      value: "32",
      unit: "pcs",
      icon: FluentIcons.food_apple_24_regular,
      color: Colors.lightBlueAccent,
    ),
    SummaryCardItem(
      label: "Total Compost Produced",
      value: "54",
      unit: "kg",
      icon: Icons.eco_rounded,
      color: Colors.greenAccent,
    ),
    SummaryCardItem(
      label: "Total Vermijuice Collected",
      value: "22",
      unit: "L",
      icon: FluentIcons.drink_bottle_20_regular,
      color: Colors.amberAccent,
    ),
    SummaryCardItem(
      label: "Total Cycle/s Completed",
      value: "1",
      unit: " cycle",
      icon: FluentIcons.recycle_20_regular,
      color: Colors.indigoAccent,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('d, MMMM y').format(now);
    final formattedTime = DateFormat('HH:mm').format(now);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double deviceHeight = MediaQuery.of(context).size.height;
        final double deviceWidth = MediaQuery.of(context).size.width;

        return Scaffold(
          body: Container(
            height: deviceHeight,
            width: deviceWidth,
            padding: const EdgeInsets.symmetric(vertical: 44, horizontal: 44),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _homeScreenHeaderSection(
                  formattedDate: formattedDate,
                  formattedTime: formattedTime,
                ),
                const SizedBox(height: 64),
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // TODO:
                            Expanded(
                              flex: 2,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    width: 1,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHigh,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Expanded(child: _sensorReadingsSection()),
                          ],
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Row(
                          children: [
                            SingleChildScrollView(
                              child: Column(
                                children: [
                                  // TODO: Camera + YOLO inference window
                                  Container(
                                    height: 320,
                                    width: 320,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        width: 1,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surfaceContainerHigh,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // TODO: Worm monitoring window
                                  Container(
                                    height: 320,
                                    width: 320,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        width: 1,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surfaceContainerHigh,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: List.generate(_summaryItems.length,
                                      (index) {
                                    final item = _summaryItems[index];
                                    final isLast =
                                        index == _summaryItems.length - 1;
                                    return Column(
                                      children: [
                                        if (index == 0)
                                          _systemHealthCard(isLast),
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(
                                              0, 0, 0, isLast ? 0.0 : 16.0),
                                          child: _summaryCard(
                                            label: item.label,
                                            value: item.value,
                                            unit: item.unit,
                                            icon: item.icon,
                                            color: item.color,
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _homeScreenHeaderSection({
    required String formattedDate,
    required String formattedTime,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Good Morning!",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "The following summary reflects system conditions as of ${formattedDate} at ${formattedTime}",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(186),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _sensorReadingsSection() {
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

  Widget _summaryCard({
    required String label,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          width: 1,
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
              const SizedBox(width: 2.5),
              Text(
                unit,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(124),
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.025,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(124),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _systemHealthCard(bool isLast) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, isLast ? 0.0 : 16.0),
      child: ClipRRect(
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              width: 1,
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "System Health",
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withAlpha(124),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Icon(
                          FluentIcons.heart_pulse_24_regular,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withAlpha(124),
                          size: 16,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Excellent",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                color: Colors.white.withAlpha(32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "View Schedule Record",
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(
                      FluentIcons.chevron_right_24_filled,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
