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

  double npkToPercent(double value) => (value / 1999) * 100;

  final nPercent = npkToPercent(nitrogen!);
  final pPercent = npkToPercent(phosphorus!);
  final kPercent = npkToPercent(potassium!);

  final conditions = [
    (temperature!, 15.0, 25.0),
    (humidity!, 60.0, 85.0),
    (soilMoisture!, 70.0, 85.0),
    (nPercent, 15.0, 40.0),
    (pPercent, 10.0, 30.0),
    (kPercent, 20.0, 50.0),
  ];

  final weights = [2.0, 1.5, 2.0, 1.0, 1.0, 1.0];

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
        'optimal': temperature >= 15 && temperature <= 25,
        'range': '15-25°C',
      },
      'humidity': {
        'value': humidity,
        'optimal': humidity >= 60 && humidity <= 85,
        'range': '60-85%',
      },
      'moisture': {
        'value': soilMoisture,
        'optimal': soilMoisture >= 70 && soilMoisture <= 85,
        'range': '70-85%',
      },
      'nitrogen': {
        'value': nitrogen,
        'optimal': nitrogen >= 300 && nitrogen <= 800,
        'range': '300-800 mg/kg',
      },
      'phosphorus': {
        'value': phosphorus,
        'optimal': phosphorus >= 200 && phosphorus <= 600,
        'range': '200-600 mg/kg',
      },
      'potassium': {
        'value': potassium,
        'optimal': potassium >= 400 && potassium <= 1000,
        'range': '400-1000 mg/kg',
      },
    },
  };
}
