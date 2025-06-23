class FoodWaste {
  final int id;
  final int foodWasteScheduleId;
  final String filePath;
  final MaterialStatus materialStatus;
  final double confidence;
  final FoodWasteClassname classname;
  final String createdAt;

  FoodWaste({
    required this.id,
    required this.foodWasteScheduleId,
    required this.filePath,
    required this.materialStatus,
    required this.confidence,
    required this.classname,
    required this.createdAt,
  });
}

enum MaterialStatus { valid, invalid }

enum FoodWasteClassname {
  fruit,
  vegetable,
  grains,
  citrus,
  meat,
  foreign,
}
