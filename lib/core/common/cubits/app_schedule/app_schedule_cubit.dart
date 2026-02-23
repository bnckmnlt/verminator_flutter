import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/data/models/compost_schedule_model.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/domain/entities/compost_schedule.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'app_schedule_state.dart';

class AppScheduleCubit extends Cubit<AppScheduleState> {
  AppScheduleCubit() : super(AppScheduleInitial());

  Future<void> initializeApp() async {
    try {
      emit(AppScheduleLoading());

      final SupabaseClient supabaseClient = GetIt.I<SupabaseClient>();

      final response = await supabaseClient
          .from('compost_schedule')
          .select()
          .order('created_at', ascending: false);

      if (response.isNotEmpty) {
        final List<CompostSchedule> data = (response as List)
            .map((schedule) => CompostScheduleModel.fromSupabaseJson(schedule))
            .toList();

        if (data.isNotEmpty) {
          final CompostSchedule latestSchedule =
              data.where((schedule) => !schedule.isCompleted).single;

          emit(AppScheduleActive(latestSchedule));
          return;
        }
      }

      emit(AppScheduleError("No schedule found or bad response"));
    } catch (e) {
      emit(AppScheduleError("Initialization failed: $e"));
    }
  }

  void updateCurrentSchedule(CompostSchedule? schedule) {
    if (schedule == null) {
      emit(AppScheduleInitial());
    } else {
      emit(AppScheduleActive(schedule));
    }
  }
}
