import 'package:flutter_vermicomposting/core/common/entities/layer_classes.dart';

class SensorReading {
  final int id;
  final int sensorScheduleId;
  final SystemLayer layer;
  final Map<String, dynamic> readings;
  final String createdAt;

  SensorReading({
    required this.id,
    required this.sensorScheduleId,
    required this.layer,
    required this.readings,
    required this.createdAt,
  });

  FluidReading? get asFluidReading =>
      layer == SystemLayer.fluid ? FluidReading.fromJson(readings) : null;

  BeddingReading? get asBeddingReading =>
      layer == SystemLayer.bedding ? BeddingReading.fromJson(readings) : null;

  CompostReading? get asCompostReading =>
      layer == SystemLayer.compost ? CompostReading.fromJson(readings) : null;
}

enum SystemLayer {
  bedding,
  compost,
  fluid,
}
