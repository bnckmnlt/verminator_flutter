import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vermicomposting/core/common/widgets/empty_display_widget.dart';
import 'package:flutter_vermicomposting/core/common/widgets/loader.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/domain/entities/compost_schedule.dart';
import 'package:flutter_vermicomposting/features/food_waste/data/models/food_waste_model.dart';
import 'package:flutter_vermicomposting/features/food_waste/domain/entities/food_waste.dart';
import 'package:flutter_vermicomposting/features/food_waste/presentation/bloc/food_waste_bloc.dart';
import 'package:flutter_vermicomposting/features/logs/domain/entity/log_entity.dart';
import 'package:flutter_vermicomposting/features/logs/presentation/bloc/log_bloc.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/schedule_screen_widget/schedule_data_table_widget.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/schedule_screen_widget/schedule_hardware_profile_widget.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/schedule_screen_widget/schedule_screen_header_widget.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/schedule_screen_widget/schedule_substrate_charts_widget.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/schedule_screen_widget/schedule_system_overview_widget.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/schedule_screen_widget/schedule_waste_and_metrics_widget.dart';
import 'package:flutter_vermicomposting/features/sensor_reading/domain/entity/sensor_reading.dart';
import 'package:flutter_vermicomposting/features/sensor_reading/presentation/bloc/sensor_reading_bloc.dart';
import 'package:flutter_vermicomposting/features/status/domain/entity/status_record.dart';
import 'package:flutter_vermicomposting/features/status/presentation/bloc/status_record_bloc.dart';
import 'package:flutter_vermicomposting/features/worm_activity/domain/entity/worm_activity.dart';
import 'package:flutter_vermicomposting/features/worm_activity/presentation/bloc/worm_activity_bloc.dart';
import 'package:flutter_vermicomposting/mqtt_service.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tab_container/tab_container.dart';

class ScheduleScreenTest extends StatefulWidget {
  final CompostSchedule compostSchedule;

  const ScheduleScreenTest({
    super.key,
    required this.compostSchedule,
  });

  @override
  State<ScheduleScreenTest> createState() => _ScheduleScreenTestState();
}

