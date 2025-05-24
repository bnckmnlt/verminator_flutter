import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/core/common/widgets/animation.dart';
import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:flutter_vermicomposting/core/utils/string_extensions.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin<HomeScreen> {
  final DateTime now = DateTime.now();

  int _currentTab = 0;

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

  final List<ChartData> _data = [
    ChartData('Fruit', 20, Color(0xff2563EB)),
    ChartData('Vegetable', 10, Color(0xff3B86F7)),
    ChartData('Grain', 4, Color(0xff60A8FB)),
    ChartData('Invalid', 14, Color(0xff90C7FE)),
  ];

  final List<ChartData> _nitrogenChartData = <ChartData>[
    ChartData('May 5', 58),
    ChartData('May 10', 37),
    ChartData('May 15', 32),
    ChartData('May 20', 28),
    ChartData('May 25', 22),
    ChartData('May 30', 27),
  ];

  final List<ChartData> _phosphorusChartData = <ChartData>[
    ChartData('May 5', 23),
    ChartData('May 10', 24),
    ChartData('May 15', 45),
    ChartData('May 20', 32),
    ChartData('May 25', 58),
    ChartData('May 30', 21),
  ];

  final List<ChartData> _potassiumChartData = <ChartData>[
    ChartData('May 5', 66),
    ChartData('May 10', 32),
    ChartData('May 15', 12),
    ChartData('May 20', 42),
    ChartData('May 25', 52),
    ChartData('May 30', 61),
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final formattedDate = DateFormat('d, MMMM y').format(now);
    final formattedTime = DateFormat('HH:mm').format(now);

    final List<Widget> _cardSections = [
      _foodWasteProcessedSection(context: context, data: _data),
      _readingsChart(context: context, data: [
        _nitrogenChartData,
        _phosphorusChartData,
        _potassiumChartData
      ]),
      Container(),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final double deviceHeight = MediaQuery.of(context).size.height;
        final double deviceWidth = MediaQuery.of(context).size.width;

        return Scaffold(
          body: Container(
            height: deviceHeight,
            width: deviceWidth,
            padding: const EdgeInsets.fromLTRB(44, 44, 44, 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _homeScreenHeaderSection(
                  formattedDate: formattedDate,
                  formattedTime: formattedTime,
                ),
                const SizedBox(height: 44),
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // TODO:
                            Expanded(
                              flex: 3,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 24, horizontal: 24),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    width: 1,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHigh,
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 0),
                                      child: Align(
                                        alignment: Alignment.topCenter,
                                        child: SingleChildScrollView(
                                          child: _cardSections[_currentTab],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Row(
                                        children: List.generate(
                                                3, (int index) => index,
                                                growable: false)
                                            .map((item) {
                                          return Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                item == 0 ? 0 : 6, 0, 0, 0),
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _currentTab = item;
                                                });
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 4,
                                                        horizontal: 12),
                                                decoration: BoxDecoration(
                                                  color: item == _currentTab
                                                      ? Color(0xFF27272a)
                                                      : Colors.transparent,
                                                  borderRadius:
                                                      BorderRadius.circular(24),
                                                  border: Border.all(
                                                    color: item == _currentTab
                                                        ? Color(0xFF27272a)
                                                        : Theme.of(context)
                                                            .colorScheme
                                                            .surfaceContainerHigh,
                                                  ),
                                                ),
                                                child: Text(
                                                  "${item + 1}",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Expanded(flex: 2, child: _sensorReadingsSection()),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
        vertical: 14,
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
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.greenAccent.withOpacity(0.05),
                      Colors.greenAccent.withOpacity(0.1),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
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
                    const Text(
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
                child: const Row(
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

Widget _foodWasteProcessedSection({
  required BuildContext context,
  required List<ChartData> data,
}) {
  return BounceWithFadeAnimation(
    delay: 1,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Food waste processed",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "The following summary reflects system conditions",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(186),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 200,
              child: SfCircularChart(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                series: <CircularSeries<ChartData, String>>[
                  DoughnutSeries(
                      explode: true,
                      explodeIndex: 3,
                      explodeOffset: '8%',
                      dataSource: data,
                      pointColorMapper: (ChartData data, _) => data.color,
                      xValueMapper: (ChartData data, _) => data.x,
                      yValueMapper: (ChartData data, _) => data.y)
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: data.map((item) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 8,
                        width: 8,
                        decoration: BoxDecoration(
                            color: item.color,
                            borderRadius: BorderRadius.circular(2)),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        item.x,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withAlpha(164),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.025,
                        ),
                      )
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _readingsChart({
  required BuildContext context,
  required List<List<ChartData>> data,
}) {
  final List<ChartData> chartColorList = [
    ChartData(
      "Nitrogen",
      0,
      Color(0xff2563EB),
    ),
    ChartData(
      "Phosphorus",
      0,
      Color(0xff3B86F7),
    ),
    ChartData(
      "Potassium",
      0,
      Color(0xff90C7FE),
    ),
  ];

  return BounceWithFadeAnimation(
    delay: 1,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Nutrient summary",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "The following show the NPK readings from the past few days",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(186),
              ),
            ),
          ],
        ),
        const SizedBox(height: 44),
        Center(
          child: Column(
            children: [
              SizedBox(
                height: 164,
                child: SfCartesianChart(
                  margin: const EdgeInsets.all(0),
                  plotAreaBorderWidth: 0,
                  plotAreaBackgroundColor: Colors.transparent,
                  primaryXAxis: const CategoryAxis(
                    axisLine: AxisLine(width: 0),
                    labelPlacement: LabelPlacement.onTicks,
                    edgeLabelPlacement: EdgeLabelPlacement.shift,
                    majorGridLines: MajorGridLines(width: 0),
                    majorTickLines: MajorTickLines(width: 0),
                    labelStyle: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.025,
                    ),
                  ),
                  primaryYAxis: const NumericAxis(
                    isVisible: false,
                  ),
                  series: <CartesianSeries<ChartData, String>>[
                    for (int i = 0; i < data.length; i++) ...[
                      SplineSeries<ChartData, String>(
                        color: chartColorList[i % chartColorList.length].color,
                        width: 2,
                        dataSource: data[i],
                        xValueMapper: (ChartData d, _) => d.x,
                        yValueMapper: (ChartData d, _) => d.y,
                      ),
                      SplineAreaSeries<ChartData, String>(
                        gradient: LinearGradient(
                          colors: [
                            chartColorList[i % chartColorList.length]
                                .color!
                                .withOpacity(0.25),
                            chartColorList[i % chartColorList.length]
                                .color!
                                .withOpacity(0.15),
                            chartColorList[i % chartColorList.length]
                                .color!
                                .withOpacity(0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        dataSource: data[i],
                        xValueMapper: (ChartData d, _) => d.x,
                        yValueMapper: (ChartData d, _) => d.y,
                      ),
                    ]
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: chartColorList.map((item) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 8,
                    width: 8,
                    decoration: BoxDecoration(
                        color: item.color,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    item.x,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withAlpha(164),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.025,
                    ),
                  )
                ],
              ),
            );
          }).toList(),
        ),
      ],
    ),
  );
}
