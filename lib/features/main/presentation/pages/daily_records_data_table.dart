import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vermicomposting/core/common/entities/layer_classes.dart';
import 'package:flutter_vermicomposting/core/common/widgets/data_table_sticky.dart';
import 'package:flutter_vermicomposting/core/utils/extract_by_day.dart';
import 'package:flutter_vermicomposting/core/utils/get_min_max.dart';
import 'package:flutter_vermicomposting/features/main/domain/entities/daily_records_cell.dart';
import 'package:flutter_vermicomposting/features/main/domain/entities/data_table_column.dart';
import 'package:flutter_vermicomposting/features/sensor_reading/domain/entity/sensor_reading.dart';
import 'package:flutter_vermicomposting/features/sensor_reading/presentation/bloc/sensor_reading_bloc.dart';
import 'package:flutter_vermicomposting/features/worm_activity/domain/entity/worm_activity.dart';
import 'package:flutter_vermicomposting/features/worm_activity/presentation/bloc/worm_activity_bloc.dart';
import 'package:intl/intl.dart';

class DailyRecordsDataTable extends StatefulWidget {
  final FocusNode tableFocusNode;
  final void Function(DailyRecordsCell) onShowDetails;
  final List<SensorReading> sensorReadings;
  final List<WormActivity> wormActivities;

  const DailyRecordsDataTable({
    super.key,
    required this.tableFocusNode,
    required this.sensorReadings,
    required this.wormActivities,
    required this.onShowDetails,
  });

  @override
  State<DailyRecordsDataTable> createState() => _DailyRecordsDataTableState();
}

class _DailyRecordsDataTableState extends State<DailyRecordsDataTable> {
  DateTimeRange? _selectedDateRange;

  late List<DailyRecordsCell> _dataSource;

