import 'package:flutter_vermicomposting/core/error/failure.dart';
import 'package:flutter_vermicomposting/core/usecase/usecase.dart';
import 'package:flutter_vermicomposting/features/notification/domain/entities/notification.dart';
import 'package:flutter_vermicomposting/features/notification/domain/repositories/notification_repository.dart';
import 'package:fpdart/fpdart.dart';

class ListNotification
    implements UseCase<Stream<List<NotificationEntity>>, NoParams> {
  final NotificationRepository notificationRepository;

  const ListNotification(this.notificationRepository);

  @override
  Future<Either<Failure, Stream<List<NotificationEntity>>>> call(
      NoParams params) async {
    return await notificationRepository.listNotification();
  }
}
