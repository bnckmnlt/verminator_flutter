import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

class EmptyDisplayWidget extends StatelessWidget {
  final String title;
  final String description;
  final IconData? icon;
  final Function()? action;
  final String? buttonLabel;

  const EmptyDisplayWidget({
    super.key,
    required this.title,
    required this.description,
    this.icon,
    this.action,
    this.buttonLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 14,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon ?? FluentIcons.flowchart_24_regular,
          size: 48,
          color: Theme.of(context).colorScheme.onSurface.withAlpha(124),
        ),
        Column(
          spacing: 2.5,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(164),
                letterSpacing: 0.025,
                height: 1.2,
              ),
            ),
          ],
        ),
        if (action != null)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.fromLTRB(14, 8, 10, 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: action,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  buttonLabel ?? "Retry again",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    letterSpacing: 0.025,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
