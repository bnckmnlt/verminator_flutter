import 'package:flutter_vermicomposting/features/sensor_reading/domain/entity/sensor_reading.dart';

double? convertToReading(String sensor, SensorReading reading) {
  switch (sensor) {
    case "temperature":
      return reading.asBeddingReading?.temperature.value.toDouble();
    case "humidity":
      return reading.asBeddingReading?.humidity.value.toDouble();
    case "soil moisture":
      return reading.asBeddingReading?.soilMoisture.value.toDouble();
    case "nitrogen":
      return reading.asCompostReading?.npk.nitrogen.toDouble();
    case "phosphorus":
      return reading.asCompostReading?.npk.phosphorus.toDouble();
    case "potassium":
      return reading.asCompostReading?.npk.potassium.toDouble();
    default:
  }

  return 0.0;
}
