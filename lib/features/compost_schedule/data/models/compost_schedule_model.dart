import 'package:flutter_vermicomposting/features/compost_schedule/domain/entities/compost_schedule.dart';

class CompostScheduleModel extends CompostSchedule {
  CompostScheduleModel({
    required super.id,
    required super.scheduleName,
    super.compostProduced,
    super.juiceProduced,
    required super.isCompleted,
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
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory CompostScheduleModel.fromJson(Map<String, dynamic> json) {
    return CompostScheduleModel(
      id: json['id'] as int,
      scheduleName: json['scheduleName'] as String,
      compostProduced: json['compostProduced'] as String,
      juiceProduced: json['juiceProduced'] as String,
      isCompleted: json['isCompleted'] as bool,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }
}
