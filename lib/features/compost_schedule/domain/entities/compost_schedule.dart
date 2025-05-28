class CompostSchedule {
  final int id;
  final String scheduleName;
  final String? compostProduced;
  final String? juiceProduced;
  final bool isCompleted;
  final String? dateReleased;
  final String createdAt;
  final String updatedAt;

  CompostSchedule({
    required this.id,
    required this.scheduleName,
    this.compostProduced,
    this.juiceProduced,
    required this.isCompleted,
    this.dateReleased,
    required this.createdAt,
    required this.updatedAt,
  });
}
