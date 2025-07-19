import 'dart:async';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/core/common/widgets/status_badge.dart';
import 'package:flutter_vermicomposting/features/main/presentation/pages/control_screen.dart';
import 'package:flutter_vermicomposting/mqtt_service.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:toggle_switch/toggle_switch.dart';

// TODO: [✅] DONEEEEEE

class ConveyorControlWidget extends StatefulWidget {
  final MqttService mqttService;

  const ConveyorControlWidget({
    super.key,
    required this.mqttService,
  });

  @override
  State<ConveyorControlWidget> createState() => _ConveyorControlWidgetState();
}

class _ConveyorControlWidgetState extends State<ConveyorControlWidget> {
  late StreamSubscription<String> _conveyorFeedbackSubscription;

  late bool _conveyorState;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _conveyorState = false;

    _conveyorFeedbackSubscription =
        widget.mqttService.controlCameraStream.listen((value) {
      setState(() {
        _conveyorState = value == 'active' ? true : false;
      });
    });
  }

  void publishConveyorCommand(String command) {
    widget.mqttService
        .publish("control/conveyor", command, qos: MqttQos.atLeastOnce);
  }

  @override
  Widget build(BuildContext context) {
    final List<ConveyorCommand> conveyorCommands = [
      ConveyorCommand(
        label: "Eject",
        onPressed: () => publishConveyorCommand("Eject"),
      ),
      ConveyorCommand(
        label: "Stop",
        iconData: FluentIcons.dismiss_24_filled,
        color: Colors.redAccent,
        onPressed: () => publishConveyorCommand("Stop"),
      ),
    ];

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
            Column(
              children: [
                _conveyorModesSection(),
                const SizedBox(height: 12),
                _conveyorCommandsSection(conveyorCommands: conveyorCommands),
              ],
            ),
            sensorCardHeader(
              context: context,
              label: "Conveyor Belt",
              device: "NEMA17 Stepper",
              optionalWidget: StatusBadge(
                  color: _conveyorState ? Colors.greenAccent : Colors.redAccent,
                  state: _conveyorState ? "Active" : "Inactive"),
            )
          ],
        ),
      ),
    );
  }

  Widget _conveyorModesSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Modes",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.025,
          ),
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerLeft,
          child: ToggleSwitch(
            minHeight: 28,
            minWidth: 124,
            cornerRadius: 6,
            borderWidth: 1,
            borderColor: [Theme.of(context).colorScheme.surfaceContainerHigh],
            activeBgColors: [
              [Color(0xFF27272a).withAlpha(64)],
              [Color(0xFF27272a).withAlpha(64)],
              [Color(0xFF27272a).withAlpha(64)],
            ],
            activeFgColor: Colors.white,
            inactiveBgColor: Theme.of(context).colorScheme.surface,
            inactiveFgColor:
                Theme.of(context).colorScheme.onSurface.withAlpha(124),
            totalSwitches: 3,
            labels: const ['Continuous', 'Valid', 'Invalid'],
            icons: const [null, null, null],
            onToggle: (index) {
              if (index == 0) {
                publishConveyorCommand("Continuous");
              } else if (index == 1) {
                publishConveyorCommand("Valid");
              } else if (index == 2) {
                publishConveyorCommand("Invalid");
              }
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
              TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.025,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _conveyorCommandsSection({
    required List<ConveyorCommand> conveyorCommands,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Commands",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.025,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: conveyorCommands.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Padding(
                  padding: EdgeInsets.fromLTRB(index == 0 ? 0 : 8, 0, 0, 0),
                  child: OutlinedButton(
                    onPressed: (item.isEnabled ?? true) ? item.onPressed : null,
                    style: OutlinedButton.styleFrom(
                      disabledBackgroundColor: Color(0xFF27272a).withAlpha(124),
                      disabledForegroundColor:
                          Theme.of(context).colorScheme.onSurface.withAlpha(0),
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 24,
                      ),
                      side: BorderSide(
                        color: item.color ??
                            Theme.of(context).colorScheme.surfaceContainerHigh,
                      ),
                      foregroundColor: Theme.of(context).colorScheme.onSurface,
                      minimumSize: Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      item.label,
                      style: TextStyle(
                        color: item.color ??
                            Theme.of(context).colorScheme.onSurface,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.025,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ],
    );
  }
}

class ConveyorCommand {
  final String label;
  final Color? color;
  final IconData? iconData;
  final bool? isEnabled;
  final VoidCallback onPressed;

  ConveyorCommand({
    required this.label,
    this.isEnabled,
    this.color,
    this.iconData,
    required this.onPressed,
  });
}
