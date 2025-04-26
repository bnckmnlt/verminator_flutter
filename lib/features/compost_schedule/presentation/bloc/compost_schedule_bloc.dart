import 'package:bloc/bloc.dart';
import 'package:flutter_vermicomposting/core/usecase/usecase.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/domain/entities/compost_schedule.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/domain/usecases/create_compost_schedule.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/domain/usecases/list_compost_schedule.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/domain/usecases/patch_compost_schedule.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/domain/usecases/remove_compost_schedule.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/domain/usecases/selectone_compost_schedule.dart';
import 'package:meta/meta.dart';

part 'compost_schedule_event.dart';
part 'compost_schedule_state.dart';

class CompostScheduleBloc
    extends Bloc<CompostScheduleEvent, CompostScheduleState> {
  final CreateCompostSchedule _createCompostSchedule;
  final ListCompostSchedule _listCompostSchedule;
  final PatchCompostSchedule _patchCompostSchedule;
  final RemoveCompostSchedule _removeCompostSchedule;
  final SelectOneCompostSchedule _selectOneCompostSchedule;

  CompostScheduleBloc({
    required CreateCompostSchedule createCompostSchedule,
    required ListCompostSchedule listCompostSchedule,
    required PatchCompostSchedule patchCompostSchedule,
    required RemoveCompostSchedule removeCompostSchedule,
    required SelectOneCompostSchedule selectOneCompostSchedule,
  })  : _createCompostSchedule = createCompostSchedule,
        _listCompostSchedule = listCompostSchedule,
        _patchCompostSchedule = patchCompostSchedule,
        _removeCompostSchedule = removeCompostSchedule,
        _selectOneCompostSchedule = selectOneCompostSchedule,
        super(CompostScheduleInitial()) {
    on<CompostScheduleEvent>((event, emit) => emit(CompostScheduleLoading()));
    on<CompostScheduleCreate>(_onCreateCompostSchedule);
    on<CompostScheduleList>(_onListCompostSchedule);
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
      (r) => emit(CompostScheduleSuccess(r)),
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
}
