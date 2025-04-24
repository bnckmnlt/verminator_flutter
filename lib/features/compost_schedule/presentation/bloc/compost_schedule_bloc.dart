import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'compost_schedule_event.dart';
part 'compost_schedule_state.dart';

class CompostScheduleBloc
    extends Bloc<CompostScheduleEvent, CompostScheduleState> {
  CompostScheduleBloc() : super(CompostScheduleInitial()) {
    on<CompostScheduleEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
