import 'package:flutter_vermicomposting/features/main/domain/entities/sensor_values.dart';

class SensorValuesModel extends SensorValues {
  SensorValuesModel({
    super.temperature,
    super.humidity,
    super.soilMoisture,
    super.nitrogen,
    super.phosphorus,
    super.potassium,
    super.compost,
    super.vermijuice,
    super.reservoir,
  });

  factory SensorValuesModel.fromJson(Map<String, dynamic> json) {
    String? getValue(Map<String, dynamic>? map, String key) =>
        map != null && map[key] != null ? map[key].toString() : null;

    return SensorValuesModel(
      temperature: getValue(json['temperature'], 'value'),
      humidity: getValue(json['humidity'], 'value'),
      soilMoisture: getValue(json['soil_moisture'], 'value'),
      nitrogen: getValue(json['npk'], 'nitrogen'),
      phosphorus: getValue(json['npk'], 'phosphorus'),
      potassium: getValue(json['npk'], 'potassium'),
      compost: getValue(json['compost_weight'], 'value'),
      vermijuice: getValue(json['juice_weight'], 'value'),
      reservoir: getValue(json['reservoir_weight'], 'value'),
    );
  }
}
