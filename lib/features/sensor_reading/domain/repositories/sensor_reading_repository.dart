import 'package:flutter_vermicomposting/core/error/failure.dart';
import 'package:flutter_vermicomposting/features/sensor_reading/domain/entity/sensor_reading.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class SensorReadingRepository {
  Future<Either<Failure, List<SensorReading>>> listSensorReading();
}
