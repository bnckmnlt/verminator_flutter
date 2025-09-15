import 'dart:async';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vermicomposting/core/common/widgets/empty_display_widget.dart';
import 'package:flutter_vermicomposting/core/common/widgets/loader.dart';
import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/home_screen_widgets/SensorReadingCard.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/home_screen_widgets/video_feed_widget.dart';
import 'package:flutter_vermicomposting/features/sensor_reading/domain/entity/sensor_reading.dart';
import 'package:flutter_vermicomposting/features/sensor_reading/presentation/bloc/sensor_reading_bloc.dart';
import 'package:flutter_vermicomposting/mqtt_service.dart';
import 'package:get_it/get_it.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  int visionCurrentTab = 0;
  int chartOverviewCurrentTab = 0;

  WebViewController? cameraFeedController;
  WebViewController? thermalFeedController;

  late List<SummaryCardItem> _summaryItems;

  late MqttService _mqttService;

  late StreamSubscription<String> _controlCameraSubscription;
  late StreamSubscription<String> _controlThermalSubscription;

  late bool cameraState;
  late bool thermalCameraState;

  @override
  void initState() {
    _mqttService = GetIt.I<MqttService>();

    context.read<SensorReadingBloc>().add(SensorReadingList());

    cameraState = false;
    thermalCameraState = false;

    _controlCameraSubscription =
        _mqttService.controlCameraStream.listen((value) {
      setState(() {
        cameraState = value == 'active' ? true : false;
      });
    });

    _controlThermalSubscription =
        _mqttService.controlThermalStream.listen((value) {
      setState(() {
        thermalCameraState = value == 'active' ? true : false;
      });
    });

    _summaryItems = [
      SummaryCardItem(
        label: "Total Food Processed",
        value: "511 ",
        unit: "pcs. of waste",
        icon: FluentIcons.food_apple_24_filled,
        color: Colors.lightBlueAccent,
      ),
      SummaryCardItem(
        label: "Total Compost Produced",
        value: "3",
        unit: "kg of soil",
        icon: Icons.eco_rounded,
        color: Colors.lightBlueAccent,
      ),
      SummaryCardItem(
        label: "Total Vermitea Collected",
        value: "4",
        unit: "L of vermitea",
        icon: FluentIcons.drink_bottle_20_filled,
        color: Colors.lightBlueAccent,
      ),
      SummaryCardItem(
        label: "Total Cycle/s Completed",
        value: "2",
        unit: " cycles",
        icon: FluentIcons.recycle_20_filled,
        color: Colors.lightBlueAccent,
      ),
    ];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double deviceHeight = MediaQuery.of(context).size.height;
    final double deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: Container(
          height: deviceHeight,
          width: deviceWidth,
          padding: const EdgeInsets.fromLTRB(32, 28, 32, 28),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 28,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16,
                  children: [
                    _cameraAndThermalmonitoringSection(),
                    Expanded(child: _compostingPerformanceOverviewSection()),
                  ],
                ),
                Row(
                  spacing: 16,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: _environmentalMetricsSection(),
                    ),
                    Expanded(child: _todaysReportSection()),
                    Expanded(child: _summarySection()),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _compostingPerformanceOverviewSection() {
    List<Map<String, dynamic>> chartsOverviewTabs = [
      {
        "label": "Bedding Condition",
      },
      {
        "label": "Nutrient Level",
      },
      {
        "label": "Materials Processed",
      },
    ];

    return Column(
      spacing: 16,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Composting Performance Overview",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        Column(
          spacing: 10,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: 14,
              children: chartsOverviewTabs.asMap().entries.map((entry) {
                final int index = entry.key;
                final Map<String, dynamic> item = entry.value;

                final bool activeTab = entry.key == chartOverviewCurrentTab;

                return GestureDetector(
                  onTap: () => setState(() => chartOverviewCurrentTab = index),
                  child: Row(
                    spacing: 8,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        transitionBuilder: (child, animation) =>
                            ScaleTransition(scale: animation, child: child),
                        child: activeTab
                            ? Container(
                                key: const ValueKey('dot'),
                                height: 6,
                                width: 6,
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  shape: BoxShape.circle,
                                ),
                              )
                            : const SizedBox.shrink(key: ValueKey('empty')),
                      ),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 250),
                        style: TextStyle(
                          color: activeTab
                              ? Theme.of(context).colorScheme.onSurface
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withAlpha(124),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        child: Text(item['label']),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            Container(
              height: 425,
              decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerLow
                      .withAlpha(124),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    width: 2,
                  )),
            ),
          ],
        )
      ],
    );
  }

  Widget _cameraAndThermalmonitoringSection() {
    final List<Map<String, dynamic>> cameraParameterList = [
      {
        "controller": cameraFeedController,
        "state": cameraState,
      },
      {
        "controller": thermalFeedController,
        "state": thermalCameraState,
      },
    ];

    bool state = cameraParameterList[visionCurrentTab]["state"];
    String source = Constants.serverList[visionCurrentTab]['src'];
    String topic = Constants.serverList[visionCurrentTab]['topic'];

    List<Map<String, dynamic>> functions = [
      {
        "icon": FluentIcons.power_24_filled,
        "function": () {
          _mqttService.publish(topic, cameraState ? "inactive" : "active",
              qos: MqttQos.atLeastOnce, retain: true);
        }
      },
      {
        "icon": FluentIcons.arrow_sync_24_filled,
        "function": () =>
            reloadWebView(cameraParameterList[visionCurrentTab]['controller']),
      },
    ];

    return SizedBox(
      width: 640,
      child: Column(
        spacing: 16,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Computer Vision and Thermal Feed",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          Column(
            spacing: 10,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  spacing: 14,
                  children: Constants.serverList.asMap().entries.map((entry) {
                    final int index = entry.key;
                    final Map<String, dynamic> item = entry.value;

                    bool activeTab = visionCurrentTab == index;

                    return GestureDetector(
                      onTap: () => setState(() => visionCurrentTab = index),
                      child: Row(
                        spacing: 8,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            transitionBuilder: (child, animation) =>
                                ScaleTransition(scale: animation, child: child),
                            child: activeTab
                                ? Container(
                                    key: const ValueKey('dot'),
                                    height: 6,
                                    width: 6,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      shape: BoxShape.circle,
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 250),
                            style: TextStyle(
                              color: activeTab
                                  ? Theme.of(context).colorScheme.onSurface
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withAlpha(124),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            child: Text(item['label']),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              Container(
                height: 425,
                width: 640,
                decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerLow
                        .withAlpha(124),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      width: 2,
                    )),
                child: Stack(
                  children: [
                    state
                        ? VideoFeedWidget(
                            onWebViewCreated: (controller) {
                              cameraParameterList[visionCurrentTab]
                                  ["controller"] = controller;
                            },
                            cameraChannel: source,
                          )
                        : Center(
                            child: EmptyDisplayWidget(
                              title: "Inactive Device",
                              description:
                                  "The device is currently not operational or has no active session.",
                            ),
                          ),
                    Positioned(
                      top: 20,
                      right: 20,
                      child: Container(
                          padding: const EdgeInsets.fromLTRB(14, 5, 14, 5),
                          decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                width: 1,
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest
                                    .withAlpha(32),
                              )),
                          child: Row(
                            spacing: 6,
                            children: [
                              Container(
                                height: 8,
                                width: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      state ? Colors.redAccent : Colors.white,
                                ),
                              ),
                              Text(
                                "LIVE",
                                style: TextStyle(
                                  color:
                                      state ? Colors.redAccent : Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 20,
                      child: Row(
                        spacing: 8,
                        children: List.generate(2, (int index) => index)
                            .asMap()
                            .entries
                            .map((entry) {
                          final int index = entry.key;
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Material(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withValues(alpha: 0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest
                                      .withAlpha(32),
                                  width: 1,
                                ),
                              ),
                              child: InkWell(
                                onTap: functions[index]['function'],
                                splashColor: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.1),
                                highlightColor: Colors.transparent,
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Icon(
                                    functions[index]['icon'],
                                    size: 24,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _environmentalMetricsSection() {
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
          BlocBuilder<SensorReadingBloc, SensorReadingState>(
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
                return GridView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: 6,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    final List<ChartData> readingList = (state.list
                            .where((reading) =>
                                reading.layer ==
                                Constants.parametersToMonitorList[index]
                                    ['layer'])
                            .map((reading) {
                      return ChartData(
                        reading.createdAt,
                        (convertToReading(
                                Constants.parametersToMonitorList[index]
                                    ['reading_key'],
                                reading) ??
                            0),
                      );
                    }).toList()
                          ..sort((a, b) => b.x.compareTo(a.x)))
                        .sublist(0, 7);

                    return SensorReadingCard(
                      key: Key(index.toString()),
                      item: Constants.parametersToMonitorList[index],
                      readingValueList: readingList,
                    );
                  },
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _todaysReportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        Text(
          "Today's Report",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHigh
                .withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.surfaceContainer,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [Text("Hello World")],
          ),
        ),
      ],
    );
  }

  Widget _summarySection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        Text(
          "Summary",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        Column(
          spacing: 12,
          children: [
            ..._summaryItems.map((item) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 22,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.withAlpha(32),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      spacing: 2.5,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          textHeightBehavior: TextHeightBehavior(
                            applyHeightToLastDescent: false,
                            applyHeightToFirstAscent: true,
                          ),
                          "${item.value}${item.unit}",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          item.label,
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withAlpha(164),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(212),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        item.icon,
                        size: 28,
                        color: Colors.black87,
                      ),
                    )
                  ],
                ),
              );
            })
          ],
        ),
      ],
    );
  }

  void reloadWebView(WebViewController? _webViewController) {
    _webViewController?.reload();
  }
}

double? convertToReading(String sensor, SensorReading reading) {
  switch (sensor) {
    case "temperature":
      return reading.asBeddingReading?.temperature.value.toDouble();
    case "humidity":
      return reading.asBeddingReading?.humidity.value.toDouble();
    case "soil moisture":
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