  final List<DataTableColumn> columns = [
    DataTableColumn(label: "Day"),
    DataTableColumn(label: "Temperature"),
    DataTableColumn(label: "Humidity"),
    DataTableColumn(label: "Soil Moisture"),
    DataTableColumn(label: "Nitrogen"),
    DataTableColumn(label: "Phosphorus"),
    DataTableColumn(label: "Potassium"),
    DataTableColumn(label: "Worm Activity"),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bool isSingleDayRange = _selectedDateRange != null &&
        _selectedDateRange!.start.year == _selectedDateRange!.end.year &&
        _selectedDateRange!.start.month == _selectedDateRange!.end.month &&
        _selectedDateRange!.start.day == _selectedDateRange!.end.day;

    final Map<String, List<BeddingReading>> beddingReadingsByTimeUnit = {};
    final Map<String, List<CompostReading>> compostReadingsByTimeUnit = {};

    for (final reading in widget.sensorReadings) {
      final String timeLabel;
      if (isSingleDayRange) {
        final date = DateTime.parse(reading.createdAt);
        timeLabel = DateFormat('yyyy-MM-dd HH').format(date);
      } else {
        timeLabel = extractDay(reading.createdAt, format: "yyyy-MM-dd");
      }

      if (reading.layer == SystemLayer.bedding) {
        final bedding = reading.asBeddingReading;
        if (bedding != null) {
          beddingReadingsByTimeUnit
              .putIfAbsent(timeLabel, () => [])
              .add(bedding);
        }
      } else if (reading.layer == SystemLayer.compost) {
        final compost = reading.asCompostReading;
        if (compost != null) {
          compostReadingsByTimeUnit
              .putIfAbsent(timeLabel, () => [])
              .add(compost);
        }
      }
    }

    final Map<String, WormActivity> wormActivitiesByTimeUnit = {};
    for (var w in widget.wormActivities) {
      final String timeLabel;
      if (isSingleDayRange) {
        final date = DateTime.parse(w.createdAt);
        timeLabel = DateFormat('yyyy-MM-dd HH').format(date);
      } else {
        timeLabel = extractDay(w.createdAt, format: "yyyy-MM-dd");
      }
      wormActivitiesByTimeUnit[timeLabel] = w;
    }

    final allTimeRecords = <String>{
      ...beddingReadingsByTimeUnit.keys,
      ...compostReadingsByTimeUnit.keys,
      ...wormActivitiesByTimeUnit.keys
    };

    final filteredTimeRecords = allTimeRecords.where((timeUnit) {
      if (_selectedDateRange == null) {
        return true;
      }

      final DateTime date;
      if (isSingleDayRange) {
        date = DateTime.parse(timeUnit + ":00:00");
      } else {
        date = DateTime.parse(timeUnit);
      }

      final start = DateTime(
        _selectedDateRange!.start.year,
        _selectedDateRange!.start.month,
        _selectedDateRange!.start.day,
      );
      final end = DateTime(
        _selectedDateRange!.end.year,
        _selectedDateRange!.end.month,
        _selectedDateRange!.end.day,
        23,
        59,
        59,
        999,
      );

      return !date.isBefore(start) && !date.isAfter(end);
    }).toList();

    filteredTimeRecords.sort((a, b) {
      return a.compareTo(b);
    });

    final List<DailyRecordsCell> mappedRecords =
        filteredTimeRecords.map((timeUnit) {
      final bed = beddingReadingsByTimeUnit[timeUnit] ?? [];
      final comp = compostReadingsByTimeUnit[timeUnit] ?? [];

      double avg(List<num> nums) =>
          nums.isEmpty ? 0.0 : nums.reduce((a, b) => a + b) / nums.length;

      final tempValues = bed.map((r) => r.temperature.value).toList();
      final avgTemp = tempValues.isNotEmpty ? avg(tempValues) : null;
      final maxTemp = getMax(tempValues);
      final minTemp = getMin(tempValues);

      final humidityValues = bed.map((r) => r.humidity.value).toList();
      final avgHumidity =
          humidityValues.isNotEmpty ? avg(humidityValues) : null;
      final maxHumidity = getMax(humidityValues);
      final minHumidity = getMin(humidityValues);

      final soilMoistureValues = bed.map((r) => r.soilMoisture.value).toList();
      final avgSoilMoisture =
          soilMoistureValues.isNotEmpty ? avg(soilMoistureValues) : null;
      final minSoilMoisture = getMin(soilMoistureValues);
      final maxSoilMoisture = getMax(soilMoistureValues);

      final nitrogen = avg(comp.map((r) => r.npk.nitrogen).toList());
      final phosphorus = avg(comp.map((r) => r.npk.phosphorus).toList());
      final potassium = avg(comp.map((r) => r.npk.potassium).toList());

      final wormActivity = (wormActivitiesByTimeUnit[timeUnit]
              ?.getActiveZoneLabel(
                  wormActivitiesByTimeUnit[timeUnit]!.zones)) ??
          "Unknown";

      final String displayLabel;
      if (isSingleDayRange) {
        final date = DateTime.parse("$timeUnit:00:00");
        displayLabel = DateFormat('ha').format(date);
      } else {
        final date = DateTime.parse(timeUnit);
        displayLabel = DateFormat('MMM d').format(date);
      }

      return DailyRecordsCell(
        day: displayLabel,
        temperature: formatDouble(avgTemp),
        minTemp: formatDouble(minTemp),
        maxTemp: formatDouble(maxTemp),
        humidity: formatDouble(avgHumidity),
        minHumidity: formatDouble(minHumidity),
        maxHumidity: formatDouble(maxHumidity),
        soilMoisture: formatDouble(avgSoilMoisture),
        minSoilMoisture: formatDouble(minSoilMoisture),
        maxSoilMoisture: formatDouble(maxSoilMoisture),
        nitrogen: comp.isNotEmpty
            ? (nitrogen == 0 ? "-" : formatDouble(nitrogen))
            : "-",
        phosphorus: comp.isNotEmpty
            ? (phosphorus == 0 ? "-" : formatDouble(phosphorus))
            : "-",
        potassium: comp.isNotEmpty
            ? (potassium == 0 ? "-" : formatDouble(potassium))
            : "-",
        wormActivity: wormActivity.toString(),
      );
    }).toList();

    _dataSource = mappedRecords;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Daily Records",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              "Here's a list of the system records for the month!",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(124),
              ),
            )
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            SizedBox(
              height: 32,
              width: 250,
              child: TextFormField(
                style: const TextStyle(
                  fontSize: 12,
                ),
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  hintText: 'Filter conditions...',
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
            const SizedBox(width: 2),
            OutlinedButton(
              onPressed: () {
                context.read<SensorReadingBloc>().add(SensorReadingList());
                context.read<WormActivityBloc>().add(WormActivityList());
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
            const SizedBox(width: 2),
            OutlinedButton(
              onPressed: () async {
                final pickedRange = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  initialDateRange: _selectedDateRange,
                  initialEntryMode: DatePickerEntryMode.inputOnly,
                  useRootNavigator: false,
                );
                if (pickedRange != null) {
                  setState(() {
                    _selectedDateRange = pickedRange;
                  });
                }
              },
              style: OutlinedButton.styleFrom(
                backgroundColor:
                    Theme.of(context).colorScheme.surface.withAlpha(124),
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
              child: Row(
                children: [
                  Icon(
                    FluentIcons.clock_24_regular,
                    size: 16,
                    color:
                        Theme.of(context).colorScheme.onSurface.withAlpha(124),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _selectedDateRange != null
                        ? "${DateFormat('MMM d').format(_selectedDateRange!.start)} - ${DateFormat('MMM d').format(_selectedDateRange!.end)}"
                        : 'Last hour',
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withAlpha(124),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.025,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
            ),
          ),
          child: SizedBox(
            height: 460,
            child: DataTableSticky(
              columns: columns,
              data: _dataSource,
              tableFocusNode: widget.tableFocusNode,
              onShowDetails: widget.onShowDetails,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
