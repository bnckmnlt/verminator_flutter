import 'dart:async';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vermicomposting/core/common/cubits/app_settings/app_settings_cubit.dart';
import 'package:flutter_vermicomposting/core/common/widgets/empty_display_widget.dart';
import 'package:flutter_vermicomposting/core/common/widgets/glassmorphism.dart';
import 'package:flutter_vermicomposting/core/common/widgets/loader.dart';
import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:flutter_vermicomposting/core/utils/format_to_local_time.dart';
import 'package:flutter_vermicomposting/core/utils/sensor_reading_to_daily_avg.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/domain/entities/compost_schedule.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/presentation/bloc/compost_schedule_bloc.dart';
import 'package:flutter_vermicomposting/features/food_waste/domain/entities/food_waste.dart';
import 'package:flutter_vermicomposting/features/food_waste/presentation/bloc/food_waste_bloc.dart';
import 'package:flutter_vermicomposting/features/logs/presentation/bloc/log_bloc.dart';
import 'package:flutter_vermicomposting/features/main/domain/entities/sensor_values.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/home_screen_widgets/camera_and_thermal_monitoring_widget.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/home_screen_widgets/composting_performance_overview_widget.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/home_screen_widgets/daily_report_widget.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/home_screen_widgets/environmental_metrics_widget.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/home_screen_widgets/notification_widget.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/home_screen_widgets/system_summary_widget.dart';
import 'package:flutter_vermicomposting/features/notification/domain/entities/notification.dart';
import 'package:flutter_vermicomposting/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:flutter_vermicomposting/features/sensor_reading/domain/entity/sensor_reading.dart';
import 'package:flutter_vermicomposting/features/sensor_reading/presentation/bloc/sensor_reading_bloc.dart';
import 'package:flutter_vermicomposting/features/status/presentation/bloc/status_record_bloc.dart';
import 'package:flutter_vermicomposting/features/worm_activity/presentation/bloc/worm_activity_bloc.dart';
import 'package:flutter_vermicomposting/main.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DateTime now = DateTime.now();

  late List<CompostSchedule> compostScheduleList;
  late List<FoodWaste> foodWasteList;
  late List<SensorReading> sensorReadingList;
  late List<NotificationEntity> notificationList;

  late List<SummaryCardItem> _summaryItems;

  bool _compostScheduleLoadingState = true;
  bool _foodWasteLoadingState = true;
  bool _sensorReadingLoadingState = true;
  bool _notificationLoadingState = true;

  bool _hasInitialized = false;
  bool _isError = false;

  List<String> _errorList = [];

  SensorValues sensorValues = SensorValues(
    temperature: "0",
    humidity: "0",
    soilMoisture: "0",
    nitrogen: "0",
    phosphorus: "0",
    potassium: "0",
    compost: "0",
    vermijuice: "0",
    reservoir: "0",
  );

  @override
  void initState() {
    super.initState();
    if (!_hasInitialized) {
      context.read<CompostScheduleBloc>().add(CompostScheduleList());
      context.read<FoodWasteBloc>().add(FoodWasteList());
      context.read<SensorReadingBloc>().add(SensorReadingList());
      context.read<LogBloc>().add(LogList());
      context.read<WormActivityBloc>().add(WormActivityList());
      context.read<StatusRecordBloc>().add(StatusRecordList());
      context.read<NotificationBloc>().add(NotificationList());
      _hasInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double deviceHeight = MediaQuery.sizeOf(context).height;
    final double deviceWidth = MediaQuery.sizeOf(context).width;

    final formattedDate = DateFormat('d MMMM y').format(now);
    final formattedTime = DateFormat('h:mm a')
        .format(DateTime.parse(formatToLocalTime(DateTime.now().toString())));

    bool mountedState = !_compostScheduleLoadingState &&
        !_foodWasteLoadingState &&
        !_sensorReadingLoadingState &&
        !_notificationLoadingState;

    if (mountedState) {
      _summaryItems = [
        SummaryCardItem(
          label: "Total Kitchen Waste Processed",
          value: "${foodWasteList.length.toString()} ",
          unit: "pcs.",
          icon: FluentIcons.food_apple_24_filled,
          color: Colors.lightBlueAccent,
        ),
        SummaryCardItem(
          label: "Total Vermicast Produced",
          value: compostScheduleList
              .fold<double>(
                  0.0,
                  (prev, next) =>
                      prev +
                      (double.tryParse(next.compostProduced ?? '0') ?? 0.0))
              .toStringAsFixed(2),
          unit: "kg of soil",
          icon: Icons.eco_rounded,
          color: Colors.lightBlueAccent,
        ),
        SummaryCardItem(
          label: "Total Vermitea Collected",
          value: compostScheduleList
              .fold<double>(
                  0.0,
                  (prev, next) =>
                      prev +
                      (double.tryParse(next.juiceProduced ?? '0') ?? 0.0))
              .toStringAsFixed(2),
          unit: "L of vermitea",
          icon: FluentIcons.drink_bottle_20_filled,
          color: Colors.lightBlueAccent,
        ),
        SummaryCardItem(
          label: "Total Process Completed",
          value: compostScheduleList.length.toString(),
          unit: " process",
          icon: FluentIcons.recycle_20_filled,
          color: Colors.lightBlueAccent,
        ),
      ];
    }

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
              log.severe("schedule ${state.error}");
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
              log.severe("food waste ${state.error}");
            }
          }),
          BlocListener<SensorReadingBloc, SensorReadingState>(
              listener: (context, state) {
            if (state is SensorReadingLoading) {
              _sensorReadingLoadingState = true;
            } else if (state is SensorReadingListSuccess) {
              setState(() {
                _sensorReadingLoadingState = false;
                sensorReadingList = state.list;
                log.warning(sensorReadingList.length);
              });
            } else if (state is SensorReadingFailure) {
              setState(() {
                _isError = true;
                _errorList.add(state.error);
              });
              log.severe("sensor reading ${state.error}");
            }
          }),
          BlocListener<NotificationBloc, NotificationState>(
              listener: (context, state) {
            if (state is SensorReadingLoading) {
              _notificationLoadingState = true;
            } else if (state is NotificationListSuccess) {
              setState(() {
                _notificationLoadingState = false;
                notificationList = state.notificationList;
              });
            } else if (state is NotificationFailure) {
              setState(() {
                _isError = true;
                _errorList.add(state.error);
              });
              log.severe("notification ${state.error}");
            }
          }),
        ],
        child: mountedState
            ? RefreshIndicator(
                onRefresh: () {
                  return Future.delayed(Duration(seconds: 1), () {
                    setState(() {
                      context
                          .read<CompostScheduleBloc>()
                          .add(CompostScheduleList());
                      context.read<FoodWasteBloc>().add(FoodWasteList());
                      context
                          .read<SensorReadingBloc>()
                          .add(SensorReadingList());
                      context.read<LogBloc>().add(LogList());
                      context.read<WormActivityBloc>().add(WormActivityList());
                      context.read<StatusRecordBloc>().add(StatusRecordList());
                      context.read<NotificationBloc>().add(NotificationList());
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Page Refreshed',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        backgroundColor:
                            Theme.of(context).colorScheme.surfaceContainer,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHigh,
                          ),
                        ),
                      ),
                    );
                  });
                },
                child: Container(
                  height: deviceHeight,
                  width: deviceWidth,
                  padding: const EdgeInsets.fromLTRB(44, 54, 44, 28),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 44,
                      children: [
                        _homeScreenHeaderSection(
                          formattedDate: formattedDate,
                          formattedTime: formattedTime,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 20,
                          children: [
                            Expanded(
                              child:
                                  DailyReportWidget(sensorValues: sensorValues),
                            ),
                            Expanded(
                              child: SystemSummaryWidget(
                                summaryItems: _summaryItems,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: CompostingPerformanceOverviewWidget(
                                sensorReadingList: sensorReadingList,
                                foodWasteList: foodWasteList,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          spacing: 20,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CameraAndThermalMonitoringWidget(),
                            Expanded(
                              flex: 2,
                              child: EnvironmentalMetricsWidget(
                                sensorReadingList: sensorReadingList,
                              ),
                            ),
                          ],
                        ),
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
      ),
    );
  }

  Widget _homeScreenHeaderSection({
    required String formattedDate,
    required String formattedTime,
  }) {
    final AppSettingsCubit appSettingsCubit = GetIt.I<AppSettingsCubit>();

    String getGreeting() {
      final hour = DateTime.now().hour;
      if (hour < 12) {
        return 'Good Morning!';
      } else if (hour < 18) {
        return 'Good Afternoon!';
      } else {
        return 'Good Evening!';
      }
    }

    List<ButtonList> buttonList = [
      ButtonList(
          icon: FluentIcons.document_bullet_list_24_regular,
          onPressedFunction: () {
            Navigator.pushNamed(context, '/schedule');
          }),
      ButtonList(
          icon: FluentIcons.toggle_multiple_24_regular,
          onPressedFunction: () {
            Navigator.pushNamed(context, '/controls');
          }),
      ButtonList(
          icon: FluentIcons.text_bullet_list_ltr_24_filled,
          onPressedFunction: () {
            Navigator.pushNamed(context, '/logs');
          }),
      if (appSettingsCubit.state.devMode)
        ButtonList(
            icon: FluentIcons.table_settings_24_regular,
            onPressedFunction: () {
              Navigator.pushNamed(context, '/dev');
            }),
      ButtonList(
          icon: FluentIcons.settings_24_regular,
          onPressedFunction: () {
            Navigator.pushNamed(context, '/settings');
          }),
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        spacing: 18,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Glassmorphism(
                blur: 64,
                opacity: 0.3,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(64),
                          offset: const Offset(0, 4),
                          blurRadius: 6,
                          spreadRadius: -1,
                        ),
                      ],
                    ),
                    child: Image.asset("assets/icons/verminator_logo.png"),
                  ),
                ),
              ),
              Row(
                spacing: 8,
                children: [
                  NotificationWidget(
                    notificationList: notificationList,
                  ),
                  ...buttonList.asMap().entries.map((entry) {
                    final item = entry.value;
                    return OutlinedButton(
                      onPressed: item.onPressedFunction,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        minimumSize: Size.zero,
                        side: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHigh,
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        item.icon,
                        size: 28,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    );
                  })
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 6,
            children: [
              Text(
                getGreeting(),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "The following summary reflects system conditions as of $formattedDate at $formattedTime",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(186),
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ButtonList {
  final IconData icon;
  final VoidCallback onPressedFunction;

  ButtonList({
    required this.icon,
    required this.onPressedFunction,
  });
}

TimeGrouping getDateRange(int selectedRange) {
  switch (selectedRange) {
    case 1:
      return TimeGrouping.last7Days;
    case 2:
      return TimeGrouping.last30Days;
    case 3:
      return TimeGrouping.annual;
    default:
      return TimeGrouping.last24Hours;
  }
}
