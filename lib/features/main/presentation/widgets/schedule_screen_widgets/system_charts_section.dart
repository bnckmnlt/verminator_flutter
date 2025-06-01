import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/core/common/entities/layer_classes.dart';
import 'package:flutter_vermicomposting/core/utils/extract_by_day.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/schedule_screen_widgets/system_chart_card.dart';
import 'package:flutter_vermicomposting/features/sensor_reading/domain/entity/sensor_reading.dart';

class SystemChartsSection extends StatefulWidget {
  final List<SensorReading> sensorReadings;

  const SystemChartsSection({
    super.key,
    required this.sensorReadings,
  });

  @override
  State<SystemChartsSection> createState() => _ScheduleChartsSectionState();
}

class _ScheduleChartsSectionState extends State<SystemChartsSection> {
  @override
  Widget build(BuildContext context) {
    final Map<String, List<BeddingReading>> readingsByDayBedding = {};
    final Map<String, List<CompostReading>> readingsByDayCompost = {};

    for (final reading in widget.sensorReadings) {
      final dateLabel = extractDay(reading.createdAt, format: "yyyy-MM-dd");
      if (reading.layer == SystemLayer.bedding) {
        final bedding = reading.asBeddingReading;
        if (bedding != null) {
          readingsByDayBedding.putIfAbsent(dateLabel, () => []).add(bedding);
        }
      } else if (reading.layer == SystemLayer.compost) {
        final compost = reading.asCompostReading;
        if (compost != null) {
          readingsByDayCompost.putIfAbsent(dateLabel, () => []).add(compost);
        }
      }
    }

    final beddingConditionCharts = [
      SystemChartDetails<BeddingReading>(
        label: 'Temperature',
        color: Color(0xff2563EB),
        groupedReadings: readingsByDayBedding,
        valueSelector: (b) => b.temperature.value.toDouble(),
      ),
      SystemChartDetails<BeddingReading>(
        label: 'Humidity',
        color: Color(0xff3B86F7),
        groupedReadings: readingsByDayBedding,
        valueSelector: (b) => b.humidity.value.toDouble(),
      ),
      SystemChartDetails<BeddingReading>(
        label: 'Soil Moisture',
        color: Color(0xff90C7FE),
        groupedReadings: readingsByDayBedding,
        valueSelector: (b) => b.soilMoisture.value.toDouble(),
      ),
      SystemChartDetails<CompostReading>(
        label: 'Nitrogen',
        color: Color(0xff2563EB),
        groupedReadings: readingsByDayCompost,
        valueSelector: (b) => b.npk.nitrogen.toDouble(),
      ),
      SystemChartDetails<CompostReading>(
        label: 'Phosphorus',
        color: Color(0xff3B86F7),
        groupedReadings: readingsByDayCompost,
        valueSelector: (b) => b.npk.phosphorus.toDouble(),
      ),
      SystemChartDetails<CompostReading>(
        label: 'Potassium',
        color: Color(0xff90C7FE),
        groupedReadings: readingsByDayCompost,
        valueSelector: (b) => b.npk.potassium.toDouble(),
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Wrap(
        spacing: 24,
        direction: Axis.horizontal,
        children: beddingConditionCharts.map((chart) {
          if (chart is SystemChartDetails<BeddingReading>) {
            return SystemChartCard<BeddingReading>(chartData: chart);
          } else if (chart is SystemChartDetails<CompostReading>) {
            return SystemChartCard<CompostReading>(chartData: chart);
          } else {
            return const SizedBox.shrink();
          }
        }).toList(),
      ),
    );
  }
}
