import 'package:flutter_vermicomposting/core/common/entities/layer_classes.dart';
import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:flutter_vermicomposting/core/utils/extract_by_day.dart';
import 'package:flutter_vermicomposting/features/main/domain/entities/daily_records_cell.dart';
import 'package:flutter_vermicomposting/features/sensor_reading/domain/entity/sensor_reading.dart';
import 'package:flutter_vermicomposting/features/worm_activity/domain/entity/worm_activity.dart';

List<DailyRecordsCell> calculateDailyAverages(
  List<SensorReading> readings,
  List<WormActivity> wormActivities,
) {
  final beddingByDay = <String, List<BeddingReading>>{};
  final compostByDay = <String, List<CompostReading>>{};

  for (var r in readings) {
    final day = extractDay(r.createdAt, format: "yyyy-MM-dd");
    if (r.layer == SystemLayer.bedding && r.asBeddingReading != null) {
      beddingByDay.putIfAbsent(day, () => []).add(r.asBeddingReading!);
    } else if (r.layer == SystemLayer.compost && r.asCompostReading != null) {
      compostByDay.putIfAbsent(day, () => []).add(r.asCompostReading!);
    }
  }

  final wormActivityByDay = {
    for (var w in wormActivities) extractDay(w.createdAt): w
  };

  final allDays = <String>{
    ...beddingByDay.keys,
    ...compostByDay.keys,
    ...wormActivityByDay.keys
  };

  return allDays.map((day) {
    final bed = beddingByDay[day] ?? [];
    final comp = compostByDay[day] ?? [];

    double avg(List<num> nums) =>
        nums.isEmpty ? 0.0 : nums.reduce((a, b) => a + b) / nums.length;

    final avgTemp = avg(bed.map((r) => r.temperature.value).toList());
    final avgHumidity = avg(bed.map((r) => r.humidity.value).toList());
    final avgSoilMoisture = avg(bed.map((r) => r.soilMoisture.value).toList());
    final nitrogen = avg(comp.map((r) => r.npk.nitrogen).toList());
    final phosphorus = avg(comp.map((r) => r.npk.phosphorus).toList());
    final potassium = avg(comp.map((r) => r.npk.potassium).toList());

    final wormActivity = (wormActivityByDay[day]
            ?.getActiveZoneLabel(wormActivityByDay[day]!.zones)) ??
        "Unknown";

    return DailyRecordsCell(
      day: day,
      condition: SensorStatus.good,
      temperature: bed.isNotEmpty ? avgTemp.toStringAsFixed(1) : "-",
      humidity: bed.isNotEmpty ? avgHumidity.toStringAsFixed(1) : "-",
      soilMoisture: bed.isNotEmpty ? avgSoilMoisture.toStringAsFixed(1) : "-",
      nitrogen: comp.isNotEmpty
          ? (nitrogen == 0 ? "-" : nitrogen.toStringAsFixed(1))
          : "-",
      phosphorus: comp.isNotEmpty
          ? (phosphorus == 0 ? "-" : phosphorus.toStringAsFixed(1))
          : "-",
      potassium: comp.isNotEmpty
          ? (potassium == 0 ? "-" : potassium.toStringAsFixed(1))
          : "-",
      wormActivity: wormActivity.toString(),
    );
  }).toList();
}
