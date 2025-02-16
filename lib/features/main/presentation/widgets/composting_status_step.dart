import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:flutter_vermicomposting/core/utils/string_extensions.dart';

class CompostingStatusStep extends StatelessWidget {
  final CompostingStatus status;
  final String time;
  final bool isCurrentOrPast;

  const CompostingStatusStep({
    super.key,
    required this.status,
    required this.time,
    required this.isCurrentOrPast,
  });

  @override
  Widget build(BuildContext context) {
    Color textColor = isCurrentOrPast
        ? Theme.of(context).colorScheme.onSurface
        : Theme.of(context).colorScheme.onSurface.withAlpha(124);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              isCurrentOrPast
                  ? FluentIcons.checkmark_circle_24_regular
                  : FluentIcons.arrow_sync_circle_20_regular,
              color: isCurrentOrPast
                  ? Colors.greenAccent.shade400
                  : Theme.of(context).colorScheme.onSurface.withAlpha(124),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              status == CompostingStatus.ready
                  ? "Ready to Release"
                  : status.toString().split('.').last.firstLetterUpperCase(),
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.025,
              ),
            ),
          ],
        ),
        Text(
          time,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.025,
          ),
        ),
      ],
    );
  }
}
