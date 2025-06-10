import 'dart:async';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vermicomposting/core/common/widgets/empty_display_widget.dart';
import 'package:flutter_vermicomposting/core/common/widgets/loader.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/domain/entities/compost_schedule.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/presentation/bloc/compost_schedule_bloc.dart';
import 'package:flutter_vermicomposting/features/food_waste/presentation/bloc/food_waste_bloc.dart';
import 'package:flutter_vermicomposting/features/main/domain/entities/daily_records_cell.dart';
import 'package:flutter_vermicomposting/features/main/presentation/pages/daily_records_data_table.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/schedule_screen_widgets/system_charts_section.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/schedule_screen_widgets/system_details_section.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/schedule_screen_widgets/system_device_information.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/schedule_screen_widgets/system_record_details_widget.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/schedule_screen_widgets/system_schedule_header_section.dart';
import 'package:flutter_vermicomposting/features/sensor_reading/domain/entity/sensor_reading.dart';
import 'package:flutter_vermicomposting/features/sensor_reading/presentation/bloc/sensor_reading_bloc.dart';
import 'package:flutter_vermicomposting/features/worm_activity/domain/entity/worm_activity.dart';
import 'package:flutter_vermicomposting/features/worm_activity/presentation/bloc/worm_activity_bloc.dart';
import 'package:flutter_vermicomposting/mqtt_service.dart';
import 'package:get_it/get_it.dart';

class ScheduleScreen extends StatefulWidget {
  final int scheduleId;

  const ScheduleScreen({
    super.key,
    required this.scheduleId,
  });

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, mainConstraints) {
      return Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
        ),
        body: SensorReadingSection(scheduleId: widget.scheduleId),
      );
    });
  }
}

class SensorReadingSection extends StatelessWidget {
  final int scheduleId;

  const SensorReadingSection({
    super.key,
    required this.scheduleId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SensorReadingBloc, SensorReadingState>(
      builder: (context, state) {
        if (state is SensorReadingLoading) return Loader();
        if (state is SensorReadingFailure) {
          return EmptyDisplayWidget(
            description: state.error,
            title: 'An error has occurred',
            icon: FluentIcons.cloud_error_24_regular,
          );
        }
        if (state is SensorReadingListSuccess) {
          return WormActivitySection(
            scheduleId: scheduleId,
            sensorReadings: state.list
                .where((activity) => activity.sensorScheduleId == scheduleId)
                .toList(),
          );
        }
        return SizedBox();
      },
    );
  }
}

class WormActivitySection extends StatelessWidget {
  final int scheduleId;
  final List<SensorReading> sensorReadings;

  const WormActivitySection({
    super.key,
    required this.sensorReadings,
    required this.scheduleId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WormActivityBloc, WormActivityState>(
      builder: (context, state) {
        if (state is WormActivityLoading) return Loader();
        if (state is WormActivityFailure) {
          return EmptyDisplayWidget(
            description: state.error,
            title: 'An error has occurred',
            icon: FluentIcons.cloud_error_24_regular,
          );
        }
        if (state is WormActivityListSuccess) {
          return CompostScheduleSection(
            scheduleId: scheduleId,
            sensorReadings: sensorReadings,
            wormActivities: state.list
                .where((schedule) => schedule.wormScheduleId == scheduleId)
                .toList(),
          );
        }
        return SizedBox();
      },
    );
  }
}

class CompostScheduleSection extends StatelessWidget {
  final int scheduleId;
  final List<SensorReading> sensorReadings;
  final List<WormActivity> wormActivities;

  const CompostScheduleSection({
    super.key,
    required this.sensorReadings,
    required this.wormActivities,
    required this.scheduleId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CompostScheduleBloc, CompostScheduleState>(
      builder: (context, state) {
        if (state is CompostScheduleLoading) return Loader();
        if (state is CompostScheduleFailure) {
          return EmptyDisplayWidget(
            description: state.error,
            title: 'An error has occurred',
            icon: FluentIcons.cloud_error_24_regular,
          );
        }
        if (state is CompostScheduleListSuccess) {
          return FoodWasteSection(
            sensorReadings: sensorReadings,
            wormActivities: wormActivities,
            compostSchedule: state.compostScheduleList
                .where((schedule) => schedule.id == scheduleId)
                .first,
          );
        }
        return SizedBox();
      },
    );
  }
}

class FoodWasteSection extends StatefulWidget {
  final List<SensorReading> sensorReadings;
  final List<WormActivity> wormActivities;
  final CompostSchedule compostSchedule;

