class NotificationEntity {
  final int id;
  final NotificationType notificationType;
  final String subject;
  final String description;
  final String? path;
  final bool read;
  final bool removed;
  final String createdAt;
  final String updatedAt;

  NotificationEntity({
    required this.id,
    required this.notificationType,
    required this.subject,
    required this.description,
    this.path,
    required this.read,
    required this.removed,
    required this.createdAt,
    required this.updatedAt,
  });
}

enum NotificationType {
  completion,
  added,
  feeding,
  error,
  activity,
}
