part of 'log_bloc.dart';

@immutable
sealed class LogState {
  const LogState();
}

final class LogsInitial extends LogState {}

final class LogsLoading extends LogState {}

final class LogsFailure extends LogState {
  final String error;

  const LogsFailure(this.error);
}

final class LogsListSuccess extends LogState {
  final List<LogEntity> logs;

  const LogsListSuccess(this.logs);
}
