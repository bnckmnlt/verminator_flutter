import 'package:flutter_vermicomposting/core/utils/format_to_local_time.dart';
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
    required super.filePath,
    required super.createdAt,
  });

  factory WormActivityModel.fromJson(Map<String, dynamic> json) {
    return WormActivityModel(
      id: json['id'] as int,
      wormScheduleId: json['wormScheduleId'] as int,
      avgTemp: (json['avgTemp'] as num).toDouble(),
      minTemp: (json['minTemp'] as num).toDouble(),
      maxTemp: (json['maxTemp'] as num).toDouble(),
      thermalSpread: (json['thermalSpread'] as num).toDouble(),
      activityLevel:
          ActivityLevel.values.byName(json['activityLevel'] as String),
      hotspot: json['hotspot'] != null ? Point.fromJson(json['hotspot']) : null,
      zones: json['zones'] as Map<String, dynamic>,
      createdAt: formatToLocalTime(json['createdAt']),
      filePath: json['filePath'] as String,
    );
  }

  factory WormActivityModel.fromSupabaseJson(Map<String, dynamic> json) {
    return WormActivityModel(
      id: json['id'] as int,
      wormScheduleId: json['worm_schedule_id'] as int,
      avgTemp: (json['avg_temp'] as num).toDouble(),
      minTemp: (json['min_temp'] as num).toDouble(),
      maxTemp: (json['max_temp'] as num).toDouble(),
      thermalSpread: (json['thermal_spread'] as num).toDouble(),
      activityLevel:
          ActivityLevel.values.byName(json['activity_level'] as String),
      hotspot: json['hotspot'] != null ? Point.fromJson(json['hotspot']) : null,
      zones: json['zones'] as Map<String, dynamic>,
      createdAt: formatToLocalTime(json['created_at']),
      filePath: json['file_path'] as String,
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
      'filePath': filePath,
      'createdAt': createdAt,
    };
  }
}
