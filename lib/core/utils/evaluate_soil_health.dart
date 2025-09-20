import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

Map<String, dynamic> evaluateSoilHealth({
  required double? temperature,
  required double? humidity,
  required double? soilMoisture,
  required double? nitrogen,
  required double? phosphorus,
  required double? potassium,
}) {
  bool isValid(double? value) => value != null && value.isFinite && value >= 0;

  final allValid = [
    temperature,
    humidity,
    soilMoisture,
    nitrogen,
    phosphorus,
    potassium,
  ].every(isValid);

  if (!allValid) {
    return {
      'status': 'Unhealthy',
      'score': 0.0,
      'color': Colors.red,
      'icon': FluentIcons.warning_24_filled,
    };
  }

  bool inRange(double value, double min, double max) =>
      value >= min && value <= max;

  final conditions = [
    inRange(temperature!, 20, 28),
    inRange(humidity!, 50, 70),
    inRange(soilMoisture!, 60, 80),
    inRange(nitrogen!, 75, 100),
    inRange(phosphorus!, 75, 100),
    inRange(potassium!, 75, 100),
  ];

  final score = conditions.where((c) => c).length;
  final percentage = (score / conditions.length) * 100;

  String status;
  Color color;
  IconData iconData;

  if (percentage >= 85) {
    status = "Healthy";
    color = Colors.greenAccent;
    iconData = FluentIcons.checkmark_circle_24_filled;
  } else if (percentage >= 50) {
    status = "Fair";
    color = Colors.amberAccent;
    iconData = FluentIcons.subtract_circle_24_filled;
  } else {
    status = "Unhealthy";
    color = Colors.orangeAccent;
    iconData = FluentIcons.warning_24_filled;
  }

  return {
    'status': status,
    'score': double.parse(percentage.toStringAsFixed(2)),
    'color': color,
    'icon': iconData,
  };
}
