import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vermicomposting/core/usecase/usecase.dart';
import 'package:flutter_vermicomposting/features/logs/domain/entity/log_entity.dart';
import 'package:flutter_vermicomposting/features/logs/domain/usecases/list_logs.dart';

part 'log_event.dart';
part 'log_state.dart';

class LogBloc extends Bloc<LogEvent, LogState> {
  final ListLogs _listLogs;

  LogBloc({
    required ListLogs listLogs,
  })  : _listLogs = listLogs,
        super(LogsInitial()) {
    on<LogEvent>((event, emit) => emit(LogsLoading()));
    on<LogList>(_onListLogs);
  }

  void _onListLogs(LogList event, Emitter<LogState> emit) async {
    final res = await _listLogs(NoParams());

    res.fold(
      (l) => emit(LogsFailure(l.message)),
      (r) => emit(LogsListSuccess(r)),
    );
  }
}
