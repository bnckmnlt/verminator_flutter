import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/features/main/presentation/pages/control_screen.dart';

class RakeControlWidget extends StatefulWidget {
  const RakeControlWidget({super.key});

  @override
  State<RakeControlWidget> createState() => _RakeControlWidgetState();
}

class _RakeControlWidgetState extends State<RakeControlWidget> {
  int _currentDuration = 1;

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _rakeCycleSection(),
                const SizedBox(height: 12),
                _rakeCommandSection(),
              ],
            ),
            sensorCardHeader(
                context: context,
                label: "Bedding Rake",
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

  Widget _rakeCycleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: List.generate(4, (int index) => index * 3 + 1,
                        growable: false)
                    .map((item) {
                  return Padding(
                    padding: EdgeInsets.fromLTRB(item == 0 ? 0 : 6, 0, 0, 0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentDuration = item;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 12),
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
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6)),
                backgroundColor: Theme.of(context).colorScheme.onSurface,
                disabledBackgroundColor: const Color(0xFF27272a).withAlpha(124),
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
                overlayColor: Colors.black87, // <-- splash color
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
  }

  Widget _rakeCommandSection() {
    final List<RakeCommand> rakeCommands = [
      RakeCommand(
          label: "Return to Origin",
          iconData: FluentIcons.arrow_down_left_24_filled,
          onPressed: () {}),
      RakeCommand(
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
