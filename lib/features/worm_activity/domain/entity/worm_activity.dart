class WormActivity {
  final int id;
  final int wormScheduleId;
  final double avgTemp;
  final double minTemp;
  final double maxTemp;
  final double thermalSpread;
  final ActivityLevel activityLevel;
  final Point? hotspot;
  final Map<String, dynamic> zones;
  final String filePath;
  final String createdAt;

  WormActivity({
    required this.id,
    required this.wormScheduleId,
    required this.avgTemp,
    required this.minTemp,
    required this.maxTemp,
    required this.thermalSpread,
    required this.activityLevel,
    this.hotspot,
    required this.zones,
    required this.filePath,
    required this.createdAt,
  });

  String getActiveZoneLabel() {
    const targetLevel = 'moderate';
    for (final entry in zones.entries) {
      final activityLevel =
          (entry.value['activity_level'] as String).toLowerCase();
      if (activityLevel == targetLevel) {
        return 'Zone ${entry.key.toUpperCase()}';
      }
    }
    return 'Zone A-D';
  }
}

class Point {
  final double x;
  final double y;

  Point(this.x, this.y);

  factory Point.fromJson(Map<String, dynamic> json) {
    return Point(
      (json['x'] as num).toDouble(),
      (json['y'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {'x': x, 'y': y};
}

enum ActivityLevel {
  low,
  moderate,
  high,
}
