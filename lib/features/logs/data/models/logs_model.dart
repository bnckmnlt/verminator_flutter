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
      "id": this.id,
      "eventSeverity": this.logSeverity,
      "eventMessage": this.message,
      "createdAt": this.createdAt,
    };
  }

  factory LogModel.fromJson(Map<String, dynamic> json) {
    return LogModel(
      id: json["id"] as int,
      logSeverity: LogSeverity.values.byName(json["eventSeverity"] as String),
      message: json["eventMessage"],
      createdAt: json["createdAt"],
    );
  }
}
