import 'dart:convert';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vermicomposting/core/common/widgets/dialog.dart';
import 'package:flutter_vermicomposting/core/common/widgets/empty_display_widget.dart';
import 'package:flutter_vermicomposting/core/common/widgets/loader.dart';
import 'package:flutter_vermicomposting/core/common/widgets/toast_helper.dart';
import 'package:flutter_vermicomposting/core/error/exception.dart';
import 'package:flutter_vermicomposting/core/secrets/app_secrets.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/domain/entities/compost_schedule.dart';
import 'package:flutter_vermicomposting/features/food_waste/data/models/food_waste_model.dart';
import 'package:flutter_vermicomposting/features/food_waste/domain/entities/food_waste.dart';
import 'package:flutter_vermicomposting/features/food_waste/presentation/bloc/food_waste_bloc.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/home_screen_widgets/daily_report_widget.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/schedule_screen_widget/schedule_data_table_widget.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/schedule_screen_widget/schedule_hardware_profile_widget.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/schedule_screen_widget/schedule_screen_header_widget.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/schedule_screen_widget/schedule_substrate_charts_widget.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/schedule_screen_widget/schedule_system_overview_widget.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/schedule_screen_widget/schedule_waste_and_metrics_widget.dart';
import 'package:flutter_vermicomposting/features/sensor_reading/domain/entity/sensor_reading.dart';
import 'package:flutter_vermicomposting/features/sensor_reading/presentation/bloc/sensor_reading_bloc.dart';
import 'package:flutter_vermicomposting/features/worm_activity/domain/entity/worm_activity.dart';
import 'package:flutter_vermicomposting/features/worm_activity/presentation/bloc/worm_activity_bloc.dart';
import 'package:flutter_vermicomposting/mqtt_service.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tab_container/tab_container.dart';

