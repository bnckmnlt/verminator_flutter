import 'dart:convert';

import 'package:flutter_vermicomposting/core/error/exception.dart';
import 'package:flutter_vermicomposting/core/utils/parse_error_message.dart';
import 'package:flutter_vermicomposting/features/sensor_reading/data/models/sensor_reading_model.dart';
import 'package:http/http.dart' as http;

abstract interface class SensorReadingRemoteDatasource {
  Future<List<SensorReadingModel>> listSensorReading();
}

class SensorReadingRemoteDatasourceImpl
    implements SensorReadingRemoteDatasource {
  @override
  Future<List<SensorReadingModel>> listSensorReading() async {
    try {
      final response = await http.get(
        Uri.parse("https://verminator.thinkio.me/sensors"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        return (jsonDecode(response.body) as List)
            .map((compostSchedule) =>
                SensorReadingModel.fromJson(compostSchedule))
            .toList();
      } else {
        throw ServerException(response.body.parseErrorMessage());
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
