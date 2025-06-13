import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/core/common/widgets/app_background.dart';
import 'package:flutter_vermicomposting/core/common/widgets/glassmorphism.dart';
import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/main_chart.dart';
import 'package:intl/intl.dart';

class SystemChartCard<T> extends StatefulWidget {
  final SystemChartDetails<T> chartData;

  const SystemChartCard({
    super.key,
    required this.chartData,
  });

  @override
  State<SystemChartCard<T>> createState() => SystemChartCardState<T>();
}

class SystemChartCardState<T> extends State<SystemChartCard<T>> {
  DateTimeRange? _selectedDateRange;

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;

    final rawGroups = widget.chartData.groupedReadings;
    final selector = widget.chartData.valueSelector;

    final Map<String, double> averagedByDay = {};
    final dateFormat = DateFormat('yyyy-MM-dd');

    rawGroups.forEach((dateLabel, readingsList) {
      final day = dateFormat.parse(dateLabel);

      if (_selectedDateRange != null) {
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
        if (day.isBefore(start) || day.isAfter(end)) return;
      }

      final values =
          readingsList.map(selector).where((v) => v != null).cast<double>();
      if (values.isNotEmpty) {
        final sum = values.reduce((a, b) => a + b);
        averagedByDay[dateLabel] = sum / values.length;
      }
    });

    final sortedEntries = averagedByDay.entries.toList()
      ..sort(
          (a, b) => dateFormat.parse(a.key).compareTo(dateFormat.parse(b.key)));

    final bool isSingleDayRange = _selectedDateRange != null &&
        _selectedDateRange!.start.year == _selectedDateRange!.end.year &&
        _selectedDateRange!.start.month == _selectedDateRange!.end.month &&
        _selectedDateRange!.start.day == _selectedDateRange!.end.day;

    final List<ChartData> chartData = sortedEntries.map((entry) {
      final date = dateFormat.parse(entry.key);
      final label = isSingleDayRange
          ? DateFormat('ha').format(date)
          : DateFormat('MMM d').format(date);
      return ChartData(label, entry.value);
    }).toList();

    return Glassmorphism(
      blur: 64,
      opacity: 0.3,
      child: AppBackground(
        child: Container(
          width: deviceWidth * 0.4,
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withAlpha(124),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              width: 1,
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.chartData.label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.025,
                    ),
                  ),
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
                      padding: const EdgeInsets.symmetric(
                          vertical: 7, horizontal: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      minimumSize: Size.zero,
                      side: BorderSide(
                        color:
                            Theme.of(context).colorScheme.surfaceContainerHigh,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          FluentIcons.clock_24_regular,
                          size: 16,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withAlpha(124),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _selectedDateRange != null
                              ? DateFormat('MMM d')
                                  .format(_selectedDateRange!.start)
                              : 'All time',
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
              const SizedBox(height: 32),
              MainChart(
                title: widget.chartData.label == "Temperature"
                    ? "Measured °C"
                    : "Percentage(%)",
                mainWidth: 1,
                sensorChart: chartData,
                chartSize: 168,
                color: widget.chartData.color,
                showAxisLine: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SystemChartDetails<T> {
  final String label;
  final Color color;

  final Map<String, List<T>> groupedReadings;

  final double Function(T) valueSelector;

  const SystemChartDetails({
    required this.label,
    required this.color,
    required this.groupedReadings,
    required this.valueSelector,
  });
}
