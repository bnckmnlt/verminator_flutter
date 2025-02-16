import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum LogSeverity {
  log,
  error,
  warning,
}

class LogTileWidget extends StatefulWidget {
  final int id;
  final LogSeverity severity;
  final String message;
  final String createdAt;

  const LogTileWidget({
    super.key,
    required this.id,
    required this.severity,
    required this.message,
    required this.createdAt,
  });

  @override
  _LogTileState createState() => _LogTileState();
}

class _LogTileState extends State<LogTileWidget> {
  bool _isTouched = false;

  @override
  Widget build(BuildContext context) {
    String formattedDate =
        DateFormat('dd MMM HH:mm:ss').format(DateTime.parse(widget.createdAt));

    return GestureDetector(
      onTapDown: (_) => _onTouch(true),
      onTapUp: (_) => _onTouch(false),
      onTapCancel: () => _onTouch(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        color: _isTouched
            ? Theme.of(context).colorScheme.secondary.withAlpha(32)
            : Theme.of(context).colorScheme.surface,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).colorScheme.surfaceDim,
                    width: 0.75,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 12.0, horizontal: 20.0),
                child: Row(
                  children: [
                    Text(
                      formattedDate,
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withAlpha(124),
                        fontFamily: "Geist Mono",
                        fontSize: 12,
                        letterSpacing: 0.025,
                      ),
                    ),
                    const SizedBox(width: 28),
                    severityType(widget.severity),
                    const SizedBox(width: 64),
                    Flexible(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Text(
                          widget.message,
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withAlpha(124),
                            fontFamily: "Geist Mono",
                            fontSize: 12,
                            letterSpacing: 0.025,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onTouch(bool isTouched) {
    setState(() {
      _isTouched = isTouched;
    });
  }

  Widget severityType(LogSeverity severity) {
    IconData icon;
    String label;
    Color color;

    switch (severity) {
      case LogSeverity.log:
        icon = CupertinoIcons.info;
        label = "LOG";
        color = Colors.blue;
        break;
      case LogSeverity.warning:
        icon = CupertinoIcons.exclamationmark_triangle;
        label = "WARNING";
        color = Colors.orange;
        break;
      case LogSeverity.error:
        icon = CupertinoIcons.exclamationmark_circle;
        label = "ERROR";
        color = Colors.red;
        break;
    }

    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontFamily: "Geist Mono",
            color: color,
          ),
        ),
      ],
    );
  }
}
