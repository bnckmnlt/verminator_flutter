import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:flutter_vermicomposting/core/error/exception.dart';
import 'package:flutter_vermicomposting/core/error/failure.dart';
import 'package:flutter_vermicomposting/core/network/connection_checker.dart';
import 'package:flutter_vermicomposting/features/notification/data/datasources/notification_remote_datasource.dart';
import 'package:flutter_vermicomposting/features/notification/domain/entities/notification.dart';
import 'package:flutter_vermicomposting/features/notification/domain/repositories/notification_repository.dart';
import 'package:fpdart/fpdart.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDatasource remoteDatasource;
  final ConnectionChecker connectionChecker;

  const NotificationRepositoryImpl(
    this.remoteDatasource,
    this.connectionChecker,
  );

  @override
  Future<Either<Failure, Stream<List<NotificationEntity>>>>
      listNotification() async {
    try {
      final list = remoteDatasource.listNotification();

      return right(list);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, NotificationEntity>> selectOneNotification({
    required int id,
  }) async {
    return _getNotification(
      () => remoteDatasource.selectOneNotification(id: id),
    );
  }

  @override
  Future<Either<Failure, NotificationEntity>> patchNotification({
    required int id,
    bool? read,
  }) {
    return _getNotification(
      () => remoteDatasource.patchNotification(id: id),
    );
  }

  @override
  Future<Either<Failure, String>> removeNotification({
    required int id,
  }) async {
    try {
      final response = await remoteDatasource.removeNotification(
        id: id,
      );

      return right(response);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  Future<Either<Failure, NotificationEntity>> _getNotification(
    Future<NotificationEntity> Function() fn,
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
