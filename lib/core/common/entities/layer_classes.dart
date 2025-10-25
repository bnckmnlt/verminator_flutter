class FluidReading {
  final Measure juiceWeight;
  final Measure reservoirWeight;

  FluidReading({
    required this.juiceWeight,
    required this.reservoirWeight,
  });

  factory FluidReading.fromJson(Map<String, dynamic> json) => FluidReading(
        juiceWeight: Measure.fromJson(json['juice_weight']),
        reservoirWeight: Measure.fromJson(json['reservoir_weight']),
      );
}

class BeddingReading {
  final Measure humidity;
  final Measure temperature;
  final Measure soilMoisture;

  BeddingReading({
    required this.humidity,
    required this.temperature,
    required this.soilMoisture,
  });

  factory BeddingReading.fromJson(Map<String, dynamic> json) => BeddingReading(
        humidity: Measure.fromJson(json['humidity']),
        temperature: Measure.fromJson(json['temperature']),
        soilMoisture: Measure.fromJson(json['soil_moisture']),
      );
}

class CompostReading {
  final Npk npk;
  final Measure compostWeight;

  CompostReading({
    required this.npk,
    required this.compostWeight,
  });

  factory CompostReading.fromJson(Map<String, dynamic> json) => CompostReading(
        npk: Npk.fromJson(json['npk']),
        compostWeight: Measure.fromJson(json['compost_weight']),
      );
}

class Measure {
  final String unit;
  final num value;

  Measure({required this.unit, required this.value});

  factory Measure.fromJson(Map<String, dynamic> json) => Measure(
        unit: json['unit'] as String,
        value: json['value'] as num,
      );
}

class Npk {
  final String unit;
  final num nitrogen;
  final num potassium;
  final num phosphorus;

  Npk({
    required this.unit,
    required this.nitrogen,
    required this.potassium,
    required this.phosphorus,
  });

  factory Npk.fromJson(Map<String, dynamic> json) => Npk(
        unit: json['unit'],
        nitrogen: json['nitrogen'],
        potassium: json['potassium'],
        phosphorus: json['phosphorus'],
      );
}

class Reading {
  final String date;
  final double temperature;
  final double humidity;
  final double soilMoisture;
  final double nitrogen;
  final double phosphorus;
  final double potassium;
  final String activeZone;

  Reading({
    required this.date,
    this.temperature = 0,
    this.humidity = 0,
    this.soilMoisture = 0,
    this.nitrogen = 0,
    this.phosphorus = 0,
    this.potassium = 0,
    this.activeZone = "Unknown",
  });
}
