import 'dart:async';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vermicomposting/core/common/widgets/dialog.dart';
import 'package:flutter_vermicomposting/core/common/widgets/empty_display_widget.dart';
import 'package:flutter_vermicomposting/core/common/widgets/loader.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/domain/entities/compost_schedule.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/presentation/bloc/compost_schedule_bloc.dart';
import 'package:flutter_vermicomposting/features/food_waste/presentation/bloc/food_waste_bloc.dart';
import 'package:flutter_vermicomposting/features/main/domain/entities/daily_records_cell.dart';
import 'package:flutter_vermicomposting/features/main/presentation/pages/schedule_initialization/initialization_waiting_screen.dart';
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

import 'daily_records_data_table.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController _scheduleIdentifierController =
      TextEditingController();

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
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return GeneralDialog(
                    title: 'Create compost schedule',
                    description:
                        'Give your composting cycle a name (e.g., Backyard Pile 1)',
                    confirmButtonLabel: 'Continue',
                    widget: Form(
                      key: formKey,
                      child: TextFormField(
                        controller: _scheduleIdentifierController,
                        validator: (value) {
                          if (value!.isEmpty || value.length <= 8) {
                            return "Compost schedule name is invalid";
                          }
                          return null;
                        },
                      ),
                    ),
                    approvedFunction: () {
                      if (formKey.currentState!.validate()) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return GeneralDialog(
                              title: 'Begin monitoring',
                              description:
                                  'Would you like to begin tracking ${_scheduleIdentifierController.text}?',
                              confirmButtonLabel: 'Confirm',
                              approvedFunction: () {
                                Navigator.pop(context);

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        InitializationWaitingScreen(),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      }
                    },
                  );
                });
          },
          child: const Icon(Icons.add),
        ),
        body: SensorReadingSection(),
      );
    });
  }
}

class SensorReadingSection extends StatelessWidget {
  const SensorReadingSection({super.key});

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
          return WormActivitySection(sensorReadings: state.list);
        }
        return SizedBox();
      },
    );
  }
}

class WormActivitySection extends StatelessWidget {
  final List<SensorReading> sensorReadings;

  const WormActivitySection({super.key, required this.sensorReadings});

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
            sensorReadings: sensorReadings,
            wormActivities: state.list,
          );
        }
        return SizedBox();
      },
    );
  }
}

class CompostScheduleSection extends StatelessWidget {
  final List<SensorReading> sensorReadings;
  final List<WormActivity> wormActivities;

  const CompostScheduleSection({
    super.key,
    required this.sensorReadings,
    required this.wormActivities,
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
            compostSchedules: state.compostScheduleList,
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
  final List<CompostSchedule> compostSchedules;

  const FoodWasteSection({
    super.key,
    required this.sensorReadings,
    required this.wormActivities,
    required this.compostSchedules,
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
                                compostSchedule: widget.compostSchedules.first),
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
                              compostSchedule: widget.compostSchedules.first,
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
