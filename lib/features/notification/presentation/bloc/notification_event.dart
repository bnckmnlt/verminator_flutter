part of 'notification_bloc.dart';

@immutable
sealed class NotificationEvent {}

final class NotificationList extends NotificationEvent {}

final class NotificationPatch extends NotificationEvent {
  final int id;
  final bool? read;

  NotificationPatch({
    required this.id,
    required this.read,
  });
}
