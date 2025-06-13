part of 'status_record_bloc.dart';

@immutable
sealed class StatusRecordState {
  const StatusRecordState();
}

final class StatusRecordInitial extends StatusRecordState {}

final class StatusRecordLoading extends StatusRecordState {}

final class StatusRecordFailure extends StatusRecordState {
  final String error;

  const StatusRecordFailure(this.error);
}

final class StatusRecordSuccess extends StatusRecordState {
  final StatusRecord statusRecord;

  const StatusRecordSuccess(this.statusRecord);
}

final class StatusRecordListSuccess extends StatusRecordState {
  final List<StatusRecord> statusRecordList;

  const StatusRecordListSuccess(this.statusRecordList);
}
