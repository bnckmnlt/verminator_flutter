part of 'worm_activity_bloc.dart';

@immutable
sealed class WormActivityState {
  const WormActivityState();
}

final class WormActivityInitial extends WormActivityState {}

final class WormActivityLoading extends WormActivityState {}

final class WormActivityFailure extends WormActivityState {
  final String error;

  const WormActivityFailure(this.error);
}

final class WormActivitySuccess extends WormActivityState {
  final WormActivity wormActivity;

  const WormActivitySuccess(this.wormActivity);
}

final class WormActivityListSuccess extends WormActivityState {
  final List<WormActivity> list;

  const WormActivityListSuccess(this.list);
}