  const FoodWasteSection({
    super.key,
    required this.sensorReadings,
    required this.wormActivities,
    required this.compostSchedule,
  });

  @override
  State<FoodWasteSection> createState() => _FoodWasteSectionState();
}

class _FoodWasteSectionState extends State<FoodWasteSection> {
  bool _isDetailsVisible = false;

  final FocusNode _tableFocusNode = FocusNode();

  late MqttService _mqttService;

  late StreamSubscription<Map<String, String>> _deviceInfoStreamSubscription;
  Map<String, String> _deviceInfo = {};

  late DailyRecordsCell selectedRecord;

  @override
  void initState() {
    super.initState();

    _mqttService = GetIt.I<MqttService>();
    _mqttService.connect();

    _deviceInfoStreamSubscription =
        _mqttService.deviceInfoStream.listen((info) {
      setState(() {
        _deviceInfo = info;
      });
    });
  }

  @override
  void dispose() {
    _deviceInfoStreamSubscription.cancel();

    super.dispose();
  }

  void _handleTableFocus(DailyRecordsCell currentRow) {
    FocusScope.of(context).requestFocus(_tableFocusNode);
    setState(() {
      _isDetailsVisible = true;
    });

    setState(() {
      selectedRecord = currentRow;
    });
  }

  void _handleOutsideTap() {
    if (_tableFocusNode.hasFocus) {
      _tableFocusNode.unfocus();
      setState(() {
        _isDetailsVisible = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;

    return BlocBuilder<FoodWasteBloc, FoodWasteState>(
      builder: (context, state) {
        if (state is FoodWasteLoading) return Loader();
        if (state is FoodWasteFailure) {
          return EmptyDisplayWidget(
            description: state.error,
            title: 'An error has occurred',
            icon: FluentIcons.cloud_error_24_regular,
          );
        }
        if (state is FoodWasteListSuccess) {
          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _handleOutsideTap,
            child: Focus(
              focusNode: _tableFocusNode,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 64, 24, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SystemScheduleHeaderSection(
                                compostSchedule: widget.compostSchedule),
                            const SizedBox(height: 44),
                            Text(
                              "System Details",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SystemDetailsSection(
                              compostSchedule: widget.compostSchedule,
                              foodWasteList: state.foodWaste,
                            ),
                            const SizedBox(height: 34),
                            SystemChartsSection(
                                sensorReadings: widget.sensorReadings),
                            const SizedBox(height: 34),
                            DailyRecordsDataTable(
                              tableFocusNode: _tableFocusNode,
                              sensorReadings: widget.sensorReadings,
                              wormActivities: widget.wormActivities,
                              onShowDetails: _handleTableFocus,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: !_isDetailsVisible
                        ? Container(
                            padding: const EdgeInsets.fromLTRB(24, 44, 24, 24),
                            decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                border: Border(
                                    left: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHigh,
                                ))),
                            child: SystemDeviceInformation(
                              deviceInfo: _deviceInfo,
                            ),
                          )
                        : SystemRecordDetails(
                            currentRecord: selectedRecord,
                          ),
                  )
                ],
              ),
            ),
          );
        }
        return SizedBox();
      },
    );
  }
}

List<SensorReading> getFilteredReadings(
    List<SensorReading> readings, DateTimeRange range) {
  return readings.where((r) {
    final timestamp = DateTime.parse(r.createdAt);
    return timestamp
            .isAfter(range.start.subtract(const Duration(seconds: 1))) &&
        timestamp.isBefore(range.end.add(const Duration(seconds: 1)));
  }).toList();
}
