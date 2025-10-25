import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vermicomposting/core/common/entities/layer_classes.dart';
import 'package:flutter_vermicomposting/core/common/widgets/empty_display_widget.dart';
import 'package:flutter_vermicomposting/core/common/widgets/loader.dart';
import 'package:flutter_vermicomposting/core/utils/extract_by_day.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/domain/entities/compost_schedule.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/presentation/bloc/compost_schedule_bloc.dart';
import 'package:flutter_vermicomposting/features/food_waste/domain/entities/food_waste.dart';
import 'package:flutter_vermicomposting/features/food_waste/presentation/bloc/food_waste_bloc.dart';
import 'package:flutter_vermicomposting/features/logs/domain/entity/log_entity.dart';
import 'package:flutter_vermicomposting/features/logs/presentation/bloc/log_bloc.dart';
import 'package:flutter_vermicomposting/features/sensor_reading/domain/entity/sensor_reading.dart';
import 'package:flutter_vermicomposting/features/sensor_reading/presentation/bloc/sensor_reading_bloc.dart';
import 'package:flutter_vermicomposting/features/status/domain/entity/status_record.dart';
import 'package:flutter_vermicomposting/features/status/presentation/bloc/status_record_bloc.dart';
import 'package:flutter_vermicomposting/features/worm_activity/domain/entity/worm_activity.dart';
import 'package:flutter_vermicomposting/features/worm_activity/presentation/bloc/worm_activity_bloc.dart';

class ScheduleScreenTest extends StatefulWidget {
  const ScheduleScreenTest({super.key});

  @override
  State<ScheduleScreenTest> createState() => _ScheduleScreenTestState();
}

class _ScheduleScreenTestState extends State<ScheduleScreenTest> {
  late List<CompostSchedule> compostScheduleList;
  late List<FoodWaste> foodWasteList;
  late List<SensorReading> sensorReadingList;
  late List<WormActivity> wormActivityList;
  late List<StatusRecord> statusList;
  late List<LogEntity> logList;

  bool _compostScheduleLoadingState = true;
  bool _foodWasteLoadingState = true;
  bool _sensorReadingLoadingState = true;
  bool _wormActivityLoadingState = true;
  bool _statusLoadingState = true;
  bool _logLoadingState = true;

  bool _hasInitialized = false;
  bool _isError = false;

  List<String> _errorList = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_hasInitialized) {
      context.read<CompostScheduleBloc>().add(CompostScheduleList());
      context.read<FoodWasteBloc>().add(FoodWasteList());
      context.read<SensorReadingBloc>().add(SensorReadingList());
      context.read<LogBloc>().add(LogList());
      context.read<WormActivityBloc>().add(WormActivityList());
      context.read<StatusRecordBloc>().add(StatusRecordList());
      _hasInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    double horizontalPadding = width * 0.075;
    double verticalPadding = height * 0.1;

    bool mountedState = !_compostScheduleLoadingState &&
        !_foodWasteLoadingState &&
        !_sensorReadingLoadingState &&
        !_wormActivityLoadingState &&
        !_statusLoadingState &&
        !_logLoadingState;

    return Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: MultiBlocListener(
          listeners: [
            BlocListener<CompostScheduleBloc, CompostScheduleState>(
                listener: (context, state) {
              if (state is CompostScheduleLoading) {
                _compostScheduleLoadingState = true;
              } else if (state is CompostScheduleListSuccess) {
                setState(() {
                  _compostScheduleLoadingState = false;
                  compostScheduleList = state.compostScheduleList;
                });
              } else if (state is CompostScheduleFailure) {
                setState(() {
                  _isError = true;
                  _errorList.add(state.error);
                });
              }
            }),
            BlocListener<FoodWasteBloc, FoodWasteState>(
                listener: (context, state) {
              if (state is FoodWasteLoading) {
                _foodWasteLoadingState = true;
              } else if (state is FoodWasteListSuccess) {
                setState(() {
                  _foodWasteLoadingState = false;
                  foodWasteList = state.foodWaste;
                });
              } else if (state is FoodWasteFailure) {
                setState(() {
                  _isError = true;
                  _errorList.add(state.error);
                });
              }
            }),
            BlocListener<SensorReadingBloc, SensorReadingState>(
                listener: (context, state) {
              if (state is SensorReadingLoading) {
                _sensorReadingLoadingState = true;
              } else if (state is SensorReadingListSuccess) {
                setState(() {
                  _sensorReadingLoadingState = false;
                  sensorReadingList =
                      state.list.where((r) => r.sensorScheduleId == 2).toList();
                });
              } else if (state is SensorReadingFailure) {
                setState(() {
                  _isError = true;
                  _errorList.add(state.error);
                });
              }
            }),
            BlocListener<WormActivityBloc, WormActivityState>(
                listener: (context, state) {
              if (state is WormActivityLoading) {
                _wormActivityLoadingState = true;
              } else if (state is WormActivityListSuccess) {
                setState(() {
                  _wormActivityLoadingState = false;
                  wormActivityList = state.list;
                });
              } else if (state is WormActivityFailure) {
                setState(() {
                  _isError = true;
                  _errorList.add(state.error);
                });
              }
            }),
            BlocListener<StatusRecordBloc, StatusRecordState>(
                listener: (context, state) {
              if (state is StatusRecordLoading) {
                _statusLoadingState = true;
              } else if (state is StatusRecordListSuccess) {
                setState(() {
                  _statusLoadingState = false;
                  statusList = state.statusRecordList;
                });
              } else if (state is StatusRecordFailure) {
                setState(() {
                  _isError = true;
                  _errorList.add(state.error);
                });
              }
            }),
            BlocListener<LogBloc, LogState>(listener: (context, state) {
              if (state is LogsLoading) {
                _logLoadingState = true;
              } else if (state is LogsListSuccess) {
                setState(() {
                  _logLoadingState = false;
                  logList = state.logs;
                });
              } else if (state is LogsFailure) {
                setState(() {
                  _isError = true;
                  _errorList.add(state.error);
                });
              }
            }),
          ],
          child: mountedState
              ? RefreshIndicator(
                  onRefresh: () {
                    return Future.delayed(Duration(seconds: 1), () {});
                  },
                  child: SafeArea(
                    child: Container(
                      height: height,
                      width: width,
                      padding: EdgeInsets.symmetric(
                          vertical: verticalPadding,
                          horizontal: horizontalPadding),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Hello"),
                          _dailyRecordDataTable(
                              sensorReadingList, wormActivityList)
                        ],
                      ),
                    ),
                  ),
                )
              : _isError
                  ? EmptyDisplayWidget(
                      title: "An error has occurred",
                      description: _errorList.join("/n"),
                      icon: FluentIcons.cloud_error_24_filled,
                    )
                  : Center(
                      child: Loader(),
                    ),
        ));
  }

  Widget _dailyRecordDataTable(
    List<SensorReading> sensorReadingList,
    List<WormActivity> wormActivityList,
  ) {
    List<Reading> readings = parseToAverage(
      sensorReadingList,
      wormActivityList,
    );

    return Container(
      child: Column(
        children: readings.map((element) {
          return Text(element.date);
        }).toList(),
      ),
    );
  }
}

