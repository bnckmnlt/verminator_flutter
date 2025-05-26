import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/features/main/presentation/pages/control_screen.dart';
import 'package:toggle_switch/toggle_switch.dart';

class ConveyorControlWidget extends StatefulWidget {
  const ConveyorControlWidget({super.key});

  @override
  State<ConveyorControlWidget> createState() => _ConveyorControlWidgetState();
}

class _ConveyorControlWidgetState extends State<ConveyorControlWidget> {
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
            Column(
              children: [
                _conveyorModesSection(),
                const SizedBox(height: 12),
                _conveyorCommandsSection(),
              ],
            ),
            sensorCardHeader(
                context: context,
                label: "Conveyor Belt",
                device: "NEMA17 Stepper",
                optionalWidget: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 2.5, horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 6,
                        width: 6,
                        decoration: BoxDecoration(
                          color: Colors.greenAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Active",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.025,
                        ),
                      )
                    ],
                  ),
                ))
          ],
        ),
      ),
    );
  }

  Widget _conveyorModesSection() {
    return Column(
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
        ToggleSwitch(
          minHeight: 28,
          minWidth: 112,
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
            print('switched to: $index');
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
      ],
    );
  }

  Widget _conveyorCommandsSection() {
    final List<ConveyorCommand> conveyorCommands = [
      ConveyorCommand(label: "Eject", onPressed: () {}),
      // ConveyorCommand(
      //     label: "Return to Origin",
      //     iconData: FluentIcons.arrow_down_left_24_filled,
      //     isEnabled: false,
      //     onPressed: () {}),
      ConveyorCommand(
          label: "Stop",
          iconData: FluentIcons.dismiss_24_filled,
          color: Colors.redAccent,
          onPressed: () {}),
    ];

    return Row(
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
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 0, 0),
              child: Row(
                children: conveyorCommands.asMap().entries.map((entry) {
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
