import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vermicomposting/core/common/cubits/app_schedule/app_schedule_cubit.dart';
import 'package:flutter_vermicomposting/core/usecase/usecase.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/domain/entities/compost_schedule.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/domain/usecases/create_compost_schedule.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/domain/usecases/list_compost_schedule.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/domain/usecases/patch_compost_schedule.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/domain/usecases/remove_compost_schedule.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/domain/usecases/selectone_compost_schedule.dart';

part 'compost_schedule_event.dart';
part 'compost_schedule_state.dart';

class CompostScheduleBloc
    extends Bloc<CompostScheduleEvent, CompostScheduleState> {
  final CreateCompostSchedule _createCompostSchedule;
  final ListCompostSchedule _listCompostSchedule;
  final PatchCompostSchedule _patchCompostSchedule;
  final RemoveCompostSchedule _removeCompostSchedule;
  final SelectOneCompostSchedule _selectOneCompostSchedule;
  final AppScheduleCubit _appScheduleCubit;

  CompostScheduleBloc({
    required CreateCompostSchedule createCompostSchedule,
    required ListCompostSchedule listCompostSchedule,
    required PatchCompostSchedule patchCompostSchedule,
    required RemoveCompostSchedule removeCompostSchedule,
    required SelectOneCompostSchedule selectOneCompostSchedule,
    required AppScheduleCubit appScheduleCubit,
  })  : _createCompostSchedule = createCompostSchedule,
        _listCompostSchedule = listCompostSchedule,
        _patchCompostSchedule = patchCompostSchedule,
        _removeCompostSchedule = removeCompostSchedule,
        _selectOneCompostSchedule = selectOneCompostSchedule,
        _appScheduleCubit = appScheduleCubit,
        super(CompostScheduleInitial()) {
    on<CompostScheduleEvent>((event, emit) => emit(CompostScheduleLoading()));
    on<CompostScheduleCreate>(_onCreateCompostSchedule);
    on<CompostScheduleList>(_onListCompostSchedule);
    on<CompostScheduleSelectOne>(_onSelectOneCompostSchedule);
    on<CompostSchedulePatch>(_onPatchCompostSchedule);
    on<CompostScheduleRemove>(_onRemoveCompostSchedule);
  }

  void _onCreateCompostSchedule(
    CompostScheduleCreate event,
    Emitter<CompostScheduleState> emit,
  ) async {
    final res = await _createCompostSchedule(CreateCompostScheduleParams(
      scheduleName: event.scheduleName,
      compostProduced: event.compostProduced,
      juiceProduced: event.juiceProduced,
    ));

    res.fold(
      (l) => emit(CompostScheduleFailure(l.message)),
      (r) => _emitCurrentSchedule(r, emit),
    );
  }

  void _onListCompostSchedule(
    CompostScheduleList event,
    Emitter<CompostScheduleState> emit,
  ) async {
    final res = await _listCompostSchedule(NoParams());

    res.fold(
      (l) => emit(CompostScheduleFailure(l.message)),
      (r) => emit(CompostScheduleListSuccess(r)),
    );
  }

  void _onSelectOneCompostSchedule(CompostScheduleSelectOne event,
      Emitter<CompostScheduleState> emit) async {
    final res = await _selectOneCompostSchedule(
        SelectOneCompostScheduleParams(id: event.id));

    res.fold(
      (l) => emit(CompostScheduleFailure(l.message)),
      (r) => emit(CompostScheduleSuccess(r)),
    );
  }

  void _onPatchCompostSchedule(
    CompostSchedulePatch event,
    Emitter<CompostScheduleState> emit,
  ) async {
    final res = await _patchCompostSchedule(PatchCompostScheduleParams(
      id: event.id,
      scheduleName: event.scheduleName,
      compostProduced: event.compostProduced,
      juiceProduced: event.juiceProduced,
      isCompleted: event.isCompleted,
      dateReleased: event.dateReleased,
    ));

    res.fold(
      (l) => emit(CompostScheduleFailure(l.message)),
      (r) => emit(CompostScheduleSuccess(r)),
    );
  }

  void _onRemoveCompostSchedule(
      CompostScheduleRemove event, Emitter<CompostScheduleState> emit) async {
    final res =
        await _removeCompostSchedule(RemoveCompostScheduleParams(id: event.id));

    res.fold(
      (l) => emit(CompostScheduleFailure(l.message)),
      (r) => emit(CompostScheduleRemoveSuccess(r)),
    );
  }

  void _emitCurrentSchedule(
      CompostSchedule schedule, Emitter<CompostScheduleState> emit) {
    _appScheduleCubit.updateCurrentSchedule(schedule);
    emit(CompostScheduleSuccess(schedule));
  }
}
