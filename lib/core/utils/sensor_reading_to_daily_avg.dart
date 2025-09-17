import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:flutter_vermicomposting/features/sensor_reading/domain/entity/sensor_reading.dart';
import 'package:intl/intl.dart';

List<ChartData> sensorReadingToDailyAvg<T>(
  List<SensorReading> readings,
  SystemLayer layer,
  num Function(T reading) valueSelector, {
  int? limit,
  DateFormat? dateFormat,
}) {
  final formatter = dateFormat ?? DateFormat.yMMMd();
  final converter = layer == SystemLayer.bedding
      ? (SensorReading r) => r.asBeddingReading as T?
      : (SensorReading r) => r.asCompostReading as T?;

  final grouped = readings
      .where((r) => r.layer == layer)
      .fold<Map<String, List<T>>>({}, (acc, r) {
    final dateLabel = formatter.format(DateTime.parse(r.createdAt));
    final converted = converter(r);
    if (converted != null) {
      acc.putIfAbsent(dateLabel, () => []).add(converted);
    }
    return acc;
  });

  final chartData = grouped.entries
      .map((entry) {
        final values = entry.value;
        final avg = values.fold<num>(0, (sum, v) => sum + valueSelector(v)) /
            values.length;
        return ChartData(entry.key, avg.toDouble());
      })
      .toList()
      .sublist(0, limit ?? 7);

  return chartData;
}
