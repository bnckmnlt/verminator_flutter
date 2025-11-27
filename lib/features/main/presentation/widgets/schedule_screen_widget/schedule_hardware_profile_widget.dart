import 'dart:async';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/core/common/entities/device_info_model.dart';
import 'package:flutter_vermicomposting/core/common/widgets/glassmorphism.dart';
import 'package:flutter_vermicomposting/core/utils/device_info_utils.dart';
import 'package:flutter_vermicomposting/mqtt_service.dart';
import 'package:get_it/get_it.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

class ScheduleHardwareProfileWidget extends StatefulWidget {
  final MqttService mqttService;

  const ScheduleHardwareProfileWidget({
    super.key,
    required this.mqttService,
  });

  @override
  State<ScheduleHardwareProfileWidget> createState() =>
      _ScheduleHardwareProfileWidgetState();
}

class _ScheduleHardwareProfileWidgetState
    extends State<ScheduleHardwareProfileWidget> {
  late MqttService _mqttService;
  DeviceInfoModel? _deviceInfo;
  bool _deviceIsActive = false;

  late final StreamSubscription<Map<String, dynamic>> _deviceInfoSubscription;

  @override
  void initState() {
    super.initState();
    _mqttService = GetIt.I<MqttService>();

    _deviceInfoSubscription = _mqttService.deviceInfoStream.listen((info) {
      if (!mounted) return;
      setState(() {
        _deviceIsActive = true;
        _deviceInfo = DeviceInfoModel.fromJson(info);
      });
    });
  }

  @override
  void dispose() {
    _deviceInfoSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> cpuTempStatus = parseCPUTempStatus();

    return Row(
      spacing: 32,
      children: [
        Expanded(
          flex: 1,
          child: Row(
            spacing: 24,
            children: [
              Expanded(
                child: Column(
                  spacing: 16,
                  children: [
                    DeviceInfoRow(
                      label: "Device Board",
                      value: _deviceInfo?.deviceBoard ?? "Connecting...",
                      icon: FluentIcons.developer_board_24_filled,
                      headerTextStyle: headerTextStyle,
                      statusTextStyle: statusTextStyle,
                    ),
                    Divider(),
                    DeviceInfoRow(
                      label: "Operating System",
                      value: _deviceInfo?.operatingSystem ?? "Connecting...",
                      icon: FluentIcons.app_title_24_filled,
                      headerTextStyle: headerTextStyle,
                      statusTextStyle: statusTextStyle,
                    ),
                    Divider(),
                    DeviceInfoRow(
                      label: "Device Uptime",
                      value: _deviceInfo?.deviceUptime ?? "Connecting...",
                      icon: FluentIcons.clock_24_filled,
                      headerTextStyle: headerTextStyle,
                      statusTextStyle: statusTextStyle,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            spacing: 16,
            children: [
              Expanded(
                child: Glassmorphism(
                  blur: 12,
                  opacity: 0.3,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHigh
                          .withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        width: 1.5,
                      ),
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.indigoAccent.withAlpha(28),
                          Colors.indigoAccent.withAlpha(20),
                        ],
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                      ),
                    ),
                    child: Row(
                      spacing: 24,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    "PROCESSOR",
                                    style: statusTextStyle(context)
                                        .copyWith(height: 1.25),
                                  ),
                                  Text(
                                    "Broadcom BCM2712",
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withAlpha(164),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                spacing: 8,
                                children: [
                                  _buildMetricBlock(
                                    context,
                                    label: "Utilization",
                                    value: _deviceInfo?.cpuUsage ?? "0.0%",
                                    progress: calculateCpuUsage(
                                        _deviceInfo?.cpuUsage ?? "0.0%"),
                                  ),
                                  _buildMetricBlock(
                                    context,
                                    label: "Clock Speed",
                                    value: "0 MHz",
                                    progress: 0.0,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 4.0),
                            child: Column(
                              spacing: 12,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      spacing: 12,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 5, 0, 0),
                                          child: Container(
                                            height: 12,
                                            width: 12,
                                            decoration: BoxDecoration(
                                              color: cpuTempStatus["color"],
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Text(
                                              "Temperature",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                height: 1.1,
                                              ),
                                            ),
                                            Text(
                                              cpuTempStatus["status"],
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface
                                                    .withAlpha(164),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        style: statusTextStyle(context),
                                        children: [
                                          TextSpan(
                                            text: _deviceInfo?.cpuTemperature
                                                    .replaceAll("°C", "°\n") ??
                                                "30.0°\n",
                                            style: statusTextStyle(context)
                                                .copyWith(
                                              fontSize: 32,
                                              height: 1.1,
                                            ),
                                          ),
                                          TextSpan(
                                            text: "Celsius",
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withAlpha(164),
                                              fontSize: 14,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 64,
                                  child: StepProgressIndicator(
                                    totalSteps: 15,
                                    currentStep: cpuTempStatus["current_step"],
                                    size: 64,
                                    selectedColor: cpuTempStatus["color"],
                                    unselectedColor: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHigh,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  spacing: 16,
                  children: [
                    UsageCard(
                      title: "RAM",
                      subtitle: "8GB LPDDR4X-4267 RAM",
                      usage: _deviceInfo?.memoryUsage ?? "0%",
                      progress: calculateMemoryUsage(
                          _deviceInfo?.memoryUsage ?? "0%"),
                    ),
                    UsageCard(
                      title: "STORAGE",
                      subtitle: "128GB SanDisk MMC",
                      usage: _deviceInfo?.storageUsage ?? "0GB/128GB",
                      progress: calculateStorageUsage(
                          _deviceInfo?.storageUsage ?? "0GB", "128"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  TextStyle headerTextStyle(BuildContext context) {
    return TextStyle(
      color: Theme.of(context).colorScheme.onSurface.withAlpha(164),
      fontSize: 18,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.025,
    );
  }

  TextStyle statusTextStyle(BuildContext context) {
    return TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.025,
    );
  }

  Map<String, dynamic> parseCPUTempStatus() {
    String status = "Optimal";

    double temp = double.tryParse(
          _deviceInfo?.cpuTemperature.replaceAll("°C", "") ?? "40",
        ) ??
        0;

    int maxTemp = 85;
    int totalSteps = 15;

    int currentStep =
        ((temp / maxTemp) * totalSteps).clamp(0, totalSteps).round();

    Color progressColor;
    if (temp <= 55) {
      progressColor = Colors.greenAccent;
      status = "Optimal";
    } else if (temp <= 70) {
      progressColor = Colors.orangeAccent;
      status = "Performance Load";
    } else {
      progressColor = Colors.redAccent;
      status = "Thermal Throttling";
    }

    return {
      "current_step": currentStep,
      "color": progressColor,
      "status": status,
    };
  }
}

class DeviceInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final TextStyle Function(BuildContext) headerTextStyle;
  final TextStyle Function(BuildContext) statusTextStyle;

  const DeviceInfoRow({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.headerTextStyle,
    required this.statusTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 4,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: headerTextStyle(context)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(value, style: statusTextStyle(context)),
            Icon(icon),
          ],
        ),
      ],
    );
  }
}

class UsageCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String usage;
  final double progress;

  const UsageCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.usage,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle statusTextStyle() => TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
        );

    return Expanded(
      child: Glassmorphism(
          blur: 12,
          opacity: 0.2,
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHigh
                  .withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                width: 1.5,
              ),
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.indigoAccent.withAlpha(28),
                  Colors.indigoAccent.withAlpha(20),
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 24,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: statusTextStyle().copyWith(height: 1.25)),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withAlpha(164),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      spacing: 10,
                      children: [
                        Container(
                          height: 12,
                          width: 12,
                          decoration: BoxDecoration(
                            color: Colors.greenAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const Text(
                          "Optimal",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  spacing: 6,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Usage",
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withAlpha(164),
                          ),
                        ),
                        Text(
                          usage,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    LinearProgressIndicator(
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                      color: Colors.white,
                      value: progress,
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceContainerHigh,
                    ),
                  ],
                ),
              ],
            ),
          )),
    );
  }
}

Widget _buildMetricBlock(
  BuildContext context, {
  required String label,
  required String value,
  required double progress,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withAlpha(164),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      const SizedBox(height: 6),
      LinearProgressIndicator(
        minHeight: 8,
        borderRadius: BorderRadius.circular(4),
        color: Colors.white,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        value: progress,
      ),
    ],
  );
}
