import 'dart:convert';

import 'package:flutter_vermicomposting/core/error/exception.dart';
import 'package:flutter_vermicomposting/core/utils/parse_error_message.dart';
import 'package:flutter_vermicomposting/features/status/data/models/status_record_model.dart';
import 'package:http/http.dart' as http;

abstract interface class StatusRemoteDatasource {
  Future<List<StatusRecordModel>> listStatusRecords();

  Future<StatusRecordModel> selectOneStatusRecord({required int id});
}

class StatusRemoteDatasourceImpl implements StatusRemoteDatasource {
  @override
  Future<List<StatusRecordModel>> listStatusRecords() async {
    try {
      final response = await http.get(
        Uri.parse("https://verminator.thinkio.me/status"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        return (jsonDecode(response.body) as List)
            .map((statusRecord) => StatusRecordModel.fromJson(statusRecord))
            .toList();
      } else {
        throw ServerException(response.body.parseErrorMessage());
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<StatusRecordModel> selectOneStatusRecord({required int id}) async {
    try {
      final response = await http.get(
        Uri.parse("https://verminator.thinkio.me/status/$id"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        return StatusRecordModel.fromJson(jsonDecode(response.body));
      } else {
        throw ServerException(response.body.parseErrorMessage());
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
