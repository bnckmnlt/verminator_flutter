import 'dart:async';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:flutter_vermicomposting/features/main/presentation/pages/control_screen.dart';
import 'package:flutter_vermicomposting/main.dart';
import 'package:flutter_vermicomposting/mqtt_service.dart';
import 'package:mqtt_client/mqtt_client.dart';

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
  final ValueNotifier<bool> _pumpControlStateNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _vermijuiceControlStateNotifier =
      ValueNotifier(false);

  StreamSubscription? _pumpSub;
  StreamSubscription? _vermiSub;

  @override
  void initState() {
    super.initState();

    _pumpSub =
        widget.mqttService.getRelayPinState(0, 2).listen((dynamic state) {
      final newState = (state.toString() == "1");
      _pumpControlStateNotifier.value = newState;
      log.info(newState);
    });

    _vermiSub =
        widget.mqttService.getRelayPinState(0, 3).listen((dynamic state) {
      final newState = (state.toString() == "1");
      _vermijuiceControlStateNotifier.value = newState;
      log.info(newState);
    });
  }

  @override
  void dispose() {
    _pumpSub?.cancel();
    _vermiSub?.cancel();
    _pumpControlStateNotifier.dispose();
    _vermijuiceControlStateNotifier.dispose();
    super.dispose();
  }

  void togglePumpState(String topic, bool value) {
    widget.mqttService
        .publish(topic, value ? "1" : "0", qos: MqttQos.atLeastOnce);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ValueListenableBuilder<bool>(
            valueListenable: _pumpControlStateNotifier,
            builder: (context, pumpState, child) {
              return _buildPumpControlCard(
                context: context,
                control: SensorControl(
                  device: "12V Pump",
                  label: "Bedding Hydration",
                  icon: Icons.water_drop_outlined,
                  state: pumpState,
                  topic: "control/pump",
                ),
              );
            },
          ),
        ),
        Expanded(
          child: ValueListenableBuilder<bool>(
            valueListenable: _vermijuiceControlStateNotifier,
            builder: (context, vermijuiceState, child) {
              return _buildPumpControlCard(
                context: context,
                control: SensorControl(
                  device: "12V Pump",
                  label: "Vermitea Dispenser",
                  icon: FluentIcons.drink_bottle_20_regular,
                  state: vermijuiceState,
                  topic: "control/vermitea",
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPumpControlCard({
    required BuildContext context,
    required SensorControl control,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 284,
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
                Icon(control.icon),
                SizedBox(
                  height: 24,
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: Switch(
                      value: control.state,
                      onChanged: (bool value) =>
                          togglePumpState(control.topic, value),
                    ),
                  ),
                ),
              ],
            ),
            sensorCardHeader(
              context: context,
              label: control.label,
              device: control.device,
            ),
          ],
        ),
      ),
    );
  }
}
