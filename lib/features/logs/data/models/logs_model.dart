import 'package:flutter_vermicomposting/core/utils/format_to_local_time.dart';
import 'package:flutter_vermicomposting/features/logs/domain/entity/log_entity.dart';

class LogModel extends LogEntity {
  LogModel({
    required super.id,
    required super.logSeverity,
    required super.message,
    required super.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "eventSeverity": logSeverity,
      "eventMessage": message,
      "createdAt": createdAt,
    };
  }

  factory LogModel.fromJson(Map<String, dynamic> json) {
    return LogModel(
      id: json["id"] as int,
      logSeverity: LogSeverity.values.byName(json["eventSeverity"] as String),
      message: json["eventMessage"],
      createdAt: formatToLocalTime(json['createdAt']),
    );
  }

  factory LogModel.fromSupabaseJson(Map<String, dynamic> json) {
    return LogModel(
      id: json["id"] as int,
      logSeverity: LogSeverity.values.byName(json["log_severity"] as String),
      message: json["event_message"],
      createdAt: formatToLocalTime(json['created_at']),
    );
  }
}
