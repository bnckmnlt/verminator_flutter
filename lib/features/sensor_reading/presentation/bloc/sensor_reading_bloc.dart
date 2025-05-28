import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vermicomposting/core/usecase/usecase.dart';
import 'package:flutter_vermicomposting/features/sensor_reading/domain/entity/sensor_reading.dart';
import 'package:flutter_vermicomposting/features/sensor_reading/domain/usecases/list_sensor_reading.dart';

part 'sensor_reading_event.dart';
part 'sensor_reading_state.dart';

class SensorReadingBloc extends Bloc<SensorReadingEvent, SensorReadingState> {
  final ListSensorReading _listSensorReading;

  SensorReadingBloc({
    required ListSensorReading listSensorReading,
  })  : _listSensorReading = listSensorReading,
        super(SensorReadingInitial()) {
    on<SensorReadingEvent>((event, emit) => emit(SensorReadingLoading()));
    on<SensorReadingList>(_onListSensorReading);
  }

  void _onListSensorReading(
      SensorReadingList event, Emitter<SensorReadingState> emit) async {
    final res = await _listSensorReading(NoParams());

    res.fold(
      (l) => emit(SensorReadingFailure(l.message)),
      (r) => emit(SensorReadingListSuccess(r)),
    );
  }
}
