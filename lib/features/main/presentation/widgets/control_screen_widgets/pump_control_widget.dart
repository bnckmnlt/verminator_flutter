import 'dart:async';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:flutter_vermicomposting/features/main/presentation/pages/control_screen.dart';
import 'package:flutter_vermicomposting/main.dart';
import 'package:flutter_vermicomposting/mqtt_service.dart';
import 'package:mqtt_client/mqtt_client.dart';

// TODO: [✅] DONEEEEE

class PumpControlWidget extends StatefulWidget {
  final MqttService mqttService;

  const PumpControlWidget({
    super.key,
    required this.mqttService,
  });

  @override
  State<PumpControlWidget> createState() => _PumpControlWidgetState();
}

class _PumpControlWidgetState extends State<PumpControlWidget> {
  bool pumpControlState = false;
  bool vermijuiceControlState = false;

  StreamSubscription? _pumpSub;
  StreamSubscription? _vermiSub;

  @override
  void initState() {
    super.initState();

    _pumpSub =
        widget.mqttService.getRelayPinState(0, 2).listen((dynamic state) {
      final newState = (state.toString() == "1");
      setState(() {
        pumpControlState = newState;
        log.info(newState);
      });
    });

    _vermiSub =
        widget.mqttService.getRelayPinState(0, 3).listen((dynamic state) {
      final newState = (state.toString() == "1");
      setState(() {
        vermijuiceControlState = newState;
        log.info(newState);
      });
    });
  }

  @override
  void dispose() {
    _pumpSub?.cancel();
    _vermiSub?.cancel();
    super.dispose();
  }

  void togglePumpState(String topic, bool value) {
    widget.mqttService
        .publish(topic, value ? "1" : "0", qos: MqttQos.atLeastOnce);
  }

  @override
  Widget build(BuildContext context) {
    final pumpControlList = [
      SensorControl(
        device: "Pump",
        label: "Bedding Hydration",
        icon: Icons.water_drop_outlined,
        state: pumpControlState,
        topic: "control/pump",
      ),
      SensorControl(
        device: "Pump",
        label: "Vermijuice Dispenser",
        icon: FluentIcons.drink_bottle_20_regular,
        state: vermijuiceControlState,
        topic: "control/vermijuice",
      ),
    ];

    return Row(
      children: pumpControlList.asMap().entries.map((entry) {
        final i = entry.key;
        final item = entry.value;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 214,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  width: 1,
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(item.icon),
                      SizedBox(
                        height: 24,
                        child: FittedBox(
                          fit: BoxFit.fill,
                          child: Switch(
                            value: item.state,
                            onChanged: (bool value) =>
                                togglePumpState(item.topic, value),
                          ),
                        ),
                      ),
                    ],
                  ),
                  sensorCardHeader(
                    context: context,
                    label: item.label,
                    device: item.device,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
