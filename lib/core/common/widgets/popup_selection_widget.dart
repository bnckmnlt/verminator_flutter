import 'package:flutter/material.dart';

class PopupSelectionWidget extends StatelessWidget {
  final String label;
  final PopupMenuItemSelected<int> selectedFunction;
  final List<String> popupKeys;
  final Icon? leadingIcon;
  final Icon? trailingIcon;
  final bool isElevated;

  const PopupSelectionWidget({
    super.key,
    required this.label,
    required this.selectedFunction,
    required this.popupKeys,
    this.leadingIcon,
    this.trailingIcon,
    this.isElevated = false,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      onSelected: selectedFunction,
      itemBuilder: (context) => popupKeys
          .asMap()
          .entries
          .map((entry) => PopupMenuItem(
                value: entry.key,
                child: Text(entry.value.toUpperCase()),
              ))
          .toList(),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 8),
        decoration:
            isElevated ? _elevatedStyle(context) : _outlinedStyle(context),
        child: Row(
          spacing: 8,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            if (leadingIcon != null) leadingIcon as Widget,
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            if (trailingIcon != null) trailingIcon as Widget,
          ],
        ),
      ),
    );
  }

  BoxDecoration _elevatedStyle(BuildContext context) => BoxDecoration(
        color: Colors.grey.withAlpha(32),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).colorScheme.surfaceContainer,
        ),
      );

  BoxDecoration _outlinedStyle(BuildContext context) => BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
        ),
      );
}
