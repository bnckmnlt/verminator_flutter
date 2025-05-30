import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:flutter_vermicomposting/core/error/exception.dart';
import 'package:flutter_vermicomposting/core/error/failure.dart';
import 'package:flutter_vermicomposting/core/network/connection_checker.dart';
import 'package:flutter_vermicomposting/features/worm_activity/data/datasources/worm_activity_remote_datasource.dart';
import 'package:flutter_vermicomposting/features/worm_activity/domain/entity/worm_activity.dart';
import 'package:flutter_vermicomposting/features/worm_activity/domain/repository/worm_activity_repository.dart';
import 'package:fpdart/fpdart.dart';

class WormActivityRepositoryImpl implements WormActivityRepository {
  final WormActivityRemoteDatasource remoteDataSource;
  final ConnectionChecker connectionChecker;

  const WormActivityRepositoryImpl(
    this.remoteDataSource,
    this.connectionChecker,
  );

  @override
  Future<Either<Failure, List<WormActivity>>> listWormActivity() async {
    try {
      final list = await remoteDataSource.listWormActivity();

      return right(list);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, WormActivity>> selectOneWormActivity({
    required int id,
  }) async {
    return _getCompostSchedule(
      () async => await remoteDataSource.selectOneWormActivity(
        id: id,
      ),
    );
  }

  Future<Either<Failure, WormActivity>> _getCompostSchedule(
    Future<WormActivity> Function() fn,
  ) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }

      final wormActivity = await fn();

      return right(wormActivity);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
