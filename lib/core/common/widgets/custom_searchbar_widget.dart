import 'package:flutter/material.dart';

class CustomSearchBarWidget {
  static SearchBar build({
    required BuildContext context,
    TextEditingController? controller,
    required String label,
    Icon? leadingIcon,
    List<Icon>? trailingIcons,
    void Function(String)? onChangedFunction,
  }) {
    return SearchBar(
      controller: controller,
      onChanged: onChangedFunction,
      hintText: label,
      keyboardType: TextInputType.text,
      backgroundColor: WidgetStatePropertyAll(Colors.transparent),
      padding: WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 16),
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          side: BorderSide(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      leading: leadingIcon,
      trailing: trailingIcons,
    );
  }
}
