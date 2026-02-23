import 'dart:convert';

import 'package:flutter_vermicomposting/core/error/exception.dart';
import 'package:flutter_vermicomposting/core/secrets/app_secrets.dart';
import 'package:flutter_vermicomposting/core/utils/parse_error_message.dart';
import 'package:flutter_vermicomposting/features/worm_activity/data/models/worm_activity_model.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class WormActivityRemoteDatasource {
  Future<List<WormActivityModel>> listWormActivity();

  Future<WormActivityModel> selectOneWormActivity({
    required int id,
  });
}

class WormActivityRemoteDatasourceImpl implements WormActivityRemoteDatasource {
  final SupabaseClient supabaseClient;

  WormActivityRemoteDatasourceImpl({
    required this.supabaseClient,
  });

  @override
  Future<List<WormActivityModel>> listWormActivity() async {
    try {
      final response = await http.get(
        Uri.parse("${AppSecrets.domainURL}/worm-activity"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        return (jsonDecode(response.body) as List)
            .map((wormActivity) => WormActivityModel.fromJson(wormActivity))
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      } else {
        throw ServerException(response.body.parseErrorMessage());
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<WormActivityModel> selectOneWormActivity({
    required int id,
  }) async {
    try {
      final response = await http.get(
        Uri.parse("${AppSecrets.domainURL}/worm-activity/$id"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        return WormActivityModel.fromJson(jsonDecode(response.body));
      } else {
        throw ServerException(response.body.parseErrorMessage());
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
