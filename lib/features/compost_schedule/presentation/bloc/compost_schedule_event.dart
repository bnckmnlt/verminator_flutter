part of 'compost_schedule_bloc.dart';

@immutable
sealed class CompostScheduleEvent {}

final class CompostScheduleList extends CompostScheduleEvent {}

final class CompostScheduleSelectOne extends CompostScheduleEvent {
  final int id;

  CompostScheduleSelectOne({
    required this.id,
  });
}

final class CompostScheduleCreate extends CompostScheduleEvent {
  final String scheduleName;
  final String compostProduced;
  final String juiceProduced;

  CompostScheduleCreate({
    required this.scheduleName,
    required this.compostProduced,
    required this.juiceProduced,
  });
}

final class CompostSchedulePatch extends CompostScheduleEvent {
  final int id;
  final String? scheduleName;
  final String? compostProduced;
  final String? juiceProduced;
  final bool? isCompleted;
  final String? dateReleased;

  CompostSchedulePatch({
    required this.id,
    this.scheduleName,
    this.compostProduced,
    this.juiceProduced,
    this.isCompleted,
    this.dateReleased,
  });
}

final class CompostScheduleRemove extends CompostScheduleEvent {
  final int id;

  CompostScheduleRemove({
    required this.id,
  });
}
