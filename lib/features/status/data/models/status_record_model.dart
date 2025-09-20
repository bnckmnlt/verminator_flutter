import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:flutter_vermicomposting/core/utils/format_to_local_time.dart';
import 'package:flutter_vermicomposting/features/status/domain/entity/status_record.dart';

class StatusRecordModel extends StatusRecord {
  StatusRecordModel({
    required super.id,
    required super.scheduleId,
    required super.status,
    required super.remarks,
    required super.isCompleted,
    required super.createdAt,
    required super.updatedAt,
  });

  factory StatusRecordModel.fromJson(Map<String, dynamic> json) {
    return StatusRecordModel(
      id: json["id"] as int,
      scheduleId: json["statusScheduleId"] as int,
      status: CompostingStatus.values.byName(json["status"] as String),
      remarks: json["remarks"] as String?,
      isCompleted: json["isCompleted"] as bool,
      createdAt: formatToLocalTime(json['createdAt']),
      updatedAt: formatToLocalTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "scheduleId": scheduleId,
      "status": status,
      "remarks": remarks,
      "isCompleted": isCompleted,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
    };
  }

  factory StatusRecordModel.fromJsonSupabase(Map<String, dynamic> json) {
    return StatusRecordModel(
      id: json["id"] as int,
      scheduleId: json["status_schedule_id"] as int,
      status: CompostingStatus.values.byName(json["status"] as String),
      remarks: json["remarks"] as String?,
      isCompleted: json["is_completed"] as bool,
      createdAt: formatToLocalTime(json['created_at']),
      updatedAt: formatToLocalTime(json['updated_at']),
    );
  }
}
