import 'package:flutter_vermicomposting/core/error/exception.dart';
import 'package:flutter_vermicomposting/core/error/failure.dart';
import 'package:flutter_vermicomposting/core/network/connection_checker.dart';
import 'package:flutter_vermicomposting/features/sensor_reading/data/datasources/sensor_reading_datasource.dart';
import 'package:flutter_vermicomposting/features/sensor_reading/domain/entity/sensor_reading.dart';
import 'package:flutter_vermicomposting/features/sensor_reading/domain/repositories/sensor_reading_repository.dart';
import 'package:fpdart/fpdart.dart';

class SensorReadingRepositoryImpl implements SensorReadingRepository {
  final SensorReadingRemoteDatasource remoteDatasource;
  final ConnectionChecker connectionChecker;

  const SensorReadingRepositoryImpl(
    this.remoteDatasource,
    this.connectionChecker,
  );

  @override
  Future<Either<Failure, List<SensorReading>>> listSensorReading() async {
    try {
      final list = await remoteDatasource.listSensorReading();

      return right(list);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
