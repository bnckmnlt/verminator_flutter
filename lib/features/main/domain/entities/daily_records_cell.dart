import 'package:flutter_vermicomposting/core/constants/constants.dart';

class DailyRecordsCell {
  final String day;
  final SensorStatus condition;
  final String temperature;
  final String humidity;
  final String soilMoisture;
  final String nitrogen;
  final String phosphorus;
  final String potassium;
  final String wormActivity;

  DailyRecordsCell({
    required this.day,
    required this.condition,
    required this.temperature,
    required this.humidity,
    required this.soilMoisture,
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    required this.wormActivity,
  });
}
