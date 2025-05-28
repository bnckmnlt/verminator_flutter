import 'package:flutter_vermicomposting/core/error/failure.dart';
import 'package:flutter_vermicomposting/core/usecase/usecase.dart';
import 'package:flutter_vermicomposting/features/sensor_reading/domain/entity/sensor_reading.dart';
import 'package:flutter_vermicomposting/features/sensor_reading/domain/repositories/sensor_reading_repository.dart';
import 'package:fpdart/fpdart.dart';

class ListSensorReading implements UseCase<List<SensorReading>, NoParams> {
  final SensorReadingRepository repository;

  const ListSensorReading(this.repository);

  @override
  Future<Either<Failure, List<SensorReading>>> call(NoParams params) async {
    return await repository.listSensorReading();
  }
}
