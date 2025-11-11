import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/device_information_widget.dart';
import 'package:flutter_vermicomposting/mqtt_service.dart';

class SystemDeviceInformation extends StatefulWidget {
  final MqttService mqttService;

  const SystemDeviceInformation({
    super.key,
    required this.mqttService,
  });

  @override
  State<SystemDeviceInformation> createState() =>
      _SystemDeviceInformationState();
}

class _SystemDeviceInformationState extends State<SystemDeviceInformation> {
  late StreamSubscription<Map<String, String>> _deviceInfoStreamSubscription;
  Map<String, String> _deviceInfo = {};

  @override
  void initState() {
    super.initState();

    _deviceInfoStreamSubscription =
        widget.mqttService.deviceInfoStream.listen((info) {
      setState(() {
        _deviceInfo = info;
      });
    });
  }

  @override
  void dispose() {
    _deviceInfoStreamSubscription.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Device Information",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          flex: 3,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  width: 1,
                )),
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 20),
            child: SingleChildScrollView(
              child: Column(
                spacing: 16,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DeviceInformationWidget(
                    deviceInfo: _deviceInfo,
                    deviceIsActive: true,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