List<Reading> parseToAverage(
    List<SensorReading> readings, List<WormActivity> wormActivities) {
  final allDates = <String>{
    ...readings.map((r) => extractDay(r.createdAt)),
    ...wormActivities.map((w) => extractDay(w.createdAt)),
  };

  final readingsByDate = <String, List<SensorReading>>{};
  for (final r in readings) {
    final date = extractDay(r.createdAt);
    readingsByDate.putIfAbsent(date, () => []).add(r);
  }

  final wormsByDate = <String, List<WormActivity>>{};
  for (final w in wormActivities) {
    final date = extractDay(w.createdAt);
    wormsByDate.putIfAbsent(date, () => []).add(w);
  }

  double avg(List<double> values) =>
      values.isEmpty ? 0 : values.reduce((a, b) => a + b) / values.length;

  return allDates.map((date) {
    final sensorList = readingsByDate[date] ?? [];
    final wormList = wormsByDate[date] ?? [];

    final rAvg = sensorList.isEmpty
        ? Reading(date: date)
        : Reading(
            date: date,
            temperature: avg(sensorList
                .where((r) => r.layer == SystemLayer.bedding)
                .map((r) =>
                    r.asBeddingReading?.temperature.value.toDouble() ?? 0)
                .toList()),
            humidity: avg(sensorList
                .where((r) => r.layer == SystemLayer.bedding)
                .map((r) => r.asBeddingReading?.humidity.value.toDouble() ?? 0)
                .toList()),
            soilMoisture: avg(sensorList
                .where((r) => r.layer == SystemLayer.bedding)
                .map((r) =>
                    r.asBeddingReading?.soilMoisture.value.toDouble() ?? 0)
                .toList()),
            nitrogen: avg(sensorList
                .where((r) => r.layer == SystemLayer.compost)
                .map((r) => r.asCompostReading?.npk.nitrogen.toDouble() ?? 0)
                .toList()),
            phosphorus: avg(sensorList
                .where((r) => r.layer == SystemLayer.compost)
                .map((r) => r.asCompostReading?.npk.phosphorus.toDouble() ?? 0)
                .toList()),
            potassium: avg(sensorList
                .where((r) => r.layer == SystemLayer.compost)
                .map((r) => r.asCompostReading?.npk.potassium.toDouble() ?? 0)
                .toList()),
          );

    final activeZone =
        wormList.isEmpty ? "Unknown" : wormList.first.getActiveZoneLabel();

    return Reading(
      date: rAvg.date,
      temperature: rAvg.temperature,
      humidity: rAvg.humidity,
      soilMoisture: rAvg.soilMoisture,
      nitrogen: rAvg.nitrogen,
      phosphorus: rAvg.phosphorus,
      potassium: rAvg.potassium,
      activeZone: activeZone,
    );
  }).toList()
    ..sort((a, b) => b.date.compareTo(a.date));
}
