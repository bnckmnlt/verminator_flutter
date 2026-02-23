import 'package:data_table_2/data_table_2.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_vermicomposting/core/common/entities/layer_classes.dart';
import 'package:flutter_vermicomposting/core/common/widgets/empty_display_widget.dart';
import 'package:flutter_vermicomposting/core/utils/extract_by_day.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/domain/entities/compost_schedule.dart';
import 'package:flutter_vermicomposting/features/main/domain/entities/data_table_column.dart';
import 'package:flutter_vermicomposting/features/sensor_reading/domain/entity/sensor_reading.dart';
import 'package:flutter_vermicomposting/features/worm_activity/domain/entity/worm_activity.dart';
import 'package:get_it/get_it.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ScheduleDataTableWidget extends StatefulWidget {
  final CompostSchedule compostSchedule;
  final List<SensorReading> sensorReadingList;
  final List<WormActivity> wormActivityList;

  const ScheduleDataTableWidget({
    super.key,
    required this.compostSchedule,
    required this.sensorReadingList,
    required this.wormActivityList,
  });

  @override
  State<ScheduleDataTableWidget> createState() =>
      _ScheduleDataTableWidgetState();
}

class _ScheduleDataTableWidgetState extends State<ScheduleDataTableWidget> {
  late SupabaseClient _supabaseClient;
  late CompostSchedule _compostSchedule;

  bool _isHourlyView = false;
  String _selectedDate = "";
  List<Reading> datasource = [];
  bool _isAscending = false;
  int compostingDays = 0;

  final List<DataTableColumn> columns = [
    DataTableColumn(label: "Date"),
    DataTableColumn(label: "Temperature"),
    DataTableColumn(label: "Humidity"),
    DataTableColumn(label: "Soil Moisture"),
    DataTableColumn(label: "Nitrogen"),
    DataTableColumn(label: "Phosphorus"),
    DataTableColumn(label: "Potassium"),
    DataTableColumn(label: "Worm Activity"),
    DataTableColumn(label: "Activity Snapshot"),
  ];

  @override
  void initState() {
    super.initState();

    _supabaseClient = GetIt.I<SupabaseClient>();
    _compostSchedule = widget.compostSchedule;
  }

