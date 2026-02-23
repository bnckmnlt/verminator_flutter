import 'package:flutter_vermicomposting/core/error/exception.dart';
import 'package:flutter_vermicomposting/features/status/data/models/status_record_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class StatusRemoteDatasource {
  Future<List<StatusRecordModel>> listStatusRecords();

  Future<StatusRecordModel> selectOneStatusRecord({required int id});
}

class StatusRemoteDatasourceImpl implements StatusRemoteDatasource {
  final SupabaseClient supabaseClient;

  StatusRemoteDatasourceImpl({
    required this.supabaseClient,
  });

  @override
  Future<List<StatusRecordModel>> listStatusRecords() async {
    try {
      final response = await supabaseClient
          .from('status_records')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((statusRecord) =>
              StatusRecordModel.fromJsonSupabase(statusRecord))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<StatusRecordModel> selectOneStatusRecord({required int id}) async {
    try {
      final response =
          await supabaseClient.from('status').select().eq('id', id).single();

      return StatusRecordModel.fromJsonSupabase(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
