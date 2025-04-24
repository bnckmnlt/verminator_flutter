import 'dart:convert';

import 'package:flutter_vermicomposting/core/error/exception.dart';
import 'package:flutter_vermicomposting/core/utils/parse_error_message.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/data/models/compost_schedule_model.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/domain/entities/compost_schedule.dart';
import 'package:http/http.dart' as http;

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
  });

  Future<String> removeCompostSchedule({
    required int id,
  });
}

class CompostScheduleRemoteDatasourceImpl
    implements CompostScheduleRemoteDatasource {
  @override
  Future<List<CompostSchedule>> listCompostSchedule() async {
    try {
      final response = await http.get(
        Uri.parse("https://verminator.thinkio.me/schedule"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        return (jsonDecode(response.body) as List)
            .map((compostSchedule) =>
                CompostScheduleModel.fromJson(compostSchedule))
            .toList();
      } else {
        throw ServerException(response.body.parseErrorMessage());
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<CompostSchedule> selectOneCompostSchedules({
    required int id,
  }) async {
    try {
      final response = await http.get(
        Uri.parse("https://verminator.thinkio.me/schedule/$id"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw ServerException(response.body.parseErrorMessage());
      }
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
      final response = await http.post(
        Uri.parse("https://verminator.thinkio.me/schedule"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'scheduleName': scheduleName,
          'compostProduced': compostProduced,
          'juiceProduced': juiceProduced,
        }),
      );

      if (response.statusCode == 200) {
        return CompostScheduleModel.fromJson(jsonDecode(response.body));
      } else {
        throw ServerException(response.body.parseErrorMessage());
      }
    } on Exception catch (e) {
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
  }) async {
    try {
      final response = await http.patch(
        Uri.parse("https://verminator.thinkio.me/schedule/$id"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'scheduleName': scheduleName ?? "",
          'compostProduced': compostProduced ?? "",
          'juiceProduced': juiceProduced ?? "",
          'isCompleted': isCompleted ?? null,
        }),
      );

      if (response.statusCode == 200) {
        return CompostScheduleModel.fromJson(jsonDecode(response.body));
      } else {
        throw ServerException(response.body.parseErrorMessage());
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> removeCompostSchedule({
    required int id,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse("https://verminator.thinkio.me/schedule/$id"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)["message"].toString();
      } else {
        throw ServerException(response.body.parseErrorMessage());
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