class _ScheduleScreenTestState extends State<ScheduleScreenTest>
    with TickerProviderStateMixin {
  late SupabaseClient _supabaseClient;
  late MqttService _mqttService;
  late TabController _tabController;

  late CompostSchedule compostSchedule;
  late List<FoodWaste> foodWasteList;
  late List<SensorReading> sensorReadingList;
  late List<WormActivity> wormActivityList;
  late List<StatusRecord> statusList;
  late List<LogEntity> logList;

  bool _foodWasteLoadingState = true;
  bool _sensorReadingLoadingState = true;
  bool _wormActivityLoadingState = true;
  bool _statusLoadingState = true;
  bool _logLoadingState = true;

  bool _hasInitialized = false;
  bool _isError = false;

  List<String> _errorList = [];

  List<TabData> _tabData = [];

  @override
  void initState() {
    super.initState();

    _mqttService = GetIt.I<MqttService>();
    _supabaseClient = GetIt.I<SupabaseClient>();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_hasInitialized) {
      _tabController = TabController(length: _tabData.length, vsync: this);

      context.read<FoodWasteBloc>().add(FoodWasteList());
      context.read<SensorReadingBloc>().add(SensorReadingList());
      context.read<LogBloc>().add(LogList());
      context.read<WormActivityBloc>().add(WormActivityList());
      context.read<StatusRecordBloc>().add(StatusRecordList());

      compostSchedule = widget.compostSchedule;

      _hasInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    double horizontalPadding = width * 0.05;
    double verticalPadding = height * 0.05;

    bool mountedState = !_foodWasteLoadingState &&
        !_sensorReadingLoadingState &&
        !_wormActivityLoadingState &&
        !_statusLoadingState &&
        !_logLoadingState;

    _tabData = [
      TabData(
        icon: FluentIcons.brain_circuit_24_filled,
        tooltipMessage: "System Overview",
        childWidget: Padding(
          padding: const EdgeInsets.all(32),
          child: ScheduleSystemOverviewWidget(
            compostSchedule: widget.compostSchedule,
          ),
        ),
      ),
      TabData(
        icon: FluentIcons.server_24_filled,
        tooltipMessage: "Hardware Profile",
        childWidget: Padding(
          padding: const EdgeInsets.all(32),
          child: ScheduleHardwareProfileWidget(
            mqttService: _mqttService,
          ),
        ),
      ),
      TabData(
        icon: FluentIcons.food_apple_24_filled,
        tooltipMessage: "Feeding and Kitchen Waste",
        childWidget: Padding(
          padding: const EdgeInsets.all(32),
          child: ScheduleWasteAndMetricsWidget(
            compostSchedule: compostSchedule,
            foodWasteList: mountedState ? foodWasteList : [],
          ),
        ),
      ),
      TabData(
        icon: FluentIcons.data_area_24_filled,
        tooltipMessage: "Substrate Metrics",
        childWidget: ScheduleSubstrateChartsWidget(
          sensorReadingList: mountedState ? sensorReadingList : [],
        ),
      ),
      TabData(
        icon: FluentIcons.document_table_24_filled,
        tooltipMessage: "Schedule Data Table",
        childWidget: ScheduleDataTableWidget(
          compostSchedule: compostSchedule,
          sensorReadingList: mountedState ? sensorReadingList : [],
          wormActivityList: mountedState ? wormActivityList : [],
        ),
      ),
    ];

    _tabController = TabController(length: _tabData.length, vsync: this);

    return Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          iconTheme:
              IconThemeData(color: Theme.of(context).colorScheme.onSurface),
          backgroundColor: Colors.transparent,
          elevation: 0.0,
        ),
        body: MultiBlocListener(
          listeners: [
            BlocListener<FoodWasteBloc, FoodWasteState>(
                listener: (context, state) {
              if (state is FoodWasteLoading) {
                _foodWasteLoadingState = true;
              } else if (state is FoodWasteListSuccess) {
                final List<FoodWasteModel> itemList = state.foodWaste
                    .where((entry) =>
                        entry.foodWasteScheduleId == widget.compostSchedule.id)
                    .map((foodWaste) {
                  final foodWasteModel = foodWaste as FoodWasteModel;
                  final publicUrl = _supabaseClient.storage
                      .from('image')
                      .getPublicUrl(foodWasteModel.filePath);

                  return foodWasteModel.copyWith(filePath: publicUrl);
                }).toList();

                setState(() {
                  _foodWasteLoadingState = false;
                  foodWasteList = itemList;
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
                  sensorReadingList = state.list
                      .where((r) => r.sensorScheduleId == compostSchedule.id)
                      .toList();
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
                  wormActivityList = state.list
                      .where((activity) =>
                          activity.wormScheduleId == compostSchedule.id)
                      .toList();
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
                  statusList = state.statusRecordList
                      .where(
                          (status) => status.scheduleId == compostSchedule.id)
                      .toList();
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
                  child: Container(
                    height: height,
                    width: width,
                    padding: EdgeInsets.symmetric(
                      vertical: verticalPadding,
                      horizontal: horizontalPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ScheduleScreenHeaderWidget(
                          mqttService: _mqttService,
                          compostSchedule: compostSchedule,
                        ),
                        Expanded(
                          flex: 3,
                          child: Column(
                            spacing: 10,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AnimatedBuilder(
                                animation: _tabController,
                                builder: (BuildContext context, _) {
                                  return Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    spacing: 12,
                                    children: [
                                      Text(
                                        _tabData[_tabController.index]
                                            .tooltipMessage,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      if (_tabController.index == 0)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.lightBlue.withAlpha(64),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            border: Border.all(
                                                color: Colors.lightBlue),
                                          ),
                                          child: Text(
                                            "AI",
                                            style: TextStyle(
                                              color: Colors.lightBlue,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              letterSpacing: 0.025,
                                            ),
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: _tabData.isNotEmpty
                                          ? TabContainer(
                                              enabled: true,
                                              enableFeedback: true,
                                              controller: _tabController,
                                              tabsEnd: 0.8,
                                              tabExtent: 74,
                                              tabEdge: TabEdge.right,
                                              curve: Curves.easeIn,
                                              childCurve: Curves.easeIn,
                                              tabBorderRadius:
                                                  BorderRadius.circular(12),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .surfaceContainerHigh
                                                  .withAlpha(124),
                                              tabs: _tabData
                                                  .asMap()
                                                  .entries
                                                  .map((tab) {
                                                return AnimatedBuilder(
                                                  animation: _tabController,
                                                  builder: (context, _) {
                                                    final isActive = tab.key ==
                                                        _tabController.index;

                                                    return Tooltip(
                                                      message: tab
                                                          .value.tooltipMessage,
                                                      child: Icon(
                                                        tab.value.icon,
                                                        size: 32,
                                                        color: isActive
                                                            ? Theme.of(context)
                                                                .colorScheme
                                                                .onSurface
                                                            : Theme.of(context)
                                                                .colorScheme
                                                                .onSurface
                                                                .withAlpha(164),
                                                      ),
                                                    );
                                                  },
                                                );
                                              }).toList(),
                                              children: _tabData
                                                  .map((tab) => tab.childWidget)
                                                  .toList(),
                                            )
                                          : SizedBox.shrink(),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
}

class TabData {
  final IconData icon;
  final String tooltipMessage;
  final Widget childWidget;

  TabData({
    required this.icon,
    required this.tooltipMessage,
    required this.childWidget,
  });
}
