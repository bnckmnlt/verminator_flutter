import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: Icon(
          FluentIcons.arrow_left_24_filled,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
    );
  }
}
