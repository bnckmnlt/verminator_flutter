import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vermicomposting/core/usecase/usecase.dart';
import 'package:flutter_vermicomposting/features/worm_activity/domain/entity/worm_activity.dart';
import 'package:flutter_vermicomposting/features/worm_activity/domain/usecases/list_worm_activity.dart';
import 'package:flutter_vermicomposting/features/worm_activity/domain/usecases/select_one_worm_activitiy.dart';

part 'worm_activity_event.dart';
part 'worm_activity_state.dart';

class WormActivityBloc extends Bloc<WormActivityEvent, WormActivityState> {
  final ListWormActivity _listWormActivity;
  final SelectOneWormActivity _selectOneWormActivity;

  WormActivityBloc({
    required ListWormActivity listWormActivity,
    required SelectOneWormActivity selectOneWormActivity,
  })  : _listWormActivity = listWormActivity,
        _selectOneWormActivity = selectOneWormActivity,
        super(WormActivityInitial()) {
    on<WormActivityEvent>((event, emit) {
      emit(WormActivityLoading());
    });
    on<WormActivityList>(_onListWormActivity);
    on<WormActivitySelectOne>(_onSelectOneWormActivity);
  }

  void _onListWormActivity(
      WormActivityList event, Emitter<WormActivityState> emit) async {
    final res = await _listWormActivity(NoParams());

    res.fold(
      (l) => emit(WormActivityFailure(l.message)),
      (r) => emit(WormActivityListSuccess(r)),
    );
  }

  void _onSelectOneWormActivity(
      WormActivitySelectOne event, Emitter<WormActivityState> emit) async {
    final res = await _selectOneWormActivity(SelectOneWormActivityParams(
      id: event.id,
    ));

    res.fold(
      (l) => emit(WormActivityFailure(l.message)),
      (r) => emit(WormActivitySuccess(r)),
    );
  }
}