  @override
  Widget build(BuildContext context) {
    _refreshDatasource();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: _buildTableHeader(),
        ),
        Expanded(
          flex: 4,
          child: _buildDataTable(),
        ),
      ],
    );
  }

  Widget _buildTableHeader() {
    TextStyle mutedTextStyle() {
      return TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withAlpha(164));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
            child: Container(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                spacing: 14,
                children: [
                  if (_isHourlyView)
                    IconButton(
                      key: ValueKey(
                          'back_btn_${DateTime.now().millisecondsSinceEpoch}'),
                      onPressed: () => setState(() {
                        _isHourlyView = false;
                      }),
                      icon: Icon(FluentIcons.arrow_left_24_filled),
                    )
                        .animate()
                        .fadeIn(duration: 250.ms)
                        .slideX(
                          duration: 350.ms,
                          begin: -0.5,
                          end: 0,
                          curve: Curves.easeOutBack,
                        )
                        .scale(
                          duration: 350.ms,
                          begin: Offset(0.8, 0.8),
                          end: Offset(1.0, 1.0),
                          curve: Curves.easeOutBack,
                        ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Composting Data Table",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _isHourlyView
                            ? "Showing hourly averages for $_selectedDate"
                            : "Showing daily averages for the current month",
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withAlpha(164),
                          fontSize: 16,
                        ),
                      )
                    ],
                  ),
                ],
              ),
              IconButton(
                onPressed: () => setState(() {
                  _isAscending = !_isAscending;
                  _refreshDatasource();
                }),
                icon: Icon(_isAscending
                    ? FluentIcons.text_sort_ascending_24_filled
                    : FluentIcons.text_sort_descending_24_filled),
              ),
            ],
          ),
        )),
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 44,
                  ),
                  decoration: BoxDecoration(
                      border: Border(
                    left: BorderSide(
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    ),
                  )),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Soil Produced",
                          style: mutedTextStyle(),
                        ),
                        Text(
                          "${_compostSchedule.compostProduced} Kilogram",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 44,
                  ),
                  decoration: BoxDecoration(
                      border: Border(
                    left: BorderSide(
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    ),
                    right: BorderSide(
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    ),
                  )),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Tea Produced",
                          style: mutedTextStyle(),
                        ),
                        Text(
                          "${_compostSchedule.juiceProduced} Liter",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 44,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Days composting",
                          style: mutedTextStyle(),
                        ),
                        Text(
                          "$compostingDays days",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  DataTable2 _buildDataTable() {
    double tableWidth = MediaQuery.sizeOf(context).width * 1.10;

    TextStyle columnTextStyle() {
      return TextStyle(
        fontSize: 16,
        letterSpacing: 0.025,
      );
    }

    return DataTable2(
      minWidth: tableWidth,
      horizontalMargin: 44,
      headingRowHeight: 44,
      dataRowHeight: 54,
      headingTextStyle: columnTextStyle().copyWith(
        fontWeight: FontWeight.w600,
      ),
      dividerThickness: 0,
      isHorizontalScrollBarVisible: false,
      isVerticalScrollBarVisible: false,
      border: TableBorder(
        horizontalInside: BorderSide.none,
      ),
      headingRowDecoration: BoxDecoration(
        border: Border(
            top: BorderSide(
                color: Theme.of(context).colorScheme.surfaceContainerHigh),
            bottom: BorderSide(
                color: Theme.of(context).colorScheme.surfaceContainerHigh)),
      ),
      columns: columns
          .map((item) => DataColumn2(
                label: Text(item.label),
                size: ColumnSize.L,
              ))
          .toList(),
      rows: _buildDataRows(),
      empty: EmptyDisplayWidget(
        icon: FluentIcons.cloud_archive_24_regular,
        title: "No results found",
        description: "Try another search or adjust the filters",
      ),
    );
  }

  List<DataRow> _buildDataRows() {
    TextStyle rowTextStyle() {
      return TextStyle(
        fontSize: 16,
      );
    }

    Widget nutrientSymbolWidget(String symbol) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 1.5, horizontal: 5),
        decoration: BoxDecoration(
          border: Border.all(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              width: 1.5),
          shape: BoxShape.circle,
        ),
        child: Text(
          symbol,
          style: rowTextStyle().copyWith(
            color: Theme.of(context).colorScheme.onSurface.withAlpha(224),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    String extractZone(String input) {
      if (input.toLowerCase().startsWith("zone ")) {
        return input.substring(5).trim();
      }
      return input.trim();
    }

    return datasource.map((item) {
      return DataRow(
        cells: [
          DataCell(
            InkWell(
              splashFactory: NoSplash.splashFactory,
              onTap: !_isHourlyView
                  ? () => setState(() {
                        _isHourlyView = true;
                        _selectedDate = item.date;
                      })
                  : null,
              child: Text(
                item.date,
                style: rowTextStyle().copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
                .animate(
                    delay:
                        Duration(milliseconds: datasource.indexOf(item) * 50))
                .fadeIn(duration: 500.ms, curve: Curves.easeOut)
                .slideX(
                  duration: 700.ms,
                  begin: 0.1,
                  end: 0,
                  curve: Curves.easeOutCubic,
                ),
          ),
          DataCell(Text(
            "${item.temperature.toStringAsFixed(0)}°C",
            style: rowTextStyle(),
          )),
          DataCell(Text(
            "${item.humidity.toStringAsFixed(0)}°C",
            style: rowTextStyle(),
          )),
          DataCell(Text(
            "${item.soilMoisture.toStringAsFixed(0)}%",
            style: rowTextStyle(),
          )),
          DataCell(Row(
            spacing: 6,
            children: [
              nutrientSymbolWidget("N"),
              Text(
                "${item.nitrogen.toStringAsFixed(1)}%",
                style: rowTextStyle(),
              ),
            ],
          )),
          DataCell(Row(
            spacing: 6,
            children: [
              nutrientSymbolWidget("P"),
              Text(
                "${item.phosphorus.toStringAsFixed(1)}%",
                style: rowTextStyle(),
              ),
            ],
          )),
          DataCell(Row(
            spacing: 6,
            children: [
              nutrientSymbolWidget("K"),
              Text(
                "${item.potassium.toStringAsFixed(1)}%",
                style: rowTextStyle(),
              ),
            ],
          )),
          DataCell(
            Container(
              padding: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: RichText(
                text: TextSpan(
                  style: rowTextStyle().copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color:
                        Theme.of(context).colorScheme.onSurface.withAlpha(204),
                  ),
                  children: [
                    const TextSpan(text: ""),
                    TextSpan(
                      text: extractZone(item.activeZone),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          DataCell(
            ElevatedButton(
              onPressed: item.imgSrc.isEmpty
                  ? null
                  : () {
                      showDialog(
                        context: context,
                        builder: (context) => Dialog(
                            backgroundColor: Colors.transparent,
                            insetPadding: EdgeInsets.all(0),
                            child: InstaImageViewer(
                              backgroundIsTransparent: true,
                              child: Image(
                                isAntiAlias: true,
                                errorBuilder: (context, error, stackTrace) {
                                  return EmptyDisplayWidget(
                                    icon:
                                        FluentIcons.image_prohibited_24_regular,
                                    title: "Unable to Display File",
                                    description:
                                        "The requested source file could not be loaded. It may be missing or there was an error accessing it.",
                                  );
                                },
                                image: Image.network(
                                  item.imgSrc,
                                  isAntiAlias: true,
                                ).image,
                              ),
                            )
                                .animate()
                                .fade(
                                  duration: 500.ms,
                                  curve: Curves.easeOut,
                                )
                                .scale(
                                  duration: 500.ms,
                                  curve: Curves.easeOutBack,
                                  begin: const Offset(0.9, 0.9),
                                  end: const Offset(1.0, 1.0),
                                )
                                .slideY(
                                  duration: 600.ms,
                                  curve: Curves.easeOutCubic,
                                  begin: 0.05,
                                  end: 0,
                                )),
                      );
                    },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                minimumSize: Size.zero,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                foregroundColor: Theme.of(context).colorScheme.onSurface,
                side: BorderSide(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 18),
                textStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: Text("View image"),
            ),
          ),
        ],
      );
    }).toList();
  }

  void _refreshDatasource() {
    datasource = _isHourlyView
        ? parseToAverage(
            _supabaseClient, widget.sensorReadingList, widget.wormActivityList,
            selectedDate: _selectedDate, ascending: _isAscending)
        : parseToAverage(
            _supabaseClient, widget.sensorReadingList, widget.wormActivityList,
            ascending: _isAscending);

    if (!_isHourlyView) {
      setState(() {
        compostingDays = datasource.length;
      });
    }
  }
}

List<Reading> parseToAverage(
  SupabaseClient supabaseClient,
  List<SensorReading> readings,
  List<WormActivity> wormActivities, {
  String? selectedDate,
  bool ascending = true,
}) {
  final isHourly = selectedDate != null;
  final allDates = <String>{};
  final readingsByDate = <String, List<SensorReading>>{};
  final wormsByDate = <String, List<WormActivity>>{};
  final dateMapping = <String, DateTime>{};

  final filteredReadings = isHourly
      ? readings
          .where(
              (r) => extractDay(r.createdAt, format: "MMMM d") == selectedDate)
          .toList()
      : readings;

  final filteredWorms = isHourly
      ? wormActivities
          .where(
              (w) => extractDay(w.createdAt, format: "MMMM d") == selectedDate)
          .toList()
      : wormActivities;

  String dateKey(String createdAt) => isHourly
      ? extractHour(DateTime.parse(createdAt))
      : extractDay(createdAt, format: "MMMM d");

  for (final r in filteredReadings) {
    final dt = DateTime.parse(r.createdAt);
    final key = dateKey(r.createdAt);
    allDates.add(key);
    readingsByDate.putIfAbsent(key, () => []).add(r);
    dateMapping.putIfAbsent(key, () => dt);
  }

  for (final w in filteredWorms) {
    final dt = DateTime.parse(w.createdAt);
    final key = dateKey(w.createdAt);
    allDates.add(key);
    wormsByDate.putIfAbsent(key, () => []).add(w);
    dateMapping.putIfAbsent(key, () => dt);
  }

  double avgSensor(List<SensorReading> sensors, SystemLayer layer,
      double Function(dynamic) getValue) {
    final validValues = <double>[];

    for (final sensor in sensors.where((r) => r.layer == layer)) {
      try {
        final value = getValue(sensor);
        if (value != null && value is double) {
          validValues.add(value);
        }
      } catch (e) {
        continue;
      }
    }

    return validValues.isEmpty
        ? 0
        : validValues.reduce((a, b) => a + b) / validValues.length;
  }

  String getMostCommonActivityLevel(List<WormActivity> wormList) {
    if (wormList.isEmpty) return "Low";

    final activityCounts = <String, int>{};
    for (final worm in wormList) {
      final level = worm.activityLevel.name;
      activityCounts[level] = (activityCounts[level] ?? 0) + 1;
    }

    var maxCount = 0;
    var mostCommon = "Low";
    activityCounts.forEach((level, count) {
      if (count > maxCount) {
        maxCount = count;
        mostCommon = level;
      }
    });

    return mostCommon;
  }

  String getMostRecentImage(List<WormActivity> wormList) {
    if (wormList.isEmpty) return "";

    final sorted = wormList.toList()
      ..sort((a, b) =>
          DateTime.parse(b.createdAt).compareTo(DateTime.parse(a.createdAt)));

    final mostRecent = sorted.firstWhere(
      (w) => w.filePath != null && w.filePath!.isNotEmpty,
      orElse: () => sorted.first,
    );

    final rawPath = mostRecent.filePath ?? "";
    return rawPath.isNotEmpty
        ? supabaseClient.storage.from('image').getPublicUrl(rawPath)
        : "";
  }

  final results = allDates.map((date) {
    final sensorList = readingsByDate[date] ?? [];
    final wormList = wormsByDate[date] ?? [];

    final temperature = avgSensor(sensorList, SystemLayer.bedding,
        (r) => r.asBeddingReading?.temperature.value.toDouble());
    final humidity = avgSensor(sensorList, SystemLayer.bedding,
        (r) => r.asBeddingReading?.humidity.value.toDouble());
    final soilMoisture = avgSensor(sensorList, SystemLayer.bedding,
        (r) => r.asBeddingReading?.soilMoisture.value.toDouble());
    final nitrogen = avgSensor(sensorList, SystemLayer.compost,
        (r) => r.asCompostReading?.npk.nitrogen.toDouble());
    final phosphorus = avgSensor(sensorList, SystemLayer.compost,
        (r) => r.asCompostReading?.npk.phosphorus.toDouble());
    final potassium = avgSensor(sensorList, SystemLayer.compost,
        (r) => r.asCompostReading?.npk.potassium.toDouble());

    final activeZone = getMostCommonActivityLevel(wormList);
    final publicUrl = getMostRecentImage(wormList);

    return Reading(
      date: date,
      temperature: temperature,
      humidity: humidity,
      soilMoisture: soilMoisture,
      nitrogen: nitrogen,
      phosphorus: phosphorus,
      potassium: potassium,
      activeZone: activeZone.toUpperCase(),
      imgSrc: publicUrl,
    );
  }).toList();

  results.sort((a, b) {
    final comparison = isHourly
        ? _compareHours(a.date, b.date)
        : dateMapping[a.date]!.compareTo(dateMapping[b.date]!);
    return ascending ? comparison : -comparison;
  });

  return results;
}

String extractHour(DateTime dateTime) {
  final hour = dateTime.hour;
  final period = hour >= 12 ? 'PM' : 'AM';
  final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
  return '$displayHour $period';
}

int _compareHours(String a, String b) {
  int hourValue(String hourStr) {
    final parts = hourStr.split(' ');
    final hour = int.parse(parts[0]);
    final isPM = parts[1] == 'PM';
    return hour == 12 ? (isPM ? 12 : 0) : (isPM ? hour + 12 : hour);
  }

  return hourValue(a).compareTo(hourValue(b));
}
