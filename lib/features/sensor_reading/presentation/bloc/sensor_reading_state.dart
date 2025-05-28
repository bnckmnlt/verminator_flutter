part of 'sensor_reading_bloc.dart';

@immutable
sealed class SensorReadingState {
  const SensorReadingState();
}

final class SensorReadingInitial extends SensorReadingState {}

final class SensorReadingLoading extends SensorReadingState {}

final class SensorReadingFailure extends SensorReadingState {
  final String error;

  const SensorReadingFailure(this.error);
}

final class SensorReadingListSuccess extends SensorReadingState {
  final List<SensorReading> list;

  const SensorReadingListSuccess(this.list);
}
