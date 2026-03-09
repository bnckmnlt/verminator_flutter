import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/core/common/widgets/status_badge.dart';
import 'package:flutter_vermicomposting/features/main/presentation/pages/control_screen.dart';
import 'package:flutter_vermicomposting/mqtt_service.dart';
import 'package:mqtt_client/mqtt_client.dart';

class SifterControlWidget extends StatefulWidget {
  final MqttService mqttService;

  const SifterControlWidget({
    super.key,
    required this.mqttService,
  });

  @override
  State<SifterControlWidget> createState() => _SifterControlWidgetState();
}

class _SifterControlWidgetState extends State<SifterControlWidget> {
  final ValueNotifier<bool> _sifterStateNotifier = ValueNotifier(false);
  final ValueNotifier<int> _currentCycleNotifier = ValueNotifier(25);
  final ValueNotifier<double> _speedValueNotifier = ValueNotifier(500);

  @override
  void initState() {
    super.initState();

    widget.mqttService.sifterFeedbackStream.listen((value) {
      _sifterStateNotifier.value = value == 'active';
    });
  }

  @override
  void dispose() {
    _sifterStateNotifier.dispose();
    _currentCycleNotifier.dispose();
    _speedValueNotifier.dispose();
    super.dispose();
  }

  void publishsifterCommand(String command) {
    widget.mqttService
        .publish("control/sifter", command, qos: MqttQos.atLeastOnce);
  }

  @override
  Widget build(BuildContext context) {
    final List<SifterCommand> sifterCommands = [
      SifterCommand(
          label: "Return to Origin",
          iconData: FluentIcons.arrow_down_left_24_filled,
          onPressed: () => publishsifterCommand("Return")),
      SifterCommand(
          label: "Stop",
          iconData: FluentIcons.dismiss_24_filled,
          color: Colors.redAccent,
          onPressed: () => publishsifterCommand("Stop")),
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
                  _sifterCycleSection(),
                  _sifterSpeedControlSection(),
                  _sifterCommandSection(sifterCommands: sifterCommands),
                ],
              ),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: _sifterStateNotifier,
              builder: (context, sifterState, child) {
                return sensorCardHeader(
                  context: context,
                  label: "Soil Sifter",
                  device: "NEMA17 Stepper",
                  optionalWidget: StatusBadge(
                    color: sifterState ? Colors.greenAccent : Colors.redAccent,
                    state: sifterState ? "Active" : "Inactive",
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _sifterCycleSection() {
    return ValueListenableBuilder<int>(
      valueListenable: _currentCycleNotifier,
      builder: (context, currentCycle, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
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
                    children: [5, 8, 10, 15, 20].map((item) {
                      return Padding(
                        padding:
                            EdgeInsets.fromLTRB(item == 5 ? 0 : 6, 0, 0, 0),
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
                  onPressed: () =>
                      publishsifterCommand("Process: $currentCycle"),
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
                    "Start Sifter",
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

  Widget _sifterSpeedControlSection() {
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
                min: 500,
                max: 2500,
                divisions: 5,
                onChanged: (double newValue) {
                  _speedValueNotifier.value = newValue;
                  widget.mqttService.publish(
                    "control/sifter",
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

  Widget _sifterCommandSection({
    required List<SifterCommand> sifterCommands,
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: sifterCommands.asMap().entries.map((entry) {
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

class SifterCommand {
  final String label;
  final Color? color;
  final IconData? iconData;
  final bool? isEnabled;
  final VoidCallback onPressed;

  SifterCommand({
    required this.label,
    this.isEnabled,
    this.color,
    this.iconData,
    required this.onPressed,
  });
}
