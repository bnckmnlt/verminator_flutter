import 'package:flutter_vermicomposting/core/error/failure.dart';
import 'package:flutter_vermicomposting/features/notification/domain/entities/notification.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class NotificationRepository {
  Future<Either<Failure, Stream<List<NotificationEntity>>>> listNotification();

  Future<Either<Failure, NotificationEntity>> selectOneNotification({
    required int id,
  });

  Future<Either<Failure, String>> removeNotification({
    required int id,
  });

  Future<Either<Failure, NotificationEntity>> patchNotification({
    required int id,
    bool read,
  });
}
