import 'dart:async';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vermicomposting/core/common/widgets/empty_display_widget.dart';
import 'package:flutter_vermicomposting/core/common/widgets/error_widget.dart';
import 'package:flutter_vermicomposting/core/common/widgets/loader.dart';
import 'package:flutter_vermicomposting/core/common/widgets/toast_helper.dart';
import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:flutter_vermicomposting/core/utils/format_to_local_time.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/domain/entities/compost_schedule.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/presentation/bloc/compost_schedule_bloc.dart';
import 'package:flutter_vermicomposting/features/food_waste/presentation/bloc/food_waste_bloc.dart';
import 'package:flutter_vermicomposting/features/logs/presentation/bloc/log_bloc.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/home_screen_widgets/bedding_condition_widget.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/home_screen_widgets/liquid_and_compost_level_widget.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/home_screen_widgets/materials_processed_widget.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/home_screen_widgets/notification_widget.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/home_screen_widgets/nutrient_summary_widget.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/home_screen_widgets/sensor_readings_widget.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/home_screen_widgets/system_information_widget.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/home_screen_widgets/video_feed_widget.dart';
import 'package:flutter_vermicomposting/features/sensor_reading/presentation/bloc/sensor_reading_bloc.dart';
import 'package:flutter_vermicomposting/features/status/presentation/bloc/status_record_bloc.dart';
import 'package:flutter_vermicomposting/features/worm_activity/presentation/bloc/worm_activity_bloc.dart';
import 'package:flutter_vermicomposting/mqtt_service.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late MqttService _mqttService;

  late StreamSubscription<String> _controlCameraSubscription;
  late StreamSubscription<String> _controlThermalSubscription;

  WebViewController? cameraFeedController;
  WebViewController? thermalFeedController;

  late bool cameraState;
  late bool thermalState;

  final DateTime now = DateTime.now();

  int _currentTab = 0;

  late CompostSchedule currentSchedule;

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive, overlays: []);

    _mqttService = GetIt.I<MqttService>();

    cameraState = false;
    thermalState = false;

    _controlCameraSubscription =
        _mqttService.controlCameraStream.listen((value) {
      setState(() {
        cameraState = value == 'active' ? true : false;
      });
    });

    _controlThermalSubscription =
        _mqttService.controlThermalStream.listen((value) {
      setState(() {
        thermalState = value == 'active' ? true : false;
      });
    });
  }

  bool _hasLoaded = false;

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
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive, overlays: []);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('d MMMM y').format(now);
    final formattedTime = DateFormat('h:mm a')
        .format(DateTime.parse(formatToLocalTime(DateTime.now().toString())));

    final toastHelper = ToastHelper(context);

    final List<Widget> _cardSections = [
      MaterialsProcessedWidget(),
      NutrientSummaryWidget(),
      BeddingConditionWidget(),
    ];

    final List<WebViewController?> controllerList = [
      cameraFeedController,
      thermalFeedController,
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final double deviceHeight = MediaQuery.of(context).size.height;
        final double deviceWidth = MediaQuery.of(context).size.width;

        final List<bool> monitoringStates = [
          cameraState,
          thermalState,
        ];

        return Scaffold(
          extendBody: true,
          extendBodyBehindAppBar: true,
          body: RefreshIndicator(
            onRefresh: () {
              return Future.delayed(Duration(seconds: 1), () {
                setState(() {
                  context
                      .read<CompostScheduleBloc>()
                      .add(CompostScheduleList());
                  context.read<FoodWasteBloc>().add(FoodWasteList());
                  context.read<SensorReadingBloc>().add(SensorReadingList());
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
                        color:
                            Theme.of(context).colorScheme.surfaceContainerHigh,
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
                padding: const EdgeInsets.fromLTRB(44, 44, 44, 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _homeScreenHeaderSection(
                      formattedDate: formattedDate,
                      formattedTime: formattedTime,
                    ),
                    const SizedBox(height: 44),
                    Expanded(
                      child: Row(
                        spacing: 16,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // TODO: 1ST ROW: []
                          Expanded(
                            child: Column(
                              spacing: 16,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                // TODO: SYSTEM CHARTS SECTION: []
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 24, horizontal: 24),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        width: 1,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surfaceContainerHigh,
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 0),
                                          child: Align(
                                            alignment: Alignment.topCenter,
                                            child: SingleChildScrollView(
                                              child: _cardSections[_currentTab],
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: Row(
                                            children: List.generate(
                                                    3, (int index) => index,
                                                    growable: false)
                                                .map((item) {
                                              return Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    item == 0 ? 0 : 6, 0, 0, 0),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      _currentTab = item;
                                                    });
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 4,
                                                        horizontal: 12),
                                                    decoration: BoxDecoration(
                                                      color: item == _currentTab
                                                          ? Theme.of(context)
                                                              .colorScheme
                                                              .surfaceContainerHigh
                                                          : Colors.transparent,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              24),
                                                      border: Border.all(
                                                        color: item ==
                                                                _currentTab
                                                            ? Color(0xFF27272a)
                                                            : Theme.of(context)
                                                                .colorScheme
                                                                .surfaceContainerHigh,
                                                      ),
                                                    ),
                                                    child: Text(
                                                      "${item + 1}",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // TODO: SENSOR PRESENT READINGS SECTION: []
                                Expanded(
                                  flex: 1,
                                  child: SensorReadingsWidget(
                                    mqttService: _mqttService,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // TODO: 2ND ROW: []
                          Expanded(
                            child: Row(
                              spacing: 16,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // TODO: CAMERA AND COMPOST/RESERVOIR SECTION: []
                                SingleChildScrollView(
                                  child: Column(
                                    spacing: 16,
                                    children: [
                                      ...Constants.serverList
                                          .asMap()
                                          .entries
                                          .map((entry) {
                                        final index = entry.key;
                                        final serverSrc = entry.value;

                                        return Container(
                                          height: 320,
                                          width: 320,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              width: 1,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .surfaceContainerHigh,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(4),
                                            child: Stack(
                                              children: [
                                                monitoringStates[index]
                                                    ? VideoFeedWidget(
                                                        onWebViewCreated:
                                                            (controller) {
                                                          controllerList[
                                                                  index] =
                                                              controller;
                                                        },
                                                        cameraChannel:
                                                            serverSrc['src'],
                                                      )
                                                    : Center(
                                                        child:
                                                            EmptyDisplayWidget(
                                                          title:
                                                              "Inactive Device",
                                                          description:
                                                              "The device is currently not operational or has no active session.",
                                                        ),
                                                      ),
                                                Positioned(
                                                  top: 18,
                                                  right: 6,
                                                  child: Container(
                                                      padding: const EdgeInsets
                                                          .fromLTRB(
                                                          12, 2, 12, 2),
                                                      decoration: BoxDecoration(
                                                          color: Theme.of(
                                                                  context)
                                                              .colorScheme
                                                              .surfaceContainerHighest
                                                              .withValues(
                                                                  alpha: 0.3),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                          border: Border.all(
                                                            width: 1,
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .surfaceContainerHighest
                                                                .withAlpha(32),
                                                          )),
                                                      child: Row(
                                                        spacing: 4,
                                                        children: [
                                                          Container(
                                                            height: 8,
                                                            width: 8,
                                                            decoration:
                                                                BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              color: monitoringStates[
                                                                      index]
                                                                  ? Colors
                                                                      .greenAccent
                                                                  : Colors
                                                                      .redAccent,
                                                            ),
                                                          ),
                                                          Text(
                                                            monitoringStates[
                                                                    index]
                                                                ? "Active"
                                                                : "Inactive",
                                                            style: TextStyle(
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ],
                                                      )),
                                                ),
                                                Positioned(
                                                  bottom: 10,
                                                  left: 6,
                                                  child: Container(
                                                      padding: const EdgeInsets
                                                          .fromLTRB(
                                                          14, 4, 14, 4),
                                                      decoration: BoxDecoration(
                                                          color: Theme.of(
                                                                  context)
                                                              .colorScheme
                                                              .surfaceContainerHighest
                                                              .withValues(
                                                                  alpha: 0.5),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                          border: Border.all(
                                                            width: 1,
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .surfaceContainerHighest
                                                                .withAlpha(32),
                                                          )),
                                                      child: Text(
                                                        index == 0
                                                            ? "Pi Camera – Material Classification"
                                                            : "MLX90640 – Worm Monitoring",
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      )),
                                                ),
                                                Positioned(
                                                  bottom: 6,
                                                  right: 6,
                                                  child: Row(
                                                    spacing: 8,
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4),
                                                        child: Material(
                                                          color: Theme.of(
                                                                  context)
                                                              .colorScheme
                                                              .surfaceContainerHighest
                                                              .withValues(
                                                                  alpha: 0.5),
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4),
                                                            side: BorderSide(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .surfaceContainerHighest
                                                                  .withAlpha(
                                                                      32),
                                                              width: 1,
                                                            ),
                                                          ),
                                                          child: InkWell(
                                                            onTap: () {
                                                              _mqttService.publish(
                                                                  serverSrc[
                                                                      'topic'],
                                                                  monitoringStates[
                                                                          index]
                                                                      ? "inactive"
                                                                      : "active",
                                                                  qos: MqttQos
                                                                      .atLeastOnce,
                                                                  retain: true);
                                                            },
                                                            splashColor: Theme
                                                                    .of(context)
                                                                .colorScheme
                                                                .primary
                                                                .withOpacity(
                                                                    0.1),
                                                            highlightColor:
                                                                Colors
                                                                    .transparent,
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Icon(
                                                                FluentIcons
                                                                    .power_24_filled,
                                                                size: 18,
                                                                color: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .onSurface,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4),
                                                        child: Material(
                                                          color: Theme.of(
                                                                  context)
                                                              .colorScheme
                                                              .surfaceContainerHighest
                                                              .withValues(
                                                                  alpha: 0.5),
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4),
                                                            side: BorderSide(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .surfaceContainerHighest
                                                                  .withAlpha(
                                                                      32),
                                                              width: 1,
                                                            ),
                                                          ),
                                                          child: InkWell(
                                                            onTap: () {
                                                              reloadWebView(
                                                                  controllerList[
                                                                      index]);
                                                            },
                                                            splashColor: Theme
                                                                    .of(context)
                                                                .colorScheme
                                                                .primary
                                                                .withOpacity(
                                                                    0.1),
                                                            highlightColor:
                                                                Colors
                                                                    .transparent,
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Icon(
                                                                FluentIcons
                                                                    .arrow_sync_24_filled,
                                                                size: 18,
                                                                color: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .onSurface,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }),
                                      LiquidAndCompostLevelWidget(
                                          mqttService: _mqttService),
                                    ],
                                  ),
                                ),
                                // TODO:SYSTEM HEALTH SECTION: []
                                Expanded(
                                  child: BlocConsumer<CompostScheduleBloc,
                                      CompostScheduleState>(
                                    listener: (context, state) {
                                      if (state is CompostScheduleFailure) {
                                        toastHelper.show(
                                          title: "An error has occurred",
                                          description: state.error,
                                          isError: true,
                                        );
                                      }
                                    },
                                    builder: (context, compostScheduleState) {
                                      if (compostScheduleState
                                          is CompostScheduleLoading) {
                                        return const Loader();
                                      }
                                      if (compostScheduleState
                                          is CompostScheduleFailure) {
                                        return Center(
                                          child: GeneralErrorWidget(
                                            errorTitle:
                                                "An error has occurred during fetching",
                                            errorMessage:
                                                compostScheduleState.error,
                                          ),
                                        );
                                      }
                                      if (compostScheduleState
                                          is CompostScheduleListSuccess) {
                                        return BlocConsumer<FoodWasteBloc,
                                            FoodWasteState>(
                                          listener: (context, state) {
                                            if (state is FoodWasteFailure) {
                                              toastHelper.show(
                                                title: "An error has occurred",
                                                description: state.error,
                                                isError: true,
                                              );
                                            }
                                          },
                                          builder: (context, foodWasteState) {
                                            if (foodWasteState
                                                is FoodWasteLoading) {
                                              return const Loader();
                                            }
                                            if (foodWasteState
                                                is FoodWasteFailure) {
                                              return Center(
                                                child: GeneralErrorWidget(
                                                  errorTitle:
                                                      "An error has occurred during fetching",
                                                  errorMessage:
                                                      foodWasteState.error,
                                                ),
                                              );
                                            }
                                            if (foodWasteState
                                                is FoodWasteListSuccess) {
                                              return SystemInformationWidget(
                                                mqttService: _mqttService,
                                                scheduleData:
                                                    compostScheduleState
                                                        .compostScheduleList,
                                                foodWasteData:
                                                    foodWasteState.foodWaste,
                                              );
                                            }
                                            return const Loader();
                                          },
                                        );
                                      }
                                      return const Loader();
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              getGreeting(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "The following summary reflects system conditions as of ${formattedDate} at ${formattedTime}",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(186),
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
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
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
                  size: 24,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              );
            })
          ],
        )
      ],
    );
  }

  void reloadWebView(WebViewController? _webViewController) {
    _webViewController?.reload();
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
