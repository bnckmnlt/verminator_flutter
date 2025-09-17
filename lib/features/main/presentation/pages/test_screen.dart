import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vermicomposting/core/common/entities/layer_classes.dart';
import 'package:flutter_vermicomposting/core/common/widgets/empty_display_widget.dart';
import 'package:flutter_vermicomposting/core/common/widgets/loader.dart';
import 'package:flutter_vermicomposting/core/common/widgets/toast_helper.dart';
import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:flutter_vermicomposting/core/utils/format-to-local-time.dart';
import 'package:flutter_vermicomposting/core/utils/sensor_reading_to_daily_avg.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/domain/entities/compost_schedule.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/presentation/bloc/compost_schedule_bloc.dart';
import 'package:flutter_vermicomposting/features/food_waste/domain/entities/food_waste.dart';
import 'package:flutter_vermicomposting/features/food_waste/presentation/bloc/food_waste_bloc.dart';
import 'package:flutter_vermicomposting/features/logs/presentation/bloc/log_bloc.dart';
import 'package:flutter_vermicomposting/features/main/presentation/pages/home_screen.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/home_screen_widgets/SensorReadingCard.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/home_screen_widgets/notification_widget.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/home_screen_widgets/video_feed_widget.dart';
import 'package:flutter_vermicomposting/features/sensor_reading/domain/entity/sensor_reading.dart';
import 'package:flutter_vermicomposting/features/sensor_reading/presentation/bloc/sensor_reading_bloc.dart';
import 'package:flutter_vermicomposting/features/status/presentation/bloc/status_record_bloc.dart';
import 'package:flutter_vermicomposting/features/worm_activity/presentation/bloc/worm_activity_bloc.dart';
import 'package:flutter_vermicomposting/mqtt_service.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  late List<SummaryCardItem> _summaryItems;

  final DateTime now = DateTime.now();

  late MqttService _mqttService;

  late List<CompostSchedule> compostScheduleList;
  late List<FoodWaste> foodWasteList;
  late List<SensorReading> sensorReadingList;

  late bool cameraState;
  late bool thermalCameraState;

  WebViewController? cameraFeedController;
  WebViewController? thermalFeedController;

  int visionCurrentTab = 0;
  int chartOverviewCurrentTab = 0;
  int selectedChart = 0;
  int selectedDateRange = 1;

  bool compostScheduleLoadingState = true;
  bool foodWasteLoadingState = true;
  bool sensorReadingLoadingState = true;

  bool _hasLoaded = false;
  bool _hasFailed = false;

  List<String> _errorList = [];

  @override
  void initState() {
    _mqttService = GetIt.I<MqttService>();

    context.read<SensorReadingBloc>().add(SensorReadingList());

    cameraState = false;
    thermalCameraState = false;

    _mqttService.controlCameraStream.listen((value) {
      setState(() {
        cameraState = value == 'active' ? true : false;
      });
    });

    _mqttService.controlThermalStream.listen((value) {
      setState(() {
        thermalCameraState = value == 'active' ? true : false;
      });
    });

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoaded) {
      context.read<CompostScheduleBloc>().add(CompostScheduleList());
      context.read<FoodWasteBloc>().add(FoodWasteList());
      context.read<SensorReadingBloc>().add(SensorReadingList());
      context.read<LogBloc>().add(LogList());
      context.read<WormActivityBloc>().add(WormActivityList());
      context.read<StatusRecordBloc>().add(StatusRecordList());
      _hasLoaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double deviceHeight = MediaQuery.of(context).size.height;
    final double deviceWidth = MediaQuery.of(context).size.width;

    bool mountedState = !compostScheduleLoadingState &&
        !foodWasteLoadingState &&
        !sensorReadingLoadingState;

    final formattedDate = DateFormat('d MMMM y').format(now);
    final formattedTime = DateFormat('h:mm a')
        .format(DateTime.parse(formatToLocalTime(DateTime.now().toString())));

    final toastHelper = ToastHelper(context);

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: MultiBlocListener(
        listeners: [
          BlocListener<CompostScheduleBloc, CompostScheduleState>(
              listener: (context, state) {
            if (state is CompostScheduleLoading) {
              compostScheduleLoadingState = true;
            } else if (state is CompostScheduleListSuccess) {
              setState(() {
                compostScheduleLoadingState = false;
                compostScheduleList = state.compostScheduleList;
              });
            } else if (state is CompostScheduleFailure) {
              setState(() {
                _hasFailed = true;
                _errorList.add(state.error);
              });
            }
          }),
          BlocListener<FoodWasteBloc, FoodWasteState>(
              listener: (context, state) {
            if (state is FoodWasteLoading) {
              foodWasteLoadingState = true;
            } else if (state is FoodWasteListSuccess) {
              setState(() {
                foodWasteLoadingState = false;
                foodWasteList = state.foodWaste;
              });
            } else if (state is FoodWasteFailure) {
              setState(() {
                _hasFailed = true;
                _errorList.add(state.error);
              });
            }
          }),
          BlocListener<SensorReadingBloc, SensorReadingState>(
              listener: (context, state) {
            if (state is SensorReadingLoading) {
              sensorReadingLoadingState = true;
            } else if (state is SensorReadingListSuccess) {
              setState(() {
                sensorReadingLoadingState = false;
                sensorReadingList = state.list;
              });
            } else if (state is SensorReadingFailure) {
              setState(() {
                _hasFailed = true;
                _errorList.add(state.error);
              });
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
                    });

                    _mqttService.connect();

                    // showing snackbar
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
                child: SafeArea(
                  child: Container(
                    height: deviceHeight,
                    width: deviceWidth,
                    padding: const EdgeInsets.fromLTRB(32, 0, 32, 28),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 28,
                        children: [
                          _homeScreenHeaderSection(
                            formattedDate: formattedDate,
                            formattedTime: formattedTime,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 16,
                            children: [
                              _cameraAndThermalmonitoringSection(),
                              Expanded(
                                  child:
                                      _compostingPerformanceOverviewSection()),
                            ],
                          ),
                          Row(
                            spacing: 16,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: _environmentalMetricsSection(),
                              ),
                              Expanded(child: _dailyReportSection()),
                              Expanded(child: _summarySection()),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : _hasFailed
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
      ButtonList(
          icon: FluentIcons.settings_24_regular,
          onPressedFunction: () {
            Navigator.pushNamed(context, '/settings');
          }),
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 6,
            children: [
              Text(
                getGreeting(),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "The following summary reflects system conditions as of ${formattedDate} at ${formattedTime}",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(186),
                  fontSize: 18,
                ),
              ),
            ],
          ),
          Row(
            spacing: 8,
            children: [
              NotificationWidget(),
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
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
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
          )
        ],
      ),
    );
  }

  Widget _cameraAndThermalmonitoringSection() {
    final List<Map<String, dynamic>> cameraParameterList = [
      {
        "controller": cameraFeedController,
        "state": cameraState,
      },
      {
        "controller": thermalFeedController,
        "state": thermalCameraState,
      },
    ];

    bool state = cameraParameterList[visionCurrentTab]["state"];
    String source = Constants.serverList[visionCurrentTab]['src'];
    String topic = Constants.serverList[visionCurrentTab]['topic'];

    List<Map<String, dynamic>> functions = [
      {
        "icon": FluentIcons.power_24_filled,
        "function": () {
          _mqttService.publish(topic, cameraState ? "inactive" : "active",
              qos: MqttQos.atLeastOnce, retain: true);
        }
      },
      {
        "icon": FluentIcons.arrow_sync_24_filled,
        "function": () =>
            reloadWebView(cameraParameterList[visionCurrentTab]['controller']),
      },
    ];

    return SizedBox(
      width: 640,
      child: Column(
        spacing: 16,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Computer Vision and Thermal Feed",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          Column(
            spacing: 10,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  spacing: 14,
                  children: Constants.serverList.asMap().entries.map((entry) {
                    final int index = entry.key;
                    final Map<String, dynamic> item = entry.value;

                    bool activeTab = visionCurrentTab == index;

                    return GestureDetector(
                      onTap: () => setState(() => visionCurrentTab = index),
                      child: Row(
                        spacing: 8,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            transitionBuilder: (child, animation) =>
                                ScaleTransition(scale: animation, child: child),
                            child: activeTab
                                ? Container(
                                    key: const ValueKey('dot'),
                                    height: 6,
                                    width: 6,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      shape: BoxShape.circle,
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 250),
                            style: TextStyle(
                              color: activeTab
                                  ? Theme.of(context).colorScheme.onSurface
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withAlpha(124),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            child: Text(item['label']),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              Container(
                height: 425,
                width: 640,
                decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerLow
                        .withAlpha(124),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      width: 2,
                    )),
                child: Stack(
                  children: [
                    state
                        ? VideoFeedWidget(
                            onWebViewCreated: (controller) {
                              cameraParameterList[visionCurrentTab]
                                  ["controller"] = controller;
                            },
                            cameraChannel: source,
                          )
                        : Center(
                            child: EmptyDisplayWidget(
                              title: "Inactive Device",
                              description:
                                  "The device is currently not operational or has no active session.",
                            ),
                          ),
                    Positioned(
                      top: 20,
                      right: 20,
                      child: Container(
                          padding: const EdgeInsets.fromLTRB(14, 5, 14, 5),
                          decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                width: 1,
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest
                                    .withAlpha(32),
                              )),
                          child: Row(
                            spacing: 6,
                            children: [
                              Container(
                                height: 8,
                                width: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      state ? Colors.redAccent : Colors.white,
                                ),
                              ),
                              Text(
                                "LIVE",
                                style: TextStyle(
                                  color:
                                      state ? Colors.redAccent : Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 20,
                      child: Row(
                        spacing: 8,
                        children: List.generate(2, (int index) => index)
                            .asMap()
                            .entries
                            .map((entry) {
                          final int index = entry.key;
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Material(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withValues(alpha: 0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest
                                      .withAlpha(32),
                                  width: 1,
                                ),
                              ),
                              child: InkWell(
                                onTap: functions[index]['function'],
                                splashColor: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.1),
                                highlightColor: Colors.transparent,
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Icon(
                                    functions[index]['icon'],
                                    size: 24,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _compostingPerformanceOverviewSection() {
    List<ChartDatasource> beddingConditionCharts = [
      ChartDatasource(
        chartData: sensorReadingToDailyAvg<BeddingReading>(
          sensorReadingList,
          SystemLayer.bedding,
          (r) => r.temperature.value,
          limit: getDateRange(selectedDateRange),
        ),
        chartColor: Color(0xff2563EB),
      ),
      ChartDatasource(
        chartData: sensorReadingToDailyAvg<BeddingReading>(
          sensorReadingList,
          SystemLayer.bedding,
          (r) => r.humidity.value,
          limit: getDateRange(selectedDateRange),
        ),
        chartColor: Color(0xff3B86F7),
      ),
      ChartDatasource(
        chartData: sensorReadingToDailyAvg<BeddingReading>(
          sensorReadingList,
          SystemLayer.bedding,
          (r) => r.soilMoisture.value,
          limit: getDateRange(selectedDateRange),
        ),
        chartColor: Color(0xff90C7FE),
      ),
    ];

    List<ChartOverview> chartsOverviewTabs = [
      ChartOverview(
        label: "Nutrient Level",
        description: "The nutrient readings recorded throughout the month",
        annotation: <AnnotationData>[
          AnnotationData("Nitrogen", Color(0xff2563EB)),
          AnnotationData("Phosphorus", Color(0xff3B86F7)),
          AnnotationData("Potassium", Color(0xff90C7FE)),
        ],
        chartWidget: _nutrientLevelChartOverview(
          [
            ChartDatasource(
              chartData: sensorReadingToDailyAvg<CompostReading>(
                sensorReadingList,
                SystemLayer.compost,
                (r) => r.npk.nitrogen,
                limit: getDateRange(selectedDateRange),
              ),
              chartColor: Color(0xff2563EB),
            ),
            ChartDatasource(
              chartData: sensorReadingToDailyAvg<CompostReading>(
                sensorReadingList,
                SystemLayer.compost,
                (r) => r.npk.phosphorus,
                limit: getDateRange(selectedDateRange),
              ),
              chartColor: Color(0xff3B86F7),
            ),
            ChartDatasource(
              chartData: sensorReadingToDailyAvg<CompostReading>(
                sensorReadingList,
                SystemLayer.compost,
                (r) => r.npk.potassium,
                limit: getDateRange(selectedDateRange),
              ),
              chartColor: Color(0xff90C7FE),
            ),
          ],
        ),
      ),
      ChartOverview(
        label: "Bedding Condition",
        description: "The bedding condition recorded throughout the month",
        annotation: <AnnotationData>[
          AnnotationData("Temperature", Color(0xff2563EB)),
          AnnotationData("Humidity", Color(0xff3B86F7)),
          AnnotationData("Soil Moisture", Color(0xff90C7FE)),
        ],
        chartWidget: _beddingConditionChartOverview(
          beddingConditionCharts[selectedChart],
        ),
      ),
    ];

    Widget dateRangeFilter = PopupMenuButton(
      onSelected: (value) => setState(() {
        selectedDateRange = value;
      }),
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 0,
          child: Text('24 hours'),
        ),
        PopupMenuItem(
          value: 1,
          child: Text('1 week'),
        ),
        PopupMenuItem(
          value: 2,
          child: Text('1 month'),
        ),
        PopupMenuItem(
          value: 3,
          child: Text('1 year'),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.fromLTRB(28, 8, 28, 8),
        decoration: BoxDecoration(
          color: Colors.grey.withAlpha(32),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Theme.of(context).colorScheme.surfaceContainer,
          ),
        ),
        child: Text(
          ["24 hours", "1 week", "1 month", "1 year"][selectedDateRange],
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );

    Widget selection = PopupMenuButton(
      onSelected: (value) => setState(() {
        selectedChart = value;
      }),
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 0,
          child: Text('Temperature'),
        ),
        PopupMenuItem(
          value: 1,
          child: Text('Humidity'),
        ),
        PopupMenuItem(
          value: 2,
          child: Text('Soil Moisture'),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 8, 16, 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: Theme.of(context).colorScheme.surfaceContainer,
          ),
        ),
        child: Row(
          spacing: 6,
          children: [
            Text(
              chartsOverviewTabs[chartOverviewCurrentTab]
                  .annotation![selectedChart]
                  .label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            const Icon(
              FluentIcons.chevron_down_24_filled,
              size: 18,
            ),
          ],
        ),
      ),
    );

    return Column(
      spacing: 16,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Composting Performance Overview",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        Column(
          spacing: 10,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                spacing: 14,
                mainAxisAlignment: MainAxisAlignment.start,
                children: chartsOverviewTabs.asMap().entries.map((entry) {
                  final int index = entry.key;
                  final ChartOverview item = entry.value;

                  final bool activeTab = entry.key == chartOverviewCurrentTab;

                  return GestureDetector(
                    onTap: () =>
                        setState(() => chartOverviewCurrentTab = index),
                    child: Row(
                      spacing: 8,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          transitionBuilder: (child, animation) =>
                              ScaleTransition(scale: animation, child: child),
                          child: activeTab
                              ? Container(
                                  key: const ValueKey('dot'),
                                  height: 6,
                                  width: 6,
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    shape: BoxShape.circle,
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 250),
                          style: TextStyle(
                            color: activeTab
                                ? Theme.of(context).colorScheme.onSurface
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withAlpha(124),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          child: Text(item.label),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            Container(
              height: 425,
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerLow
                      .withAlpha(124),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    width: 2,
                  )),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 24,
                      left: 24,
                      child: Column(
                        spacing: 10,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          dateRangeFilter,
                          if (chartOverviewCurrentTab == 1) selection,
                        ],
                      ),
                    ),
                    Positioned(
                      top: 24,
                      right: 24,
                      child: Column(
                        spacing: 32,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            spacing: 4,
                            children: [
                              Text(
                                chartsOverviewTabs[chartOverviewCurrentTab]
                                    .label,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                chartsOverviewTabs[chartOverviewCurrentTab]
                                    .description,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withAlpha(186),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            spacing: 14,
                            children:
                                chartsOverviewTabs[chartOverviewCurrentTab]
                                    .annotation!
                                    .map((item) {
                              return Row(
                                spacing: 8,
                                children: [
                                  Container(
                                    height: 12,
                                    width: 12,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: item.color,
                                    ),
                                  ),
                                  Text(item.label),
                                ],
                              );
                            }).toList(),
                          )
                        ],
                      ),
                    ),
                    chartsOverviewTabs[chartOverviewCurrentTab].chartWidget,
                  ],
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _nutrientLevelChartOverview(
      List<ChartDatasource> nutrientLevelDatasources) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        height: 248,
        child: SfCartesianChart(
          margin: const EdgeInsets.all(0),
          plotAreaBorderWidth: 0,
          plotAreaBackgroundColor: Colors.transparent,
          primaryXAxis: CategoryAxis(
            axisLine: AxisLine(width: 0),
            borderWidth: 0,
            borderColor: Colors.transparent,
            labelPlacement: LabelPlacement.onTicks,
            edgeLabelPlacement: EdgeLabelPlacement.shift,
            majorGridLines: MajorGridLines(width: 0),
            majorTickLines: MajorTickLines(width: 0),
            isVisible: false,
          ),
          primaryYAxis: NumericAxis(
            labelPosition: ChartDataLabelPosition.inside,
            labelAlignment: LabelAlignment.end,
            tickPosition: TickPosition.inside,
            minorTickLines: MinorTickLines(width: 0),
            majorTickLines: MajorTickLines(width: 0),
            borderWidth: 0,
            plotOffset: 0,
            labelFormat: ' {value}%',
            labelStyle: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.025,
            ),
            axisLine: AxisLine(
              width: 0,
            ),
          ),
          series: <CartesianSeries>[
            ...nutrientLevelDatasources.map((item) {
              return SplineAreaSeries<ChartData, String>(
                sortingOrder: SortingOrder.ascending,
                dataSource: item.chartData,
                xValueMapper: (ChartData data, _) => data.x,
                yValueMapper: (ChartData data, _) => data.y,
                color: Colors.white,
                borderColor: Colors.white,
                borderWidth: 4,
                borderDrawMode: BorderDrawMode.top,
                gradient: LinearGradient(
                  colors: [
                    item.chartColor!.withAlpha(58),
                    item.chartColor!.withAlpha(24),
                    item.chartColor!.withAlpha(0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                markerSettings: MarkerSettings(
                  borderWidth: 1.5,
                  borderColor: Colors.white,
                  width: 12,
                  height: 12,
                  isVisible: true,
                  shape: DataMarkerType.circle,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _beddingConditionChartOverview(ChartDatasource datasource) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        height: 248,
        child: SfCartesianChart(
          margin: EdgeInsets.zero,
          plotAreaBorderWidth: 0,
          primaryXAxis: CategoryAxis(
            axisLine: AxisLine(width: 0),
            borderWidth: 0,
            borderColor: Colors.transparent,
            labelPlacement: LabelPlacement.onTicks,
            edgeLabelPlacement: EdgeLabelPlacement.shift,
            majorGridLines: MajorGridLines(width: 0),
            majorTickLines: MajorTickLines(width: 0),
            isVisible: false,
          ),
          primaryYAxis: NumericAxis(
            minimum: selectedChart == 0 ? 20 : 0,
            maximum: selectedChart == 0 ? 40 : 100,
            labelPosition: ChartDataLabelPosition.inside,
            labelAlignment: LabelAlignment.end,
            tickPosition: TickPosition.inside,
            minorTickLines: MinorTickLines(width: 0),
            majorTickLines: MajorTickLines(width: 0),
            borderWidth: 0,
            plotOffset: 0,
            labelFormat: ' {value}${selectedChart == 0 ? "°C" : "%"}',
            labelStyle: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.025,
            ),
            axisLine: AxisLine(
              width: 0,
            ),
          ),
          series: <CartesianSeries>[
            SplineAreaSeries<ChartData, String>(
              sortingOrder: SortingOrder.ascending,
              dataSource: datasource.chartData,
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y,
              color: Colors.white,
              borderColor: Colors.white,
              borderWidth: 4,
              borderDrawMode: BorderDrawMode.top,
              gradient: LinearGradient(
                colors: [
                  Colors.blueAccent.withAlpha(58),
                  Colors.blueAccent.withAlpha(24),
                  Colors.blueAccent.withAlpha(0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              markerSettings: MarkerSettings(
                borderWidth: 1.5,
                borderColor: Colors.white,
                width: 12,
                height: 12,
                isVisible: true,
                shape: DataMarkerType.circle,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _environmentalMetricsSection() {
    return SizedBox(
      child: Column(
        spacing: 16,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Environmental Metrics",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: 6,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (BuildContext context, int index) {
              final List<ChartData> readingList = (sensorReadingList
                      .where((reading) =>
                          reading.layer ==
                          Constants.parametersToMonitorList[index]['layer'])
                      .map((reading) {
                return ChartData(
                  reading.createdAt,
                  (convertToReading(
                          Constants.parametersToMonitorList[index]
                              ['reading_key'],
                          reading) ??
                      0),
                );
              }).toList())
                  .sublist(0, 7);

              return SensorReadingCard(
                key: Key(index.toString()),
                item: Constants.parametersToMonitorList[index],
                readingValueList: readingList,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _dailyReportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        Text(
          "Today's Report",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHigh
                .withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.surfaceContainer,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [Text("Hello World")],
          ),
        ),
      ],
    );
  }

  Widget _summarySection() {
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
        value:
            "${compostScheduleList.fold(0, (prev, next) => prev + int.parse(next.compostProduced as String))}",
        unit: "kg of soil",
        icon: Icons.eco_rounded,
        color: Colors.lightBlueAccent,
      ),
      SummaryCardItem(
        label: "Total Vermitea Collected",
        value:
            "${compostScheduleList.fold(0, (prev, next) => prev + int.parse(next.juiceProduced as String))}",
        unit: "L of vermitea",
        icon: FluentIcons.drink_bottle_20_filled,
        color: Colors.lightBlueAccent,
      ),
      SummaryCardItem(
        label: "Total Cycle/s Completed",
        value: "${compostScheduleList.length.toString()}",
        unit: " cycles",
        icon: FluentIcons.recycle_20_filled,
        color: Colors.lightBlueAccent,
      ),
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 18,
      children: [
        Text(
          "Summary",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        Column(
          spacing: 12,
          children: [
            ..._summaryItems.map((item) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.withAlpha(32),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      spacing: 2.5,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          textHeightBehavior: TextHeightBehavior(
                            applyHeightToLastDescent: false,
                            applyHeightToFirstAscent: true,
                          ),
                          "${item.value}${item.unit}",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          item.label,
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withAlpha(164),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        item.icon,
                        size: 28,
                        color: Colors.black87,
                      ),
                    )
                  ],
                ),
              );
            })
          ],
        ),
      ],
    );
  }

  void reloadWebView(WebViewController? _webViewController) {
    _webViewController?.reload();
  }
}

double? convertToReading(String sensor, SensorReading reading) {
  switch (sensor) {
    case "temperature":
      return reading.asBeddingReading?.temperature.value.toDouble();
    case "humidity":
      return reading.asBeddingReading?.humidity.value.toDouble();
    case "soil moisture":
      return reading.asBeddingReading?.soilMoisture.value.toDouble();
    case "nitrogen":
      return reading.asCompostReading?.npk.nitrogen.toDouble();
    case "phosphorus":
      return reading.asCompostReading?.npk.phosphorus.toDouble();
    case "potassium":
      return reading.asCompostReading?.npk.potassium.toDouble();
    default:
  }

  return 0.0;
}

int getDateRange(int selectedRange) {
  switch (selectedRange) {
    case 1:
      return 7;
    case 2:
      return 30;
    case 3:
      return 365;
    default:
      return 24;
  }
}

class ChartOverview {
  final String label;
  final String description;
  final List<AnnotationData>? annotation;
  final List<ChartData>? singleData;
  final Widget chartWidget;

  ChartOverview({
    required this.label,
    required this.description,
    this.annotation,
    this.singleData,
    required this.chartWidget,
  });
}

class ChartDatasource {
  final List<ChartData> chartData;
  final Color? chartColor;

  ChartDatasource({
    required this.chartData,
    required this.chartColor,
  });
}

class AnnotationData {
  final String label;
  final Color? color;

  AnnotationData(
    this.label,
    this.color,
  );
}
