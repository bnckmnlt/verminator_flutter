part of 'compost_schedule_bloc.dart';

@immutable
sealed class CompostScheduleState {
  const CompostScheduleState();
}

final class CompostScheduleInitial extends CompostScheduleState {}

final class CompostScheduleLoading extends CompostScheduleState {}

final class CompostScheduleFailure extends CompostScheduleState {
  final String error;

  const CompostScheduleFailure(
    this.error,
  );
}

final class CompostScheduleListSuccess extends CompostScheduleState {
  final List<CompostSchedule> compostScheduleList;

  const CompostScheduleListSuccess(this.compostScheduleList);
}

final class CompostScheduleSuccess extends CompostScheduleState {
  final CompostSchedule compostSchedule;

  const CompostScheduleSuccess(this.compostSchedule);
}

final class CompostScheduleRemoveSuccess extends CompostScheduleState {
  final String message;

  const CompostScheduleRemoveSuccess(this.message);
}
