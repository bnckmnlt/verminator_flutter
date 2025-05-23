import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class StatusCardWidget extends StatelessWidget {
  final String iconSrc;
  final String title;
  final String message;
  final String buttonLabel;
  final Color? buttonColor;
  final IconData buttonIcon;
  final VoidCallback? buttonBehavior;
  final double deviceHeight;

  const StatusCardWidget({
    super.key,
    required this.iconSrc,
    required this.title,
    required this.message,
    required this.buttonLabel,
    this.buttonColor,
    this.buttonIcon = FluentIcons.chevron_right_24_filled,
    this.buttonBehavior,
    required this.deviceHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(8),
        ),
        border: Border.all(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            iconSrc,
            repeat: false,
            height: deviceHeight * 0.25,
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.025,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withAlpha(124),
              letterSpacing: 0.025,
            ),
          ),
          const SizedBox(height: 36),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.fromLTRB(14, 8, 10, 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: buttonBehavior,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  buttonLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    letterSpacing: 0.025,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  buttonIcon,
                  color: Colors.white,
                  size: 14,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
