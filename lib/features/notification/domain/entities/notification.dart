class NotificationEntity {
  final int id;
  final int scheduleId;
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
    required this.scheduleId,
    required this.notificationType,
    required this.subject,
    required this.description,
    this.path,
    required this.read,
    required this.removed,
    required this.createdAt,
    required this.updatedAt,
  });

  NotificationEntity copyWith({
    int? id,
    int? scheduleId,
    NotificationType? notificationType,
    String? subject,
    String? description,
    String? path,
    bool? read,
    bool? removed,
    String? createdAt,
    String? updatedAt,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      scheduleId: scheduleId ?? this.scheduleId,
      notificationType: notificationType ?? this.notificationType,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      path: path ?? this.path,
      read: read ?? this.read,
      removed: removed ?? this.removed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum NotificationType {
  completion,
  added,
  feeding,
  error,
  activity,
}
