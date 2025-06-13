part of 'status_record_bloc.dart';

@immutable
sealed class StatusRecordEvent {}

final class StatusRecordList extends StatusRecordEvent {}

final class StatusRecordSelectOne extends StatusRecordEvent {
  final int id;

  StatusRecordSelectOne({required this.id});
}
