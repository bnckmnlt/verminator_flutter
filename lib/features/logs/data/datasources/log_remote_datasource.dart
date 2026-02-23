import 'package:flutter_vermicomposting/core/error/exception.dart';
import 'package:flutter_vermicomposting/features/logs/data/models/logs_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class LogRemoteDatasource {
  Future<List<LogModel>> listLogs();
}

class LogRemoteDatasourceImpl implements LogRemoteDatasource {
  final SupabaseClient supabaseClient;

  LogRemoteDatasourceImpl({
    required this.supabaseClient,
  });

  @override
  Future<List<LogModel>> listLogs() async {
    try {
      final allLogs = <LogModel>[];
      const int pageSize = 1000;
      int currentOffset = 0;
      bool hasMore = true;

      while (hasMore) {
        final response = await supabaseClient
            .from('reading_log')
            .select()
            .order('created_at', ascending: false)
            .range(currentOffset, currentOffset + pageSize - 1);

        final logs = (response as List)
            .map((log) => LogModel.fromSupabaseJson(log))
            .toList();

        allLogs.addAll(logs);
        hasMore = logs.length == pageSize;
        currentOffset += pageSize;

        if (hasMore) {
          await Future.delayed(Duration(milliseconds: 100));
        }
      }

      return allLogs;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
