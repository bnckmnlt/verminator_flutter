import 'package:flutter_vermicomposting/core/error/exception.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/data/models/compost_schedule_model.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/domain/entities/compost_schedule.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class CompostScheduleRemoteDatasource {
  Future<List<CompostSchedule>> listCompostSchedule();

  Future<CompostSchedule> selectOneCompostSchedules({
    required int id,
  });

  Future<CompostSchedule> createCompostScheduleById({
    required String scheduleName,
    required String compostProduced,
    required String juiceProduced,
  });

  Future<CompostSchedule> patchCompostSchedule({
    required int id,
    String? scheduleName,
    String? compostProduced,
    String? juiceProduced,
    bool? isCompleted,
    String? dateReleased,
  });

  Future<String> removeCompostSchedule({
    required int id,
  });
}

class CompostScheduleRemoteDatasourceImpl
    implements CompostScheduleRemoteDatasource {
  final SupabaseClient supabaseClient;

  CompostScheduleRemoteDatasourceImpl({
    required this.supabaseClient,
  });

  @override
  Future<List<CompostSchedule>> listCompostSchedule() async {
    try {
      final response = await supabaseClient
          .from('compost_schedule')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((schedule) => CompostScheduleModel.fromSupabaseJson(schedule))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<CompostSchedule> selectOneCompostSchedules({
    required int id,
  }) async {
    try {
      final response = await supabaseClient
          .from('compost_schedule')
          .select()
          .eq('id', id)
          .single();

      return CompostScheduleModel.fromSupabaseJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<CompostSchedule> createCompostScheduleById({
    required String scheduleName,
    required String compostProduced,
    required String juiceProduced,
  }) async {
    try {
      final response = await supabaseClient
          .from('compost_schedule')
          .insert({
            'schedule_name': scheduleName,
            'compost_produced': compostProduced,
            'juice_produced': juiceProduced,
          })
          .select()
          .single();

      return CompostScheduleModel.fromSupabaseJson(response);
    } on PostgrestException catch (e) {
      throw ServerException('Database error: ${e.message}');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<CompostSchedule> patchCompostSchedule({
    required int id,
    String? scheduleName,
    String? compostProduced,
    String? juiceProduced,
    bool? isCompleted,
    String? dateReleased,
  }) async {
    try {
      final Map<String, dynamic> updates = {};

      if (scheduleName != null) updates['schedule_name'] = scheduleName;
      if (compostProduced != null)
        updates['compost_produced'] = compostProduced;
      if (juiceProduced != null) updates['juice_produced'] = juiceProduced;
      if (isCompleted != null) updates['is_completed'] = isCompleted;
      if (dateReleased != null) updates['date_released'] = dateReleased;

      if (updates.isEmpty) {
        return selectOneCompostSchedules(id: id);
      }

      final response = await supabaseClient
          .from('compost_schedule')
          .update(updates)
          .eq('id', id)
          .select()
          .single();

      return CompostScheduleModel.fromSupabaseJson(response);
    } on PostgrestException catch (e) {
      throw ServerException('Database error: ${e.message}');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> removeCompostSchedule({
    required int id,
  }) async {
    try {
      await supabaseClient.from('compost_schedule').delete().eq('id', id);

      return 'Compost schedule deleted successfully';
    } on PostgrestException catch (e) {
      throw ServerException('Database error: ${e.message}');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
