import 'dart:convert';

import 'package:flutter_vermicomposting/core/utils/format_to_local_time.dart';
import 'package:flutter_vermicomposting/features/sensor_reading/domain/entity/sensor_reading.dart';

class SensorReadingModel extends SensorReading {
  SensorReadingModel({
    required super.id,
    required super.sensorScheduleId,
    required super.layer,
    required super.readings,
    required super.createdAt,
  });

  factory SensorReadingModel.fromJson(Map<String, dynamic> json) {
    return SensorReadingModel(
      id: json["id"] is int ? json["id"] : int.parse(json["id"].toString()),
      sensorScheduleId: json["sensorScheduleId"] is int
          ? json["sensorScheduleId"]
          : int.parse(json["sensorScheduleId"].toString()),
      layer: SystemLayer.values.byName(json["layer"] as String),
      readings: json["readings"] is String
          ? Map<String, dynamic>.from(jsonDecode(json["readings"]))
          : Map<String, dynamic>.from(json["readings"]),
      createdAt: formatToLocalTime(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "sensorScheduleId": sensorScheduleId,
      "layer": layer,
      "readings": readings,
      "createdAt": createdAt,
    };
  }
}
