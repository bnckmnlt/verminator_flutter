import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:flutter_vermicomposting/features/notification/domain/entities/notification.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationTile extends StatefulWidget {
  final NotificationEntity notification;

  const NotificationTile({super.key, required this.notification});

  @override
  State<NotificationTile> createState() => _NotificationTileState();
}

class _NotificationTileState extends State<NotificationTile> {
  late NotificationEntity notification;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();

    notification = widget.notification;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final timeCreated = DateTime.parse(notification.createdAt);

    final String ago = timeago.format(timeCreated);
    final String formattedDay = DateFormat("MMMM d, yyyy").format(timeCreated);
    final String formattedTime =
        DateFormat("EEEE, hh:mm a").format(timeCreated);

    return Padding(
      padding: const EdgeInsets.only(top: 1),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHigh,
          ),
          padding: const EdgeInsets.fromLTRB(14, 18, 14, 18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.lightBlueAccent.withAlpha(28),
                ),
                padding: const EdgeInsets.all(12),
                child: const Icon(
                  CupertinoIcons.alarm_fill,
                  size: 18,
                  color: Colors.lightBlueAccent,
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
                    if (_isExpanded) _buildExpandedSection(theme),
                  ],
                ),
              ),
            ],
          ),
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

  Widget _buildExpandedSection(ThemeData theme) {
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
      ],
    );
  }
}
