import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:flutter_vermicomposting/core/error/exception.dart';
import 'package:flutter_vermicomposting/core/error/failure.dart';
import 'package:flutter_vermicomposting/core/network/connection_checker.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/data/datasources/compost_schedule_remote_datasource.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/domain/entities/compost_schedule.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/domain/repositories/compost_schedule_repository.dart';
import 'package:fpdart/src/either.dart';

class CompostScheduleRepositoryImpl implements CompostScheduleRepository {
  final CompostScheduleRemoteDatasource remoteDataSource;
  final ConnectionChecker connectionChecker;

  const CompostScheduleRepositoryImpl(
    this.remoteDataSource,
    this.connectionChecker,
  );

  @override
  Future<Either<Failure, List<CompostSchedule>>> listCompostSchedule() async {
    try {
      final list = await remoteDataSource.listCompostSchedule();

      return right(list);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, CompostSchedule>> selectOneCompostSchedules({
    required int id,
  }) async {
    return _getCompostSchedule(
      () async => await remoteDataSource.selectOneCompostSchedules(
        id: id,
      ),
    );
  }

  @override
  Future<Either<Failure, CompostSchedule>> createCompostScheduleById({
    required String scheduleName,
    required String compostProduced,
    required String juiceProduced,
  }) async {
    return _getCompostSchedule(
      () async => await remoteDataSource.createCompostScheduleById(
        scheduleName: scheduleName,
        compostProduced: compostProduced,
        juiceProduced: juiceProduced,
      ),
    );
  }

  @override
  Future<Either<Failure, CompostSchedule>> patchCompostSchedule({
    required int id,
    String? scheduleName,
    String? compostProduced,
    String? juiceProduced,
    bool? isCompleted,
  }) {
    return _getCompostSchedule(
      () async => await remoteDataSource.patchCompostSchedule(
        id: id,
      ),
    );
  }

  @override
  Future<Either<Failure, String>> removeCompostSchedule({
    required int id,
  }) async {
    try {
      final response = await remoteDataSource.removeCompostSchedule(
        id: id,
      );

      return right(response);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  Future<Either<Failure, CompostSchedule>> _getCompostSchedule(
    Future<CompostSchedule> Function() fn,
  ) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }

      final compostSchedule = await fn();

      return right(compostSchedule);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
