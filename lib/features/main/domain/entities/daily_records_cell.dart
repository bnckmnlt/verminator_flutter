class DailyRecordsCell {
  final String day;
  final String temperature;
  final String minTemp;
  final String maxTemp;
  final String humidity;
  final String minHumidity;
  final String maxHumidity;
  final String soilMoisture;
  final String minSoilMoisture;
  final String maxSoilMoisture;
  final String nitrogen;
  final String phosphorus;
  final String potassium;
  final String wormActivity;

  DailyRecordsCell({
    required this.day,
    required this.temperature,
    required this.minTemp,
    required this.maxTemp,
    required this.humidity,
    required this.minHumidity,
    required this.maxHumidity,
    required this.soilMoisture,
    required this.minSoilMoisture,
    required this.maxSoilMoisture,
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    required this.wormActivity,
  });

  Map<String, dynamic> toJson() {
    return {
      "day": this.day,
      "temperature": this.temperature,
      "minTemp": this.minTemp,
      "maxTemp": this.maxTemp,
      "humidity": this.humidity,
      "minHumidity": this.minHumidity,
      "maxHumidity": this.maxHumidity,
      "soilMoisture": this.soilMoisture,
      "minSoilMoisture": this.minSoilMoisture,
      "maxSoilMoisture": this.maxSoilMoisture,
      "nitrogen": this.nitrogen,
      "phosphorus": this.phosphorus,
      "potassium": this.potassium,
      "wormActivity": this.wormActivity,
    };
  }
}
