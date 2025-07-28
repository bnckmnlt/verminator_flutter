import 'dart:convert';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/core/common/widgets/toast_helper.dart';
import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:flutter_vermicomposting/features/notification/domain/entities/notification.dart';
import 'package:flutter_vermicomposting/mqtt_service.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationTile extends StatefulWidget {
  final NotificationEntity notification;
  final SupabaseClient supabaseClient;
  final void Function() onRefresh;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.supabaseClient,
    required this.onRefresh,
  });

  @override
  State<NotificationTile> createState() => _NotificationTileState();
}

class _NotificationTileState extends State<NotificationTile> {
  late NotificationEntity notification;
  late SupabaseClient supabaseClient;
  late MqttService _mqttService;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();

    _mqttService = GetIt.instance<MqttService>();

    notification = widget.notification;
    supabaseClient = widget.supabaseClient;
  }

  void runSifter(ToastHelper toast) async {
    try {
      final statusUri = Uri.parse(
        "https://verminator.thinkio.me/status",
      );

      _mqttService.publish("control/sifter", "Process:15",
          qos: MqttQos.atLeastOnce);

      final statusPayload = {
        'statusScheduleId': notification.scheduleId,
        'status': CompostingStatus.released.name,
        'remarks': null,
        'isCompleted': false,
      };

      final statusResponse = await http.post(
        statusUri,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(statusPayload),
      );

      if (statusResponse.statusCode != 200) {
        toast.show(
          title: "An error has occurred",
          description:
              "An error occurred during the process: ${statusResponse.body.toString()}",
          isError: true,
        );

        return;
      }

      toast.show(
        title: "Sifting operation started",
        description: "Sifter is executing for 15 full processing cycles",
        isError: false,
      );
    } catch (e) {
      toast.show(
        title: "An error has occurred",
        description: "An error occurred during the process: ${e.toString()}",
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final toast = ToastHelper(context);

    final timeCreated = DateTime.parse(notification.createdAt);

    final String ago = timeago.format(timeCreated);
    final String formattedDay = DateFormat("MMMM d, yyyy").format(timeCreated);
    final String formattedTime =
        DateFormat("EEEE, hh:mm a").format(timeCreated);

    List<Map<String, dynamic>> actionButtonList = [
      {
        'label': "Accept",
        'behavior': () => runSifter(toast),
      },
      {
        'label': "Maybe later",
        'behavior': () {},
      },
    ];

    return GestureDetector(
      onTap: () async {
        if (!notification.read) {
          final id = notification.id;
          await supabaseClient
              .from("notification")
              .update({'read': true}).eq('id', id);
        }
        setState(() {
          notification = notification.copyWith(read: true);
          _isExpanded = !_isExpanded;
        });
        widget.onRefresh;
      },
      child: Container(
        decoration: BoxDecoration(
          color: notification.read
              ? theme.colorScheme.surfaceContainerHighest
              : theme.colorScheme.surfaceContainerHigh,
        ),
        padding: const EdgeInsets.fromLTRB(14, 18, 14, 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: parseActivityToColor(notification.notificationType)
                    .withAlpha(28),
              ),
              padding: const EdgeInsets.all(12),
              child: Icon(
                parseActivityToIcon(notification.notificationType),
                size: 18,
                color: parseActivityToColor(notification.notificationType),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        notification.subject,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.025,
                        ),
                      ),
                      if (_isExpanded) const SizedBox(width: 16),
                      if (_isExpanded)
                        _buildNotificationTime(
                            formattedTime, formattedDay, ago),
                    ],
                  ),
                  if (!_isExpanded)
                    _buildNotificationTime(formattedTime, formattedDay, ago),
                  if (_isExpanded)
                    _buildExpandedSection(theme, actionButtonList),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTime(String time, String day, String ago) {
    return !_isExpanded
        ? Padding(
            padding: const EdgeInsets.only(top: 0.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Constants().textMutedFgDark,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.025,
                  ),
                ),
                Text(
                  day,
                  style: TextStyle(
                    fontSize: 12,
                    color: Constants().textMutedFgDark,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.025,
                  ),
                ),
              ],
            ),
          )
        : Padding(
            padding: const EdgeInsets.only(top: 0.0),
            child: Text(
              ago,
              style: TextStyle(
                fontSize: 12,
                color: Constants().textMutedFgDark,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.025,
              ),
            ),
          );
  }

  Widget _buildExpandedSection(
      ThemeData theme, List<Map<String, dynamic>> actionButtonList) {
    return Column(
      children: [
        const SizedBox(height: 6),
        Text(
          notification.description,
          style: TextStyle(
            color: theme.colorScheme.onSurface.withAlpha(164),
            fontSize: 12,
          ),
        ),
        notification.path == "SIFTER"
            ? Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  spacing: 10,
                  children: actionButtonList.map((item) {
                    return ElevatedButton(
                      onPressed: item['behavior'],
                      style: ElevatedButton.styleFrom(
                        side: BorderSide(
                          color: item['label'] == "Accept"
                              ? Colors.transparent
                              : Colors.white30,
                        ),
                        backgroundColor: item['label'] == "Accept"
                            ? Colors.amberAccent.shade200
                            : Color(0xFFFFF4F2).withAlpha(64),
                        padding:
                            EdgeInsets.symmetric(vertical: 6, horizontal: 20),
                        minimumSize: Size.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(6), // Adjust as needed
                        ),
                      ),
                      child: Text(
                        item['label'],
                        style: TextStyle(
                          color: item["label"] == "Accept"
                              ? Colors.black87
                              : Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.012,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              )
            : const SizedBox.shrink()
      ],
    );
  }
}

IconData parseActivityToIcon(NotificationType type) {
  switch (type) {
    case NotificationType.completion:
      return CupertinoIcons.checkmark_alt_circle_fill;
    case NotificationType.added:
      return FluentIcons.apps_add_in_24_filled;
    case NotificationType.error:
      return FluentIcons.prohibited_24_filled;
    case NotificationType.feeding:
      return FluentIcons.food_16_filled;
    default:
      return FluentIcons.dual_screen_vibrate_24_filled;
  }
}

MaterialAccentColor parseActivityToColor(NotificationType type) {
  switch (type) {
    case NotificationType.completion:
      return Colors.greenAccent;
    case NotificationType.added:
      return Colors.lightBlueAccent;
    case NotificationType.error:
      return Colors.redAccent;
    case NotificationType.feeding:
      return Colors.indigoAccent;
    default:
      return Colors.amberAccent;
  }
}
