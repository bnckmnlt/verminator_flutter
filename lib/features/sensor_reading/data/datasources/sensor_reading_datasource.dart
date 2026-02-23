import 'package:flutter_vermicomposting/core/error/exception.dart';
import 'package:flutter_vermicomposting/features/sensor_reading/data/models/sensor_reading_model.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class SensorReadingRemoteDatasource {
  Future<List<SensorReadingModel>> listSensorReading();
}

class SensorReadingRemoteDatasourceImpl
    implements SensorReadingRemoteDatasource {
  @override
  Future<List<SensorReadingModel>> listSensorReading() async {
    try {
      SupabaseClient supabaseClient = GetIt.instance<SupabaseClient>();

      final allReadings = <SensorReadingModel>[];
      const int pageSize = 1000;
      int currentOffset = 0;
      bool hasMore = true;

      while (hasMore) {
        final response = await supabaseClient
            .from("sensor_readings")
            .select()
            .order('created_at', ascending: false)
            .range(currentOffset, currentOffset + pageSize - 1);

        final readings = (response as List)
            .map((reading) => SensorReadingModel.fromSupabaseJson(reading))
            .toList();

        allReadings.addAll(readings);
        hasMore = readings.length == pageSize;
        currentOffset += pageSize;

        if (hasMore) {
          await Future.delayed(Duration(milliseconds: 100));
        }
      }

      return allReadings;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
