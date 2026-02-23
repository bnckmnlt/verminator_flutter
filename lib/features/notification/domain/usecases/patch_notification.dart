import 'package:flutter_vermicomposting/core/error/failure.dart';
import 'package:flutter_vermicomposting/core/usecase/usecase.dart';
import 'package:flutter_vermicomposting/features/notification/domain/entities/notification.dart';
import 'package:flutter_vermicomposting/features/notification/domain/repositories/notification_repository.dart';
import 'package:fpdart/fpdart.dart';

class PatchNotification
    implements UseCase<NotificationEntity, PatchNotificationParams> {
  final NotificationRepository notificationRepository;

  const PatchNotification(this.notificationRepository);

  @override
  Future<Either<Failure, NotificationEntity>> call(
      PatchNotificationParams params) async {
    return await notificationRepository.patchNotification(
      id: params.id,
    );
  }
}

class PatchNotificationParams {
  final int id;
  final bool? read;

  PatchNotificationParams({
    required this.id,
    required this.read,
  });
}
