part of 'app_schedule_cubit.dart';

@immutable
sealed class AppScheduleState {
  const AppScheduleState();
}

final class AppScheduleInitial extends AppScheduleState {}

final class AppScheduleLoading extends AppScheduleState {}

final class AppScheduleError extends AppScheduleState {
  final String error;

  const AppScheduleError(this.error);
}

final class AppScheduleActive extends AppScheduleState {
  final CompostSchedule compostSchedule;

  const AppScheduleActive(this.compostSchedule);
}