import 'schedule_initialization/initialization_instruction_screen.dart';

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
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late SupabaseClient _supabaseClient;
  late MqttService _mqttService;
  late TabController _tabController;

  PromptBody _scheduleSummaryResponse =
      PromptBody(insight: "", recommendation: "");

  bool _hasAttemptedFetch = false;
  bool _responseLoaded = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _mqttService = GetIt.I<MqttService>();
    _supabaseClient = GetIt.I<SupabaseClient>();

    _tabController = TabController(length: 5, vsync: this);

    if (!_hasAttemptedFetch) {
      _hasAttemptedFetch = true;
      _getResponse();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<TabData> _buildTabData({
    required CompostSchedule compostSchedule,
    required List<FoodWaste> foodWasteList,
    required List<SensorReading> sensorReadingList,
    required List<WormActivity> wormActivityList,
  }) {
    return [
      TabData(
        icon: FluentIcons.brain_circuit_24_filled,
        tooltipMessage: "System Overview",
        childWidget: Padding(
          padding: const EdgeInsets.all(32),
          child: ScheduleSystemOverviewWidget(
            key: ValueKey(
                'overview_${_responseLoaded}_${_scheduleSummaryResponse.insight.hashCode}'),
            compostSchedule: compostSchedule,
            responseLoaded: _responseLoaded,
            scheduleSummaryResponse: _scheduleSummaryResponse,
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
            foodWasteList: foodWasteList,
          ),
        ),
      ),
      TabData(
        icon: FluentIcons.data_area_24_filled,
        tooltipMessage: "Substrate Metrics",
        childWidget: ScheduleSubstrateChartsWidget(
          sensorReadingList: sensorReadingList,
        ),
      ),
      TabData(
        icon: FluentIcons.document_table_24_filled,
        tooltipMessage: "Schedule Data Table",
        childWidget: ScheduleDataTableWidget(
          compostSchedule: compostSchedule,
          sensorReadingList: sensorReadingList,
          wormActivityList: wormActivityList,
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    double horizontalPadding = width * 0.05;
    double verticalPadding = height * 0.05;

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
      body: BlocBuilder<SensorReadingBloc, SensorReadingState>(
        builder: (context, sensorReadingState) {
          return BlocBuilder<FoodWasteBloc, FoodWasteState>(
            builder: (context, foodWasteState) {
              return BlocBuilder<WormActivityBloc, WormActivityState>(
                builder: (context, wormActivityState) {
                  final isSensorReadingLoading =
                      sensorReadingState is SensorReadingLoading;
                  final isFoodWasteLoading = foodWasteState is FoodWasteLoading;
                  final isWormActivityLoading =
                      wormActivityState is WormActivityLoading;

                  if (isSensorReadingLoading ||
                      isFoodWasteLoading ||
                      isWormActivityLoading) {
                    return const Center(child: Loader());
                  }

                  final sensorReadingError =
                      sensorReadingState is SensorReadingFailure
                          ? sensorReadingState.error
                          : null;
                  final foodWasteError = foodWasteState is FoodWasteFailure
                      ? foodWasteState.error
                      : null;
                  final wormActivityError =
                      wormActivityState is WormActivityFailure
                          ? wormActivityState.error
                          : null;

                  if (sensorReadingError != null ||
                      foodWasteError != null ||
                      wormActivityError != null) {
                    return _buildErrorState(
                      sensorReadingError: sensorReadingError,
                      foodWasteError: foodWasteError,
                      wormActivityError: wormActivityError,
                    );
                  }

                  if (sensorReadingState is SensorReadingListSuccess &&
                      foodWasteState is FoodWasteListSuccess &&
                      wormActivityState is WormActivityListSuccess) {
                    return _buildSuccessState(
                      context: context,
                      height: height,
                      width: width,
                      horizontalPadding: horizontalPadding,
                      verticalPadding: verticalPadding,
                      sensorReadingList: sensorReadingState.list,
                      foodWasteList: foodWasteState.foodWaste,
                      wormActivityList: wormActivityState.list,
                    );
                  }

                  return const Center(
                    child: EmptyDisplayWidget(
                      title: "Initializing",
                      description:
                          "Data fetching. It will take a few seconds to load.",
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSuccessState({
    required BuildContext context,
    required double height,
    required double width,
    required double horizontalPadding,
    required double verticalPadding,
    required List<SensorReading> sensorReadingList,
    required List<FoodWaste> foodWasteList,
    required List<WormActivity> wormActivityList,
  }) {
    final filteredSensorReadings = sensorReadingList
        .where((r) => r.sensorScheduleId == widget.compostSchedule.id)
        .toList();

    final filteredFoodWaste = foodWasteList
        .where(
            (entry) => entry.foodWasteScheduleId == widget.compostSchedule.id)
        .map((foodWaste) {
      final foodWasteModel = foodWaste as FoodWasteModel;
      final publicUrl = _supabaseClient.storage
          .from('image')
          .getPublicUrl(foodWasteModel.filePath);

      return foodWasteModel.copyWith(filePath: publicUrl);
    }).toList();

    final filteredWormActivity = wormActivityList
        .where(
            (activity) => activity.wormScheduleId == widget.compostSchedule.id)
        .toList();

    final tabData = _buildTabData(
      compostSchedule: widget.compostSchedule,
      foodWasteList: filteredFoodWaste,
      sensorReadingList: filteredSensorReadings,
      wormActivityList: filteredWormActivity,
    );

    return RefreshIndicator(
      onRefresh: () async {
        context.read<SensorReadingBloc>().add(SensorReadingList());
        context.read<FoodWasteBloc>().add(FoodWasteList());
        context.read<WormActivityBloc>().add(WormActivityList());
        await Future.delayed(const Duration(seconds: 1));
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
              compostSchedule: widget.compostSchedule,
            ),
            _scheduleHeaderAndAction(tabData),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState({
    String? sensorReadingError,
    String? foodWasteError,
    String? wormActivityError,
  }) {
    final errors = <String>[
      if (sensorReadingError != null) sensorReadingError,
      if (foodWasteError != null) foodWasteError,
      if (wormActivityError != null) wormActivityError,
    ];

    return Center(
      child: EmptyDisplayWidget(
        icon: FluentIcons.document_error_24_regular,
        title: "Error loading data",
        description: errors.join('\n'),
        action: () {
          context.read<SensorReadingBloc>().add(SensorReadingList());
          context.read<FoodWasteBloc>().add(FoodWasteList());
          context.read<WormActivityBloc>().add(WormActivityList());
        },
      ),
    );
  }

  Widget _scheduleHeaderAndAction(List<TabData> tabData) {
    return Expanded(
      flex: 3,
      child: Column(
        spacing: 10,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AnimatedBuilder(
                animation: _tabController,
                builder: (BuildContext context, _) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 12,
                    children: [
                      Text(
                        tabData[_tabController.index].tooltipMessage,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (_tabController.index == 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            color: Colors.lightBlue.withAlpha(64),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.lightBlue),
                          ),
                          child: const Text(
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
              if (!widget.compostSchedule.isCompleted)
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return GeneralDialog(
                          title: "Start Worm Feeding",
                          description:
                              "Are you ready to begin adding food waste to this composting batch? This will mark the start of the feeding process",
                          isDismissable: true,
                          confirmButtonLabel: "Continue",
                          approvedFunction: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              InitializationInstructionScreen.route(
                                widget.compostSchedule.id,
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0.75,
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    'Start Feeding',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TabContainer(
                    enabled: true,
                    enableFeedback: true,
                    controller: _tabController,
                    tabsEnd: 0.8,
                    tabExtent: 74,
                    tabEdge: TabEdge.right,
                    curve: Curves.easeIn,
                    childCurve: Curves.easeIn,
                    tabBorderRadius: BorderRadius.circular(12),
                    borderRadius: BorderRadius.circular(12),
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHigh
                        .withAlpha(124),
                    tabs: tabData.asMap().entries.map((tab) {
                      return AnimatedBuilder(
                        animation: _tabController,
                        builder: (context, _) {
                          final isActive = tab.key == _tabController.index;

                          return Tooltip(
                            message: tab.value.tooltipMessage,
                            child: Icon(
                              tab.value.icon,
                              size: 32,
                              color: isActive
                                  ? Theme.of(context).colorScheme.onSurface
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withAlpha(164),
                            ),
                          );
                        },
                      );
                    }).toList(),
                    children: tabData.map((tab) => tab.childWidget).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _getResponse() async {
    try {
      final response = await http.post(
        Uri.parse(
            "${AppSecrets.domainURL}/summary/${widget.compostSchedule.id}"),
      );

      if (response.statusCode == 200) {
        final responseBody = PromptBody.fromJson(jsonDecode(response.body));

        if (!mounted) return;

        setState(() {
          _scheduleSummaryResponse = responseBody;
          _responseLoaded = true;
        });
      }
    } on ServerException catch (e) {
      if (!mounted) return;

      ToastHelper(context).show(
        title: "Something went wrong",
        description: e.toString(),
        isError: true,
      );
    } catch (e) {
      if (!mounted) return;

      ToastHelper(context).show(
        title: "Unexpected error has occurred",
        description: e.toString(),
        isError: true,
      );
    }
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
