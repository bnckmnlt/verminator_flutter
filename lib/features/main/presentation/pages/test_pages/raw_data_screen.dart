import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vermicomposting/core/common/widgets/empty_display_widget.dart';
import 'package:flutter_vermicomposting/core/common/widgets/loader.dart';
import 'package:flutter_vermicomposting/core/utils/extract_by_day.dart';
import 'package:flutter_vermicomposting/features/sensor_reading/domain/entity/sensor_reading.dart';
import 'package:flutter_vermicomposting/features/sensor_reading/presentation/bloc/sensor_reading_bloc.dart';
import 'package:to_csv/to_csv.dart' as exportCSV;

class RawDataScreen extends StatefulWidget {
  const RawDataScreen({super.key});

  @override
  State<RawDataScreen> createState() => _RawDataScreenState();
}

class _RawDataScreenState extends State<RawDataScreen> {
  @override
  void initState() {
    super.initState();

    // context.read<SensorReadingBloc>().add(SensorReadingList());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SensorReadingBloc, SensorReadingState>(
      builder: (BuildContext context, SensorReadingState state) {
        if (state is SensorReadingLoading) {
          return Loader();
        } else if (state is SensorReadingListSuccess) {
          List<List<String>> datasource = parseReadingToTableRecord(state.list);

          List<String> header = [];
          header.add('ID');
          header.add('Schedule ID');
          header.add('Temperature');
          header.add('Humidity');
          header.add('Soil Moisture');
          header.add('Nitrogen');
          header.add('Phosphorus');
          header.add('Potassium');
          header.add('Date & Time');

          return Center(
            child: Column(
              spacing: 14,
              children: [
                ElevatedButton(
                    onPressed: () => exportCSV.myCSV(header, datasource,
                        setHeadersInFirstRow: true,
                        includeNoRow: true,
                        sharing: false),
                    child: Text("Save CSV")),
              ],
            ),
          );
        } else if (state is SensorReadingFailure) {
          return EmptyDisplayWidget(
            title: "Something went wrong",
            description: "Hello",
          );
        }
        return SizedBox.shrink();
      },
    );
  }
}

List<List<String>> parseReadingToTableRecord(
    List<SensorReading> sensorReadings) {
  const degreeSymbol = '\u00B0';

  final readingsByMinute = <String, List<SensorReading>>{};
  final dateTimeMapping = <String, DateTime>{};

  for (final r in sensorReadings) {
    final dt = DateTime.parse(r.createdAt);
    final roundedDt = DateTime(dt.year, dt.month, dt.day, dt.hour, dt.minute);
    final key = roundedDt.toIso8601String();

    readingsByMinute.putIfAbsent(key, () => []).add(r);
    dateTimeMapping.putIfAbsent(key, () => roundedDt);
  }

  List<List<String>> list = [];

  final sortedKeys = dateTimeMapping.keys.toList()
    ..sort((a, b) => dateTimeMapping[a]!.compareTo(dateTimeMapping[b]!));

  for (var key in sortedKeys) {
    final readings = readingsByMinute[key]!;

    SensorReading? beddingReading;
    SensorReading? compostReading;

    for (var r in readings) {
      if (r.layer == SystemLayer.bedding && beddingReading == null) {
        beddingReading = r;
      }
      if (r.layer == SystemLayer.compost && compostReading == null) {
        compostReading = r;
      }
    }

    final formattedDate = extractDay(
        format: "MM-dd-yyyy hh:mm a", dateTimeMapping[key]!.toIso8601String());

    list.add([
      (beddingReading?.id ?? compostReading?.id ?? '').toString(),
      (beddingReading?.sensorScheduleId ??
              compostReading?.sensorScheduleId ??
              '')
          .toString(),
      "${beddingReading?.asBeddingReading?.temperature.value ?? 0}$degreeSymbol"
          "C",
      "${beddingReading?.asBeddingReading?.humidity.value ?? 0}%",
      "${beddingReading?.asBeddingReading?.soilMoisture.value ?? 0}%",
      "${compostReading?.asCompostReading?.npk.nitrogen ?? 0}%",
      "${compostReading?.asCompostReading?.npk.phosphorus ?? 0}%",
      "${compostReading?.asCompostReading?.npk.potassium ?? 0}%",
      formattedDate,
    ]);
  }

  return list;
}

class RawSensorReading {
  final String id;
  final String scheduleId;
  final String temperature;
  final String humidity;
  final String soilMoisture;
  final String nitrogen;
  final String phosphorus;
  final String potassium;
  final String dateTime;

  RawSensorReading({
    required this.id,
    required this.scheduleId,
    required this.temperature,
    required this.humidity,
    required this.soilMoisture,
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    required this.dateTime,
  });
}
