import 'dart:convert';

import 'package:flutter_vermicomposting/core/error/exception.dart';
import 'package:flutter_vermicomposting/core/utils/parse_error_message.dart';
import 'package:flutter_vermicomposting/features/notification/data/models/notification_model.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class NotificationRemoteDatasource {
  Stream<List<NotificationModel>> listNotification();

  Future<NotificationModel> selectOneNotification({
    required int id,
  });

  Future<NotificationModel> patchNotification({
    required int id,
    bool? read,
  });

  Future<String> removeNotification({
    required int id,
  });
}

class NotificationRemoteDatasourceImpl implements NotificationRemoteDatasource {
  final SupabaseClient supabaseClient;

  NotificationRemoteDatasourceImpl(this.supabaseClient);

  @override
  Stream<List<NotificationModel>> listNotification() {
    try {
      final notificationStream = supabaseClient
          .from("notification")
          .stream(primaryKey: ['id']).order('created_at');

      return notificationStream
          .map<List<NotificationModel>>((notificationList) {
        final notifications = notificationList
            .map<NotificationModel>(
              (notification) =>
                  NotificationModel.fromJsonSupabase(notification),
            )
            .toList();

        return notifications;
      });
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<NotificationModel> selectOneNotification({
    required int id,
  }) async {
    try {
      final response = await http.get(
        Uri.parse("https://verminator.thinkio.me/notification/$id"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        return NotificationModel.fromJson(jsonDecode(response.body));
      } else {
        throw ServerException(response.body.parseErrorMessage());
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<NotificationModel> patchNotification({
    required int id,
    bool? read,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse("https://verminator.thinkio.me/notification/$id"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          "id": id,
          "read": read ?? false,
        }),
      );

      if (response.statusCode == 200) {
        return NotificationModel.fromJson(jsonDecode(response.body));
      } else {
        throw ServerException(response.body.parseErrorMessage());
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> removeNotification({
    required int id,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse("https://verminator.thinkio.me/notification/$id"),
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
