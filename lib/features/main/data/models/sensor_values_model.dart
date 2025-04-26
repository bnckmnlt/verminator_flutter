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

    String npkValue(Map<String, dynamic>? npkMap, String key) {
      if (npkMap != null && npkMap[key] != null) {
        return npkMap[key].toString();
      }
      return "0";
    }

    return SensorValuesModel(
      temperature: getValue(json['temperature'], 'value'),
      humidity: getValue(json['humidity'], 'value'),
      soilMoisture: getValue(json['soil_moisture'], 'value'),
      nitrogen: npkValue(json['npk'], 'nitrogen'),
      phosphorus: npkValue(json['npk'], 'phosphorus'),
      potassium: npkValue(json['npk'], 'potassium'),
      compost: getValue(json['compost_weight'], 'value'),
      vermijuice: getValue(json['juice_weight'], 'value'),
      reservoir: getValue(json['reservoir_weight'], 'value'),
    );
  }
}
