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
    };
  }

  bool inRange(double value, double min, double max) =>
      value >= min && value <= max;

  final conditions = [
    inRange(temperature!, 18, 28),
    inRange(humidity!, 60, 80),
    inRange(soilMoisture!, 60, 70),
    inRange(nitrogen!, 20, 50),
    inRange(phosphorus!, 5, 15),
    inRange(potassium!, 30, 60),
  ];

  final score = conditions.where((c) => c).length;
  final percentage = (score / conditions.length) * 100;

  String status;
  Color color;

  if (percentage >= 85) {
    status = "Healthy";
    color = Colors.greenAccent;
  } else if (percentage >= 50) {
    status = "Fair";
    color = Colors.amberAccent;
  } else {
    status = "Unhealthy";
    color = Colors.redAccent;
  }

  return {
    'status': status,
    'score': double.parse(percentage.toStringAsFixed(2)),
    'color': color,
  };
}
