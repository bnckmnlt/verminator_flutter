import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/data/models/compost_schedule_model.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/domain/entities/compost_schedule.dart';
import 'package:http/http.dart' as http;

part 'app_schedule_state.dart';

class AppScheduleCubit extends Cubit<AppScheduleState> {
  AppScheduleCubit() : super(AppScheduleInitial());

  Future<void> initializeApp() async {
    try {
      emit(AppScheduleLoading());

      final response = await http.get(
        Uri.parse("https://verminator.thinkio.me/schedule"),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        if (data.isNotEmpty) {
          final latestJson = data.first;
          final latestSchedule = CompostScheduleModel.fromJson(latestJson);

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
