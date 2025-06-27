import 'package:flutter_vermicomposting/core/utils/format-to-local-time.dart';
import 'package:flutter_vermicomposting/features/notification/domain/entities/notification.dart';

class NotificationModel extends NotificationEntity {
  NotificationModel({
    required super.id,
    required super.notificationType,
    required super.subject,
    required super.description,
    required super.path,
    required super.read,
    required super.removed,
    required super.createdAt,
    required super.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json["id"] as int,
      notificationType:
          NotificationType.values.byName(json["notificationType"] as String),
      subject: json["subject"] as String,
      description: json["description"] as String,
      path: json["path"] as String?,
      read: json["read"] as bool,
      removed: json["removed"] as bool,
      createdAt: formatToLocalTime(json["createdAt"]),
      updatedAt: formatToLocalTime(json["updatedAt"]),
    );
  }

  factory NotificationModel.fromJsonSupabase(Map<String, dynamic> json) {
    return NotificationModel(
      id: json["id"] as int,
      notificationType:
          NotificationType.values.byName(json["notification_type"] as String),
      subject: json["subject"] as String,
      description: json["description"] as String,
      path: json["path"] as String?,
      read: json["read"] as bool,
      removed: json["removed"] as bool,
      createdAt: formatToLocalTime(json["created_at"]),
      updatedAt: formatToLocalTime(json["updated_at"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "notificationType": notificationType,
      "subject": subject,
      "description": description,
      "path": path,
      "read": read,
      "removed": removed,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
    };
  }
}
