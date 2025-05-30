import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/core/common/widgets/status_badge.dart';
import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:flutter_vermicomposting/features/main/presentation/pages/control_screen.dart';
import 'package:flutter_vermicomposting/mqtt_service.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:rxdart/rxdart.dart';
import 'package:toggle_switch/toggle_switch.dart';

// TODO: [✅] DONEEEE

class SensorWithDurationWidget extends StatefulWidget {
  final String label;
  final String device;
  final SensorControl sensorData;
  final MqttService mqttService;
  final String topic;

  const SensorWithDurationWidget({
    super.key,
    required this.label,
    required this.device,
    required this.sensorData,
    required this.mqttService,
    required this.topic,
  });

  @override
  State<SensorWithDurationWidget> createState() =>
      _SensorWithDurationWidgetState();
}

class _SensorWithDurationWidgetState extends State<SensorWithDurationWidget> {
  late StreamSubscription<bool> _stateSub;
  int _currentDuration = 0;
  int _toggleState = 1;
  int _currentState = 1;

  @override
  void initState() {
    super.initState();
    _stateSub = getTopicState(widget.mqttService, widget.topic).listen((on) {
      setState(() {
        _currentState = on ? 0 : 1;
      });
    });
  }

  @override
  void dispose() {
    _stateSub.cancel();
    super.dispose();
  }

  void publishTurnOnCommand() {
    widget.mqttService.publish(widget.topic,
        "1:${_currentDuration == 15 ? "indefinite" : _currentDuration}",
        qos: MqttQos.atLeastOnce);
  }

  void publishTurnOffCommand() {
    widget.mqttService.publish(widget.topic,
        "0:${_currentDuration == 15 ? "indefinite" : _currentDuration}",
        qos: MqttQos.atLeastOnce);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                Icon(widget.sensorData.icon),
                ToggleSwitch(
                  minHeight: 28,
                  minWidth: 44,
                  cornerRadius: 4,
                  borderWidth: 1,
                  borderColor: [
                    Theme.of(context).colorScheme.surfaceContainerHigh
                  ],
                  activeBgColors: [
                    [Color(0xFF27272a).withAlpha(64)],
                    [Color(0xFF27272a).withAlpha(64)],
                  ],
                  activeFgColor: Colors.white,
                  inactiveBgColor: Theme.of(context).colorScheme.surface,
                  inactiveFgColor:
                      Theme.of(context).colorScheme.onSurface.withAlpha(124),
                  totalSwitches: 2,
                  labels: const ['ON', 'OFF'],
                  initialLabelIndex: _toggleState ?? 0,
                  onToggle: (index) {
                    setState(() {
                      _toggleState = index!;
                    });
                  },
                  customTextStyles: const [
                    TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.025,
                    ),
                    TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.025,
                    ),
                  ],
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Select Duration",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.025,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [0, 1, 3, 7, 10, 15].map((item) {
                      return Padding(
                        padding:
                            EdgeInsets.fromLTRB(item == 0 ? 0 : 6, 0, 0, 0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _currentDuration = item;

                              if (_toggleState == 0) {
                                publishTurnOnCommand();
                              } else {
                                publishTurnOffCommand();
                              }
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: item == 0 ? 6 : 4, horizontal: 12),
                            decoration: BoxDecoration(
                              color: item == _currentDuration
                                  ? Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHigh
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: item == _currentDuration
                                    ? Color(0xFF27272a)
                                    : Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHigh,
                              ),
                            ),
                            child: Text(
                              "${item == 0 ? "Default" : item == 15 ? "∞" : item}",
                              style: TextStyle(
                                fontSize: item == 0 ? 12 : 14,
                                fontWeight: item == 0
                                    ? FontWeight.w500
                                    : FontWeight.w600,
                                letterSpacing: 0.025,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList()),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                sensorCardHeader(
                  context: context,
                  label: widget.label,
                  device: widget.device,
                ),
                StatusBadge(
                  color: _currentState == 0
                      ? Colors.greenAccent
                      : Colors.redAccent,
                  state: _currentState == 0 ? "Active" : "Inactive",
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Stream<bool> getTopicState(MqttService mqttService, String topic) {
    final pins = Constants().topicPinMapping[topic];
    if (pins == null) {
      return Stream.value(false);
    }

    final pinStreams = pins
        .map((bp) => mqttService
            .getRelayPinState(bp[0], bp[1])
            .map((state) => state.toString() == '1'))
        .toList();

    return Rx.combineLatestList<bool>(pinStreams)
        .map((pinStates) => pinStates.every((s) => s));
  }
}
