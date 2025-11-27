part of 'notification_bloc.dart';

@immutable
sealed class NotificationState {
  const NotificationState();
}

final class NotificationInitial extends NotificationState {}

final class NotificationLoading extends NotificationState {}

final class NotificationFailure extends NotificationState {
  final String error;

  const NotificationFailure(this.error);
}

final class NotificationSuccess extends NotificationState {
  final NotificationEntity notificationEntity;

  const NotificationSuccess(this.notificationEntity);
}

final class NotificationListSuccess extends NotificationState {
  final List<NotificationEntity> notificationList;

  const NotificationListSuccess(this.notificationList);
}
