import 'package:flutter/material.dart';

class DataTableColumn {
  final String label;
  final IconData? icon;
  final Color? color;

  DataTableColumn({
    required this.label,
    this.icon,
    this.color,
  });
}
