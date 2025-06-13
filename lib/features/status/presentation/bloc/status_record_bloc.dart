import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vermicomposting/core/usecase/usecase.dart';
import 'package:flutter_vermicomposting/features/status/domain/entity/status_record.dart';
import 'package:flutter_vermicomposting/features/status/domain/usecases/list_status_records.dart';
import 'package:flutter_vermicomposting/features/status/domain/usecases/select_one_status_record.dart';

part 'status_record_event.dart';
part 'status_record_state.dart';

class StatusRecordBloc extends Bloc<StatusRecordEvent, StatusRecordState> {
  final ListStatusRecords _listStatusRecords;
  final SelectOneStatusRecord _selectOneStatusRecord;

  StatusRecordBloc({
    required ListStatusRecords listStatusRecords,
    required SelectOneStatusRecord selectOneStatusRecord,
  })  : _listStatusRecords = listStatusRecords,
        _selectOneStatusRecord = selectOneStatusRecord,
        super(StatusRecordInitial()) {
    on<StatusRecordEvent>((event, emit) => emit(StatusRecordLoading()));
    on<StatusRecordList>(_onListStatusRecords);
    on<StatusRecordSelectOne>(_onSelectOneStatusRecord);
  }

  void _onListStatusRecords(
      StatusRecordList event, Emitter<StatusRecordState> emit) async {
    final res = await _listStatusRecords(NoParams());

    res.fold(
      (l) => emit(StatusRecordFailure(l.message)),
      (r) => emit(StatusRecordListSuccess(r)),
    );
  }

  void _onSelectOneStatusRecord(
      StatusRecordSelectOne event, Emitter<StatusRecordState> emit) async {
    final res =
        await _selectOneStatusRecord(SelectOneStatusRecordParams(id: event.id));

    res.fold(
      (l) => emit(StatusRecordFailure(l.message)),
      (r) => emit(StatusRecordSuccess(r)),
    );
  }
}
