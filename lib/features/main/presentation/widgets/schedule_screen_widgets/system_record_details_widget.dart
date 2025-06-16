import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vermicomposting/core/common/widgets/error_widget.dart';
import 'package:flutter_vermicomposting/core/common/widgets/loader.dart';
import 'package:flutter_vermicomposting/core/common/widgets/toast_helper.dart';
import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:flutter_vermicomposting/core/utils/evaluate_soil_health.dart';
import 'package:flutter_vermicomposting/core/utils/extract_by_day.dart';
import 'package:flutter_vermicomposting/core/utils/string_extensions.dart';
import 'package:flutter_vermicomposting/features/logs/presentation/bloc/log_bloc.dart';
import 'package:flutter_vermicomposting/features/main/domain/entities/daily_records_cell.dart';
import 'package:flutter_vermicomposting/features/main/domain/entities/data_table_column.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/logs_widgets/logs_data_table.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class SystemRecordDetails extends StatefulWidget {
  final DailyRecordsCell currentRecord;

  const SystemRecordDetails({
    super.key,
    required this.currentRecord,
  });

  @override
  State<SystemRecordDetails> createState() => _SystemRecordDetailsState();
}

class _SystemRecordDetailsState extends State<SystemRecordDetails> {
  @override
  Widget build(BuildContext context) {
    final jsonData = widget.currentRecord.toJson();

    final List<String> targetKeys = [
      'temperature',
      'humidity',
      'soilMoisture',
      'nitrogen',
      'phosphorus',
      'potassium',
    ];

    final filteredEntries = jsonData.entries
        .where((entry) => targetKeys.contains(entry.key))
        .toList();

    final itemsPerRow = 3;
    final rowCount = (filteredEntries.length / itemsPerRow).ceil();

    final rows = List.generate(rowCount, (rowIndex) {
      final start = rowIndex * itemsPerRow;
      final end = (start + itemsPerRow).clamp(0, filteredEntries.length);
      return filteredEntries.sublist(start, end);
    });

    final result = evaluateSoilHealth(
      temperature: safeParseDouble(widget.currentRecord.temperature),
      humidity: safeParseDouble(widget.currentRecord.humidity),
      soilMoisture: safeParseDouble(widget.currentRecord.soilMoisture),
      nitrogen: safeParseDouble(widget.currentRecord.nitrogen),
      phosphorus: safeParseDouble(widget.currentRecord.phosphorus),
      potassium: safeParseDouble(widget.currentRecord.potassium),
    );

    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
                left: BorderSide(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
            ))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(24, 44, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Record Information",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              width: 1,
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHigh,
                            )),
                        child: Text(
                          widget.currentRecord.day,
                          style: GoogleFonts.spaceMono(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 164,
                    width: double.infinity,
                    child: SfRadialGauge(
                      axes: <RadialAxis>[
                        RadialAxis(
                          radiusFactor: 1,
                          startAngle: 180,
                          endAngle: 0,
                          minimum: 0,
                          maximum: 100,
                          showTicks: false,
                          showLabels: false,
                          canScaleToFit: true,
                          axisLineStyle: AxisLineStyle(
                            thicknessUnit: GaugeSizeUnit.factor,
                            thickness: 0.1,
                            color: Colors.transparent,
                          ),
                          ranges: [
                            GaugeRange(
                              startValue: result['score'] + 4,
                              endValue: 100,
                              startWidth: 15,
                              endWidth: 15,
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHigh,
                            ),
                            GaugeRange(
                              startValue: 0,
                              endValue: result['score'],
                              startWidth: 15,
                              endWidth: 15,
                              gradient:
                                  getGradientForValue(context, result['score']),
                            )
                          ],
                          annotations: <GaugeAnnotation>[
                            GaugeAnnotation(
                              verticalAlignment: GaugeAlignment.far,
                              horizontalAlignment: GaugeAlignment.center,
                              widget: Text(
                                result['status'].toString().toUpperCase(),
                                style: GoogleFonts.spaceMono(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              angle: 90,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Column(
                    spacing: 16,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: rows.map((rowEntries) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: rowEntries.map((entry) {
                          return Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  spacing: 4,
                                  children: [
                                    Container(
                                      height: 8,
                                      width: 8,
                                      margin: const EdgeInsets.only(right: 8),
                                      color: Colors.blueAccent,
                                    ),
                                    Text(
                                      entry.key.contains("temp")
                                          ? "${entry.value}°C"
                                          : "${entry.value}%",
                                      style: GoogleFonts.spaceMono(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 20),
                                  child: Text(
                                    entry.key.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Constants().textMutedFgDark,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.025,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    }).toList(),
                  )
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Bedding Overview",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      )),
                  const SizedBox(height: 20),
                  _currentRecordOverview(context, jsonData),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: _currentRecordLogs(
                  deviceHeight: MediaQuery.of(context).size.height),
            ),
          ],
        ),
      ),
    );
  }

  Widget _currentRecordOverview(
      BuildContext context, Map<String, dynamic> jsonData) {
    final Map<String, String> keyLabels = {
      'minTemp': 'Min value monitored',
      'maxTemp': 'Max value monitored',
      'minHumidity': 'Min value monitored',
      'maxHumidity': 'Max value monitored',
      'minSoilMoisture': 'Min value monitored',
      'maxSoilMoisture': 'Max value monitored',
    };

    final Map<String, List<String>> groupedKeys = {
      'Temperature': ['minTemp', 'maxTemp'],
      'Humidity': ['minHumidity', 'maxHumidity'],
      'Soil Moisture': ['minSoilMoisture', 'maxSoilMoisture'],
    };

    List<Widget> buildGroup(String title, List<String> keys) {
      final entries = keys
          .where((key) => jsonData.containsKey(key))
          .map((key) => MapEntry(key, jsonData[key]))
          .toList();

      if (entries.isEmpty) return [];

      return [
        Column(
          spacing: 6,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                )),
            Column(
              spacing: 2.5,
              children: entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 8,
                            width: 8,
                            margin: const EdgeInsets.only(right: 8),
                            color: Colors.blueAccent,
                          ),
                          Text(
                            keyLabels[entry.key] ?? entry.key,
                            style: TextStyle(
                              color: Constants().textMutedFgDark,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        entry.key.contains("Temp")
                            ? "${entry.value}°C"
                            : "${entry.value}%",
                        style: GoogleFonts.spaceMono(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        )
      ];
    }

    return Column(
      spacing: 14,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: groupedKeys.entries
          .expand((group) => buildGroup(group.key, group.value))
          .toList(),
    );
  }

  Widget _currentRecordLogs({required double deviceHeight}) {
    final toastHelper = ToastHelper(context);

    final List<DataTableColumn> columns = [
      DataTableColumn(label: "Log Level"),
      DataTableColumn(label: "Timestamp"),
      DataTableColumn(label: "Message"),
    ];

    return BlocBuilder<LogBloc, LogState>(builder: (context, state) {
      if (state is LogsLoading) {
        return Center(child: Loader());
      } else if (state is LogsFailure) {
        toastHelper.show(
          title: "An error has occurred during retrieval",
          description: state.error,
          isError: true,
        );
      } else if (state is LogsListSuccess) {
        final filteredLogs = state.logs.where((log) {
          final day = extractDay(log.createdAt);

          final currentDayMatched = day == widget.currentRecord.day;

          return currentDayMatched;
        });

        final data = filteredLogs.map((item) {
          final date = DateTime.parse(item.createdAt);
          final formattedDate = DateFormat("HH:mm:ss").format(date);

          return LogDataTableCell(
            logSeverity: item.logSeverity,
            message: item.message,
            createdAt: formattedDate,
          );
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Activity Log",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                )),
            const SizedBox(height: 16),
            LogsDataTable(
              padding: 0,
              columns: columns,
              data: data,
              deviceHeight: deviceHeight,
            ),
          ],
        );
      }

      return SizedBox(
        child: Center(
            child: GeneralErrorWidget(
                errorTitle: "An error has occurred",
                errorMessage:
                    "Something has occurred during the data retrieval, please try again later.")),
      );
    });
  }
}

SweepGradient getGradientForValue(BuildContext context, double value) {
  if (value <= 40) {
    return const SweepGradient(
      colors: [Colors.redAccent],
      stops: [0.0],
    );
  } else if (value <= 70) {
    return const SweepGradient(
      colors: [Colors.redAccent, Colors.amberAccent],
      stops: [0.0, 1.0],
    );
  } else {
    return const SweepGradient(
      colors: [Colors.redAccent, Colors.amberAccent, Colors.green],
      stops: [0.0, 0.5, 1.0],
    );
  }
}
