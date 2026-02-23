import 'dart:async';

import 'package:dotted_border/dotted_border.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vermicomposting/core/common/widgets/error_widget.dart';
import 'package:flutter_vermicomposting/core/common/widgets/loader.dart';
import 'package:flutter_vermicomposting/core/common/widgets/toast_helper.dart';
import 'package:flutter_vermicomposting/features/logs/domain/entity/log_entity.dart';
import 'package:flutter_vermicomposting/features/logs/presentation/bloc/log_bloc.dart';
import 'package:flutter_vermicomposting/features/main/domain/entities/data_table_column.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/logs_widgets/logs_data_table.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  Timer? _debounce;
  final ValueNotifier<String> _selectedSeverity = ValueNotifier('all');
  final ValueNotifier<String> _searchQuery = ValueNotifier('');

  final List<String> _severityOptions = [
    'all',
    'info',
    'warn',
    'error',
    'fatal',
  ];

  final List<DataTableColumn> columns = [
    DataTableColumn(label: "Log Level"),
    DataTableColumn(label: "Timestamp"),
    DataTableColumn(label: "Message"),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _selectedSeverity.dispose();
    _searchQuery.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final toastHelper = ToastHelper(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        double deviceHeight = constraints.maxHeight;
        double deviceWidth = constraints.maxWidth;

        return Scaffold(
          extendBody: true,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            iconTheme:
                IconThemeData(color: Theme.of(context).colorScheme.onSurface),
            backgroundColor: Colors.transparent,
            elevation: 0.0,
          ),
          body: BlocBuilder<LogBloc, LogState>(builder: (context, state) {
            if (state is LogsLoading) {
              return Center(child: Loader());
            } else if (state is LogsFailure) {
              toastHelper.show(
                title: "An error has occurred during retrieval",
                description: state.error,
                isError: true,
              );
            } else if (state is LogsListSuccess) {
              final cardList = _buildLogCards(state.logs);

              return SizedBox(
                width: deviceWidth,
                height: deviceHeight,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(44, 86, 44, 0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "System Logs",
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 32),
                            Row(
                              children: cardList.map((item) {
                                final isFirst = cardList.indexOf(item) == 0;
                                return Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(
                                        isFirst ? 0 : 14, 0, 0, 0),
                                    child: Container(
                                      height: 124,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surfaceContainerHigh,
                                          width: 1,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            item.label,
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withAlpha(164),
                                              fontFamily: "Zenbones Mono",
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Icon(
                                                item.icon,
                                                color: item.color,
                                              ),
                                              Text(
                                                item.recordSize.toString(),
                                                style: GoogleFonts.spaceMono(
                                                  fontSize: 44,
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: 0.025,
                                                  height: 0.9,
                                                ),
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 44),
                        child: _dataTableControls(),
                      ),
                      const SizedBox(height: 12),
                      ValueListenableBuilder<String>(
                        valueListenable: _searchQuery,
                        builder: (context, searchQuery, _) {
                          return ValueListenableBuilder<String>(
                            valueListenable: _selectedSeverity,
                            builder: (context, selectedSeverity, _) {
                              final List<LogEntity> filteredLogs =
                                  state.logs.where((item) {
                                final matchesSeverity = selectedSeverity ==
                                        'all'
                                    ? true
                                    : item.logSeverity.name == selectedSeverity;

                                final matchesSearch = searchQuery.isEmpty
                                    ? true
                                    : item.message
                                        .toLowerCase()
                                        .contains(searchQuery.toLowerCase());

                                return matchesSeverity && matchesSearch;
                              }).toList();

                              final data = filteredLogs.map((item) {
                                final date = DateTime.parse(item.createdAt);
                                final formattedDate =
                                    DateFormat("yyyy-MM-dd HH:mm:ss")
                                        .format(date);

                                return LogDataTableCell(
                                  logSeverity: item.logSeverity,
                                  message: item.message,
                                  createdAt: formattedDate,
                                );
                              }).toList();

                              // Sort by date
                              data.sort(
                                  (a, b) => b.createdAt.compareTo(a.createdAt));

                              return LogsDataTable(
                                columns: columns,
                                data: data,
                                deviceHeight: deviceHeight,
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            }

            return SizedBox(
              height: deviceHeight,
              child: Center(
                  child: GeneralErrorWidget(
                      errorTitle: "An error has occurred",
                      errorMessage:
                          "Something has occurred during the data retrieval, please try again later.")),
            );
          }),
        );
      },
    );
  }

  List<LogsCard> _buildLogCards(List<LogEntity> logs) {
    int infoRecords =
        logs.where((item) => item.logSeverity.name == 'info').length;
    int warnRecords =
        logs.where((item) => item.logSeverity.name == 'warn').length;
    int errorRecords =
        logs.where((item) => item.logSeverity.name == 'error').length;
    int fatalRecords =
        logs.where((item) => item.logSeverity.name == 'fatal').length;

    return [
      LogsCard(
        label: "Info Records",
        color: Colors.blueAccent,
        icon: FluentIcons.info_24_regular,
        recordSize: infoRecords,
      ),
      LogsCard(
        label: "Warn Records",
        color: Colors.amberAccent,
        icon: FluentIcons.warning_24_regular,
        recordSize: warnRecords,
      ),
      LogsCard(
        label: "Error Records",
        color: Colors.redAccent,
        icon: FluentIcons.error_circle_24_regular,
        recordSize: errorRecords,
      ),
      LogsCard(
        label: "Fatal Records",
        color: Colors.indigoAccent,
        icon: FluentIcons.important_24_regular,
        recordSize: fatalRecords,
      ),
    ];
  }

  Widget _dataTableControls() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      spacing: 2,
      children: [
        SizedBox(
          height: 32,
          width: 286,
          child: TextFormField(
            onChanged: (value) {
              if (_debounce?.isActive ?? false) _debounce!.cancel();
              _debounce = Timer(const Duration(milliseconds: 300), () {
                _searchQuery.value = value;
              });
            },
            style: const TextStyle(
              fontSize: 12,
            ),
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              hintText: 'Search events',
              hintStyle: TextStyle(
                color: Theme.of(context).hintColor,
                fontSize: 12,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 1.5,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                  color: Theme.of(context)
                      .colorScheme
                      .outlineVariant
                      .withOpacity(0.5),
                  width: 1,
                ),
              ),
              filled: true,
              fillColor: Colors.transparent,
            ),
            cursorColor: Theme.of(context).colorScheme.primary,
            enabled: true,
            textAlignVertical: TextAlignVertical.center,
          ),
        ),
        OutlinedButton(
          onPressed: () {
            context.read<LogBloc>().add(LogList());
          },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            minimumSize: Size.zero,
            side: BorderSide(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              width: 1,
            ),
          ),
          child: Icon(
            FluentIcons.arrow_sync_24_regular,
            size: 18,
            color: Theme.of(context).colorScheme.onSurface.withAlpha(124),
          ),
        ),
        PopupMenuButton(
          onSelected: (value) {
            _selectedSeverity.value = value.toString();
          },
          itemBuilder: (context) => _severityOptions.map((item) {
            return PopupMenuItem(
              value: item,
              child: Text(
                item[0].toUpperCase() + item.substring(1),
                style: TextStyle(
                  fontFamily: "Zenbones Mono",
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
          child: ValueListenableBuilder<String>(
            valueListenable: _selectedSeverity,
            builder: (context, severity, child) {
              return DottedBorder(
                options: RoundedRectDottedBorderOptions(
                  dashPattern: [3, 3],
                  strokeWidth: 1,
                  padding: EdgeInsets.fromLTRB(16, 7, 16, 7),
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(64),
                  radius: Radius.circular(8),
                ),
                child: Text(
                  severity.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: "Zenbones Mono",
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.025,
                  ),
                ),
              );
            },
          ),
        ),
        // OutlinedButton(
        //   onPressed: () {},
        //   style: OutlinedButton.styleFrom(
        //     padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 8),
        //     shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadius.circular(6),
        //     ),
        //     minimumSize: Size.zero,
        //     side: BorderSide(
        //       color: Theme.of(context).colorScheme.surfaceContainerHigh,
        //       width: 1,
        //     ),
        //   ),
        //   child: Icon(
        //     FluentIcons.arrow_download_24_regular,
        //     size: 18,
        //     color: Theme.of(context).colorScheme.onSurface.withAlpha(124),
        //   ),
        // ),
      ],
    );
  }
}

class LogsCard {
  final String label;
  final Color color;
  final IconData icon;
  final int recordSize;

  LogsCard({
    required this.label,
    required this.color,
    required this.icon,
    required this.recordSize,
  });
}
