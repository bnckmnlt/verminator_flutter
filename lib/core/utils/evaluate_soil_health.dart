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
  final values = [
    temperature,
    humidity,
    soilMoisture,
    nitrogen,
    phosphorus,
    potassium
  ];
  if (values.any((v) => v == null || !v.isFinite || v < 0)) {
    return {
      'status': 'Unhealthy',
      'score': 0.0,
      'color': Colors.red,
      'icon': FluentIcons.warning_24_filled,
    };
  }

  final conditions = [
    (temperature!, 25.0, 30.0),
    (humidity!, 70.0, 90.0),
    (soilMoisture!, 60.0, 80.0),
    (nitrogen!, 1.0, 5.0),
    (phosphorus!, 5.0, 10.0),
    (potassium!, 5.0, 10.0),
  ];

  final weights = [2.5, 2.0, 3.0, 1.0, 1.0, 1.0];

  double weightedScore = 0;
  double totalWeight = 0;

  for (int i = 0; i < conditions.length; i++) {
    final (value, min, max) = conditions[i];
    final inRange = value >= min && value <= max;
    weightedScore += inRange ? weights[i] : 0;
    totalWeight += weights[i];
  }

  final percentage = (weightedScore / totalWeight) * 100;

  final (status, color, icon) = switch (percentage) {
    >= 80 => ('Optimal', Colors.green, FluentIcons.checkmark_circle_24_filled),
    >= 60 => (
        'Good',
        Colors.lightGreen,
        FluentIcons.checkmark_circle_24_regular
      ),
    >= 40 => ('Fair', Colors.amber, FluentIcons.warning_24_regular),
    >= 20 => ('Poor', Colors.orange, FluentIcons.warning_24_filled),
    _ => ('Critical', Colors.red, FluentIcons.error_circle_24_filled),
  };

  return {
    'status': status,
    'score': percentage.roundToDouble(),
    'color': color,
    'icon': icon,
    'details': {
      'temperature': {
        'value': temperature,
        'optimal': temperature >= 25 && temperature <= 30,
        'range': '25-30°C',
      },
      'humidity': {
        'value': humidity,
        'optimal': humidity >= 70 && humidity <= 90,
        'range': '70-90%',
      },
      'moisture': {
        'value': soilMoisture,
        'optimal': soilMoisture >= 60 && soilMoisture <= 80,
        'range': '60-80%',
      },
      'nitrogen': {
        'value': nitrogen,
        'optimal': nitrogen >= 1.0 && nitrogen <= 5.0,
        'range': '1.0-5.0%',
      },
      'phosphorus': {
        'value': phosphorus,
        'optimal': phosphorus >= 5.0 && phosphorus <= 10.0,
        'range': '5.0-10.0%',
      },
      'potassium': {
        'value': potassium,
        'optimal': potassium >= 5.0 && potassium <= 10.0,
        'range': '5.0-10.0%',
      },
    },
  };
}
