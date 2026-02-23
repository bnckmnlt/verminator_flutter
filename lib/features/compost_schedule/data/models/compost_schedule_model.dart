import 'package:flutter_vermicomposting/core/utils/format_to_local_time.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/domain/entities/compost_schedule.dart';

class CompostScheduleModel extends CompostSchedule {
  CompostScheduleModel({
    required super.id,
    required super.scheduleName,
    super.compostProduced,
    super.juiceProduced,
    required super.isCompleted,
    super.dateReleased,
    required super.createdAt,
    required super.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scheduleName': scheduleName,
      'compostProduced': compostProduced,
      'juiceProduced': juiceProduced,
      'isCompleted': isCompleted,
      'dateReleased': dateReleased,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory CompostScheduleModel.fromJson(Map<String, dynamic> json) {
    return CompostScheduleModel(
      id: json['id'] as int,
      scheduleName: json['scheduleName'] as String,
      compostProduced: json['compostProduced']?.toString(),
      juiceProduced: json['juiceProduced']?.toString(),
      isCompleted: json['isCompleted'] as bool,
      dateReleased: json['dateReleased'] as String?,
      createdAt: formatToLocalTime(json['createdAt']),
      updatedAt: formatToLocalTime(json['updatedAt']),
    );
  }

  factory CompostScheduleModel.fromSupabaseJson(Map<String, dynamic> json) {
    return CompostScheduleModel(
      id: json['id'] as int,
      scheduleName: json['schedule_name'] as String,
      compostProduced: json['compost_produced']?.toString(),
      juiceProduced: json['juice_produced']?.toString(),
      isCompleted: json['is_completed'] as bool,
      dateReleased: json['date_released'] as String?,
      createdAt: formatToLocalTime(json['created_at']),
      updatedAt: formatToLocalTime(json['updated_at']),
    );
  }
}
