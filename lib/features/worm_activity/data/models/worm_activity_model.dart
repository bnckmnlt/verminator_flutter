import 'package:flutter_vermicomposting/core/utils/format-to-local-time.dart';
import 'package:flutter_vermicomposting/features/worm_activity/domain/entity/worm_activity.dart';

class WormActivityModel extends WormActivity {
  WormActivityModel({
    required super.id,
    required super.wormScheduleId,
    required super.avgTemp,
    required super.minTemp,
    required super.maxTemp,
    required super.thermalSpread,
    required super.activityLevel,
    required super.hotspot,
    required super.zones,
    required super.createdAt,
  });

  factory WormActivityModel.fromJson(Map<String, dynamic> json) {
    return WormActivityModel(
      id: json['id'] as int,
      wormScheduleId: json['wormScheduleId'] as int,
      avgTemp: (json['avgTemp'] as num).toDouble(),
      minTemp: (json['minTemp'] as num).toDouble(),
      maxTemp: (json['maxTemp'] as num).toDouble(),
      thermalSpread: json['thermalSpread'] as double,
      activityLevel:
          ActivityLevel.values.byName(json['activityLevel'] as String),
      hotspot: json['hotspot'] != null ? Point.fromJson(json['hotspot']) : null,
      zones: json['zones'] as Map<String, dynamic>,
      createdAt: formatToLocalTime(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'wormScheduleId': wormScheduleId,
      'avgTemp': avgTemp,
      'minTemp': minTemp,
      'maxTemp': maxTemp,
      'thermalSpread': thermalSpread,
      'activityLevel': activityLevel,
      'hotspot': hotspot?.toJson(),
      'zones': zones,
      'createdAt': createdAt,
    };
  }
}
