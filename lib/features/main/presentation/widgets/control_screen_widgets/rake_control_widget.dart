import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/core/common/widgets/status_badge.dart';
import 'package:flutter_vermicomposting/features/main/presentation/pages/control_screen.dart';
import 'package:flutter_vermicomposting/mqtt_service.dart';
import 'package:mqtt_client/mqtt_client.dart';

class RakeControlWidget extends StatefulWidget {
  final MqttService mqttService;

  const RakeControlWidget({
    super.key,
    required this.mqttService,
  });

  @override
  State<RakeControlWidget> createState() => _RakeControlWidgetState();
}

class _RakeControlWidgetState extends State<RakeControlWidget> {
  final ValueNotifier<bool> _rakeStateNotifier = ValueNotifier(false);
  final ValueNotifier<int> _currentCycleNotifier = ValueNotifier(25);
  final ValueNotifier<double> _speedValueNotifier = ValueNotifier(1000);

  @override
  void initState() {
    super.initState();

    widget.mqttService.rakeFeedbackStream.listen((value) {
      _rakeStateNotifier.value = value == 'active';
    });
  }

  @override
  void dispose() {
    _rakeStateNotifier.dispose();
    _currentCycleNotifier.dispose();
    _speedValueNotifier.dispose();
    super.dispose();
  }

  void publishRakeCommand(String command) {
    widget.mqttService
        .publish("control/rake", command, qos: MqttQos.atLeastOnce);
  }

  @override
  Widget build(BuildContext context) {
    final List<RakeCommand> rakeCommands = [
      RakeCommand(
          label: "Return to Origin",
          iconData: FluentIcons.arrow_down_left_24_filled,
          onPressed: () => publishRakeCommand("Return")),
      RakeCommand(
          label: "Stop",
          iconData: FluentIcons.dismiss_24_filled,
          color: Colors.redAccent,
          onPressed: () => publishRakeCommand("Stop")),
    ];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 264,
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
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 14,
                children: [
                  _rakeCycleSection(),
                  _rakeSpeedControlSection(),
                  _rakeCommandSection(rakeCommands: rakeCommands),
                ],
              ),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: _rakeStateNotifier,
              builder: (context, rakeState, child) {
                return sensorCardHeader(
                  context: context,
                  label: "Bedding Rake",
                  device: "NEMA17 Stepper",
                  optionalWidget: StatusBadge(
                    color: rakeState ? Colors.greenAccent : Colors.redAccent,
                    state: rakeState ? "Active" : "Inactive",
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _rakeCycleSection() {
    return ValueListenableBuilder<int>(
      valueListenable: _currentCycleNotifier,
      builder: (context, currentCycle, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Number of Cycles",
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
              children: [
                Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: List.generate(4, (int index) => index * 3 + 1,
                            growable: false)
                        .map((item) {
                      return Padding(
                        padding:
                            EdgeInsets.fromLTRB(item == 0 ? 0 : 6, 0, 0, 0),
                        child: GestureDetector(
                          onTap: () {
                            _currentCycleNotifier.value = item;
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 12),
                            decoration: BoxDecoration(
                              color: item == currentCycle
                                  ? Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHigh
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: item == currentCycle
                                    ? Color(0xFF27272a)
                                    : Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHigh,
                              ),
                            ),
                            child: Text(
                              "$item",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList()),
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 6, 0),
                  child: SizedBox(
                    height: 30,
                    child: VerticalDivider(
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                      thickness: 1,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => publishRakeCommand("Process: $currentCycle"),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                    backgroundColor: Theme.of(context).colorScheme.onSurface,
                    disabledBackgroundColor:
                        const Color(0xFF27272a).withAlpha(124),
                    disabledForegroundColor:
                        Theme.of(context).colorScheme.onSurface.withAlpha(0),
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 24,
                    ),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    ),
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    overlayColor: Colors.black87,
                  ),
                  child: Text(
                    "Start Rake",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.surface,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.025,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _rakeSpeedControlSection() {
    return ValueListenableBuilder<double>(
      valueListenable: _speedValueNotifier,
      builder: (context, speedValue, child) {
        return Column(
          spacing: 6,
          children: [
            const Text(
              "Speed Control",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.025,
              ),
            ),
            SizedBox(
              height: 32,
              child: Slider(
                activeColor: Theme.of(context).colorScheme.tertiary,
                inactiveColor:
                    Theme.of(context).colorScheme.surfaceContainerHigh,
                value: speedValue,
                min: 1000,
                max: 4000,
                divisions: 4,
                onChanged: (double newValue) {
                  _speedValueNotifier.value = newValue;
                  widget.mqttService.publish(
                    "control/rake",
                    "Acceleration:$newValue",
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _rakeCommandSection({
    required List<RakeCommand> rakeCommands,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
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
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 0, 0),
              child: Row(
                children: rakeCommands.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return Padding(
                    padding: EdgeInsets.fromLTRB(index == 0 ? 0 : 8, 0, 0, 0),
                    child: OutlinedButton(
                      onPressed:
                          (item.isEnabled ?? true) ? item.onPressed : null,
                      style: OutlinedButton.styleFrom(
                        disabledBackgroundColor:
                            Color(0xFF27272a).withAlpha(124),
                        disabledForegroundColor: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withAlpha(0),
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 24,
                        ),
                        side: BorderSide(
                          color: item.color ??
                              Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHigh,
                        ),
                        foregroundColor:
                            Theme.of(context).colorScheme.onSurface,
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
            ),
          ],
        ),
      ],
    );
  }
}

class RakeCommand {
  final String label;
  final Color? color;
  final IconData? iconData;
  final bool? isEnabled;
  final VoidCallback onPressed;

  RakeCommand({
    required this.label,
    this.isEnabled,
    this.color,
    this.iconData,
    required this.onPressed,
  });
}
