import 'package:flutter/material.dart';

class ClassListItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color iconColor;
  final double iconSize;
  final double spacing;
  final TextStyle? textStyle;
  final VoidCallback? onTap;

  const ClassListItem({
    super.key,
    required this.icon,
    required this.text,
    this.iconColor = Colors.blueAccent,
    this.iconSize = 16,
    this.spacing = 8,
    this.textStyle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(
              icon,
              color: iconColor,
              size: iconSize,
            ),
            SizedBox(width: spacing),
            Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: textStyle ??
                  TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
