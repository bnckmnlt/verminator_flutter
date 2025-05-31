import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vermicomposting/core/common/widgets/data_table_sticky.dart';
import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:flutter_vermicomposting/features/main/domain/entities/daily_records_cell.dart';
import 'package:flutter_vermicomposting/features/main/domain/entities/data_table_column.dart';
import 'package:flutter_vermicomposting/features/sensor_reading/presentation/bloc/sensor_reading_bloc.dart';
import 'package:flutter_vermicomposting/features/worm_activity/presentation/bloc/worm_activity_bloc.dart';

class DailyRecordsDataTable extends StatefulWidget {
  final List<DailyRecordsCell> data;

  const DailyRecordsDataTable({
    super.key,
    required this.data,
  });

  @override
  State<DailyRecordsDataTable> createState() => _DailyRecordsDataTableState();
}

class _DailyRecordsDataTableState extends State<DailyRecordsDataTable> {
  DateTime selectedDate = DateTime.now();

  late List<DailyRecordsCell> _dataSource;

  final List<DataTableColumn> columns = [
    DataTableColumn(label: "Day"),
    DataTableColumn(label: "Condition"),
    DataTableColumn(label: "Temperature"),
    DataTableColumn(label: "Humidity"),
    DataTableColumn(label: "Soil Moisture"),
    DataTableColumn(label: "Nitrogen"),
    DataTableColumn(label: "Potassium"),
    DataTableColumn(label: "Phosphorus"),
    DataTableColumn(label: "Worm Activity"),
  ];

  @override
  void initState() {
    super.initState();

    _dataSource = widget.data.map((item) {
      return DailyRecordsCell(
        day: item.day,
        condition: SensorStatus.good,
        temperature: item.temperature,
        humidity: item.humidity,
        soilMoisture: item.soilMoisture,
        nitrogen: item.nitrogen,
        phosphorus: item.phosphorus,
        potassium: item.potassium,
        wormActivity: item.wormActivity,
      );
    }).toList();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.isAfter(now) ? now : selectedDate,
      firstDate: DateTime(2024),
      lastDate: now,
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
              onPressed: () {
                _selectDate(context);
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
                    'Last hour',
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
          // constrain the height
          child: SizedBox(
            height: 460,
            child: DataTableSticky(
              columns: columns,
              data: _dataSource,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
