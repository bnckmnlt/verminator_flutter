import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:flutter_vermicomposting/features/sensor_reading/domain/entity/sensor_reading.dart';
import 'package:intl/intl.dart';

List<ChartData> sensorReadingToWindowedAvg<T>(
  List<SensorReading> readings,
  SystemLayer layer,
  TimeGrouping grouping,
  num Function(T reading) valueSelector,
) {
  final filtered = filterByMode(readings, grouping);

  final converter = layer == SystemLayer.bedding
      ? (SensorReading r) => r.asBeddingReading as T?
      : (SensorReading r) => r.asCompostReading as T?;

  final buckets = <String, List<T>>{};

  for (final r in filtered) {
    final dt = DateTime.parse(r.createdAt);
    final key = buildBucketKey(dt, grouping);
    final value = converter(r);

    if (value != null) {
      buckets.putIfAbsent(key, () => []).add(value);
    }
  }

  final data = buckets.entries.map((e) {
    final avg =
        e.value.fold<num>(0, (s, v) => s + valueSelector(v)) / e.value.length;
    return ChartData(e.key, avg.toDouble());
  }).toList();

  data.sort((a, b) => a.x.compareTo(b.x));
  return data;
}

List<SensorReading> filterByMode(
  List<SensorReading> readings,
  TimeGrouping grouping,
) {
  if (grouping == TimeGrouping.all) return readings;

  final now = DateTime.now();

  return readings.where((r) {
    final dt = DateTime.parse(r.createdAt);
    return switch (grouping) {
      TimeGrouping.last24Hours => dt.isAfter(now.subtract(Duration(hours: 24))),
      TimeGrouping.last7Days => dt.isAfter(now.subtract(Duration(days: 7))),
      TimeGrouping.last30Days => dt.isAfter(now.subtract(Duration(days: 30))),
      TimeGrouping.annual => dt.year == now.year,
      TimeGrouping.all => true,
    };
  }).toList();
}

String buildBucketKey(DateTime dt, TimeGrouping grouping) {
  switch (grouping) {
    case TimeGrouping.last24Hours:
      return DateFormat('yyyy-MM-dd HH:00').format(dt);
    case TimeGrouping.last7Days:
    case TimeGrouping.last30Days:
      return DateFormat('yyyy-MM-dd').format(dt);
    case TimeGrouping.annual:
      return DateFormat('yyyy-MM').format(dt);
    case TimeGrouping.all:
      return DateFormat('yyyy-MM').format(dt);
  }
}

enum TimeGrouping {
  last24Hours,
  last7Days,
  last30Days,
  annual,
  all,
}

TimeGrouping getTimeGrouping(int selectedTime) {
  return [
    TimeGrouping.last24Hours,
    TimeGrouping.last7Days,
    TimeGrouping.last30Days,
    TimeGrouping.annual,
    TimeGrouping.all,
  ][selectedTime];
}
