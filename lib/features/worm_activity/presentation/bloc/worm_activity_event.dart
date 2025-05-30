part of 'worm_activity_bloc.dart';

@immutable
sealed class WormActivityEvent {}

final class WormActivityList extends WormActivityEvent {}

final class WormActivitySelectOne extends WormActivityEvent {
  final int id;

  WormActivitySelectOne(this.id);
}
