import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:flutter_vermicomposting/features/main/presentation/pages/control_screen.dart';

class SensorWithDurationWidget extends StatefulWidget {
  final String label;
  final String device;
  final SensorControl sensorData;

  const SensorWithDurationWidget({
    super.key,
    required this.label,
    required this.device,
    required this.sensorData,
  });

  @override
  State<SensorWithDurationWidget> createState() =>
      _SensorWithDurationWidgetState();
}

class _SensorWithDurationWidgetState extends State<SensorWithDurationWidget> {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(widget.sensorData.icon),
                ElevatedButton(
                  onPressed: () {},
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
                      horizontal: 14,
                    ),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    ),
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    overlayColor: Colors.black87, // <-- splash color
                  ),
                  child: Center(
                    child: Row(
                      children: [
                        Icon(
                          FluentIcons.code_block_24_regular,
                          color: Theme.of(context).colorScheme.surface,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Run",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.surface,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.025,
                          ),
                        ),
                      ],
                    ),
                  ),
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
                    children: List.generate(4, (int index) => index * 3 + 1,
                            growable: false)
                        .map((item) {
                      return Padding(
                        padding:
                            EdgeInsets.fromLTRB(item == 0 ? 0 : 6, 0, 0, 0),
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
              ],
            ),
            sensorCardHeader(
              context: context,
              label: widget.label,
              device: widget.device,
            )
          ],
        ),
      ),
    );
  }
}
