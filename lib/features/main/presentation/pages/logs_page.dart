import 'package:dotted_border/dotted_border.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:flutter_vermicomposting/core/utils/string_extensions.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/log_tile_widget.dart';

class LogsPage extends StatefulWidget {
  const LogsPage({super.key});

  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  bool isChartShown = false;
  String searchQuery = '';
  LogSeverityFilter selectedSeverity = LogSeverityFilter.all;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double height = constraints.maxHeight;
        double width = constraints.maxWidth;

        return Scaffold(
          extendBody: true,
          extendBodyBehindAppBar: true,
          body: SizedBox(
            height: height,
            width: width,
            child: Column(
              children: [
                Container(
                  width: width,
                  color: Theme.of(context).colorScheme.surface,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: width * 0.5,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceDim,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: CupertinoSearchTextField(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainer,
                                  placeholder: "Search events",
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withAlpha(124),
                                      fontSize: 14,
                                      letterSpacing: 0.025),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 8.0),
                                  onChanged: (value) {
                                    setState(() {
                                      searchQuery = value;
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              height: 34,
                              width: 34,
                              child: IconButton(
                                padding: const EdgeInsets.all(0),
                                iconSize: 18,
                                onPressed: () {},
                                style: ButtonStyle(
                                  shape: WidgetStatePropertyAll(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surfaceDim,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                ),
                                icon: Icon(
                                  FluentIcons.arrow_sync_20_regular,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withAlpha(124),
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            PopupMenuButton<LogSeverityFilter>(
                              onSelected: (value) {
                                setState(() {
                                  selectedSeverity = value;
                                });
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(
                                  value: LogSeverityFilter.all,
                                  child: Text('All'),
                                ),
                                PopupMenuItem(
                                  value: LogSeverityFilter.log,
                                  child: Text('Log'),
                                ),
                                PopupMenuItem(
                                  value: LogSeverityFilter.error,
                                  child: Text('Error'),
                                ),
                                PopupMenuItem(
                                  value: LogSeverityFilter.warning,
                                  child: Text('Warning'),
                                ),
                              ],
                              child: DottedBorder(
                                strokeWidth: 1.3,
                                borderType: BorderType.RRect,
                                radius: Radius.circular(8),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 12.0),
                                color: Theme.of(context).colorScheme.surfaceDim,
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                  child: Container(
                                    child: Text(
                                      selectedSeverity == LogSeverityFilter.all
                                          ? "All"
                                          : selectedSeverity
                                              .toString()
                                              .split('.')
                                              .last
                                              .firstLetterUpperCase(),
                                      // Display selected severity
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withAlpha(168),
                                        fontSize: 12,
                                        fontFamily: 'Geist Mono',
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.025,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isChartShown = !isChartShown;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 12.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceDim,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isChartShown
                                          ? CupertinoIcons.eye
                                          : CupertinoIcons.eye_slash,
                                      size: 16,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withAlpha(124),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Chart",
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withAlpha(168),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.025,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              height: 34,
                              width: 34,
                              child: IconButton(
                                padding: const EdgeInsets.all(0),
                                iconSize: 18,
                                onPressed: () {},
                                style: ButtonStyle(
                                  shape: WidgetStatePropertyAll(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surfaceDim,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                ),
                                icon: Icon(
                                  FluentIcons.arrow_download_24_regular,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withAlpha(124),
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isChartShown)
                        Container(
                          height: height * 0.15,
                          margin: const EdgeInsets.only(top: 12.0),
                          color: Colors.greenAccent,
                        )
                    ],
                  ),
                ),

                // Log Details
                Expanded(
                  child: Container(
                    height: height * 0.75,
                    width: width,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withAlpha(124),
                      border: Border(
                        top: BorderSide(
                          color: Theme.of(context).colorScheme.surfaceDim,
                          width: 0.75,
                        ),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          LogTileWidget(
                              id: 412,
                              severity: LogSeverity.log,
                              message: "Hello world",
                              createdAt: "2021-09-12 12:00:00"),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
