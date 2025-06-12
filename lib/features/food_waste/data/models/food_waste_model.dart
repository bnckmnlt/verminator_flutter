import 'package:flutter_vermicomposting/features/food_waste/domain/entities/food_waste.dart';

class FoodWasteModel extends FoodWaste {
  FoodWasteModel({
    required super.id,
    required super.foodWasteScheduleId,
    required super.filePath,
    required super.materialStatus,
    required super.confidence,
    required super.classname,
    required super.createdAt,
  });

  factory FoodWasteModel.fromJson(Map<String, dynamic> json) {
    return FoodWasteModel(
      id: json['id'] as int,
      foodWasteScheduleId: json['foodWasteScheduleId'] as int,
      filePath: json['filePath'] as String,
      materialStatus:
          MaterialStatus.values.byName(json['materialStatus'] as String),
      confidence: json['confidence'].toDouble() ?? 0.0,
      classname: FoodWasteClassname.values.byName(json['classname'] as String),
      createdAt: json['createdAt'] as String,
    );
  }

  factory FoodWasteModel.fromJsonRealtime(Map<String, dynamic> json) {
    return FoodWasteModel(
      id: json['id'] as int,
      foodWasteScheduleId: json['food_waste_schedule_id'] as int,
      filePath: json['file_path'] as String,
      materialStatus:
          MaterialStatus.values.byName(json['material_status'] as String),
      confidence: json['confidence'].toDouble() ?? 0.0,
      classname: FoodWasteClassname.values.byName(json['classname'] as String),
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'foodWasteScheduleId': foodWasteScheduleId,
      'filePath': filePath,
      'materialStatus': materialStatus,
      'confidence': confidence,
      'classname': classname,
      'createdAt': createdAt,
    };
  }

  FoodWasteModel copyWith({
    int? id,
    int? foodWasteScheduleId,
    String? filePath,
    MaterialStatus? materialStatus,
    double? confidence,
    FoodWasteClassname? classname,
    String? createdAt,
  }) {
    return FoodWasteModel(
      id: id ?? this.id,
      foodWasteScheduleId: foodWasteScheduleId ?? this.foodWasteScheduleId,
      filePath: filePath ?? this.filePath,
      materialStatus: materialStatus ?? this.materialStatus,
      confidence: confidence ?? this.confidence,
      classname: classname ?? this.classname,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
