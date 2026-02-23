import 'dart:async';
import 'dart:convert';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vermicomposting/core/common/widgets/custom_searchbar_widget.dart';
import 'package:flutter_vermicomposting/core/common/widgets/dialog.dart';
import 'package:flutter_vermicomposting/core/common/widgets/empty_display_widget.dart';
import 'package:flutter_vermicomposting/core/common/widgets/get_progress_value.dart';
import 'package:flutter_vermicomposting/core/common/widgets/loader.dart';
import 'package:flutter_vermicomposting/core/common/widgets/toast_helper.dart';
import 'package:flutter_vermicomposting/core/secrets/app_secrets.dart';
import 'package:flutter_vermicomposting/core/utils/extract_by_day.dart';
import 'package:flutter_vermicomposting/core/utils/parse_error_message.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/data/models/compost_schedule_model.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/domain/entities/compost_schedule.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/presentation/bloc/compost_schedule_bloc.dart';
import 'package:flutter_vermicomposting/features/main/presentation/pages/schedule_initialization/initialization_instruction_screen.dart';
import 'package:flutter_vermicomposting/features/main/presentation/pages/schedule_screen.dart';
import 'package:flutter_vermicomposting/features/status/domain/entity/status_record.dart';
import 'package:flutter_vermicomposting/features/status/presentation/bloc/status_record_bloc.dart';
import 'package:flutter_vermicomposting/mqtt_service.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:mqtt_client/mqtt_client.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:timeago/timeago.dart' as timeago;

class ScheduleListScreen extends StatefulWidget {
  const ScheduleListScreen({super.key});

  @override
  State<ScheduleListScreen> createState() => _ScheduleListScreenState();
}

class _ScheduleListScreenState extends State<ScheduleListScreen> {
  late MqttService _mqttService;

  final formKey = GlobalKey<FormState>();
  final TextEditingController _scheduleIdentifierController =
      TextEditingController();

  final ValueNotifier<String> _searchQuery = ValueNotifier('');

  Timer? _debounce;

  List<CompostSchedule> _compostSchedules = [];
  List<StatusRecord> _statusRecords = [];

  @override
  void initState() {
    super.initState();

    _mqttService = GetIt.I<MqttService>();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchQuery.dispose();
    _scheduleIdentifierController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double deviceHeight = MediaQuery.sizeOf(context).height;
    final double deviceWidth = MediaQuery.sizeOf(context).width;

    final double verticalPadding = deviceHeight * 0.05;
    final double horizontalPadding = deviceWidth * 0.05;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme:
            IconThemeData(color: Theme.of(context).colorScheme.onSurface),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocBuilder<CompostScheduleBloc, CompostScheduleState>(
          builder: (context, scheduleState) {
        return BlocBuilder<StatusRecordBloc, StatusRecordState>(
            builder: (context, statusState) {
          final isCompostLoading = scheduleState is CompostScheduleLoading;
          final isStatusLoading = statusState is StatusRecordLoading;

          if (isCompostLoading || isStatusLoading) {
            return Loader();
          }

          final compostError = scheduleState is CompostScheduleFailure
              ? scheduleState.error
              : null;
          final statusError =
              statusState is StatusRecordFailure ? statusState.error : null;

          if (compostError != null || statusError != null) {
            return _buildErrorState(
              compostError: compostError,
              statusError: statusError,
            );
          }

          if (scheduleState is CompostScheduleListSuccess &&
              statusState is StatusRecordListSuccess) {
            _compostSchedules = scheduleState.compostScheduleList;
            _statusRecords = statusState.statusRecordList;

            return SafeArea(
              child: Container(
                height: deviceHeight,
                width: deviceWidth,
                padding: EdgeInsets.symmetric(
                  vertical: verticalPadding,
                  horizontal: horizontalPadding,
                ),
                child: SingleChildScrollView(child: _buildContent()),
              ),
            );
          }

          return EmptyDisplayWidget(
            title: "Initializing",
            description: "Data fetching. It will take a few seconds to load.",
          );
        });
      }),
    );
  }

  Widget _buildErrorState({
    String? compostError,
    String? statusError,
  }) {
    final errors = <String>[
      if (compostError != null) compostError,
      if (statusError != null) statusError,
    ];

    return Center(
      child: EmptyDisplayWidget(
        icon: FluentIcons.document_error_24_regular,
        title: "Error loading data",
        description: errors.map((error) => "$error\n").toString(),
        action: () {
          context.read<CompostScheduleBloc>().add(CompostScheduleList());
          context.read<StatusRecordBloc>().add(StatusRecordList());
        },
      ),
    );
  }

  Widget _scheduleListControls() {
    final toastHelper = ToastHelper(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          spacing: 8,
          children: [
            SizedBox(
              height: MediaQuery.sizeOf(context).width * 0.0275,
              width: MediaQuery.sizeOf(context).width * 0.23,
              child: CustomSearchBarWidget.build(
                context: context,
                onChangedFunction: (value) {
                  if (_debounce?.isActive ?? false) _debounce!.cancel();
                  _debounce = Timer(const Duration(milliseconds: 300), () {
                    _searchQuery.value = value;
                  });
                },
                label: "Search schedule name",
                leadingIcon: Icon(
                  FluentIcons.search_24_regular,
                  size: 20,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                context.read<CompostScheduleBloc>().add(CompostScheduleList());
                context.read<StatusRecordBloc>().add(StatusRecordList());
              },
              style: TextButton.styleFrom(
                foregroundColor:
                    Theme.of(context).colorScheme.onSurface.withAlpha(164),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 6,
                children: [
                  Icon(
                    FluentIcons.arrow_clockwise_24_filled,
                    color:
                        Theme.of(context).colorScheme.onSurface.withAlpha(164),
                  ),
                  Text(
                    "Refresh",
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: "Zenbones Mono",
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.025,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
        ElevatedButton(
          onPressed:
              _compostSchedules.isEmpty || !_compostSchedules.first.isCompleted
                  ? null
                  : () => _handleScheduleCreation(context, toastHelper),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade400,
            disabledForegroundColor: Colors.white70,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
            minimumSize: Size.zero,
          ),
          child: Row(
            spacing: 8,
            children: [
              Text(
                "New",
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: "Zenbones Mono",
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.025,
                ),
              ),
              const Icon(
                FluentIcons.add_24_filled,
                color: Colors.white,
                grade: 100,
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Column(
      spacing: 44,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 38,
          children: [
            Text(
              "Compost Schedules",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            _scheduleListControls(),
          ],
        ),
        ValueListenableBuilder<String>(
          valueListenable: _searchQuery,
          builder: (context, searchQuery, _) {
            final filteredSchedules = _compostSchedules.where((item) {
              final bool matchesSearch = searchQuery.isEmpty
                  ? true
                  : item.scheduleName
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase());
              return matchesSearch;
            }).toList();

            return Column(
              children: filteredSchedules.map((schedule) {
                return _buildScheduleCard(schedule);
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildScheduleCard(CompostSchedule schedule) {
    final StatusRecord statusRecord = _statusRecords
        .where((record) => record.scheduleId == schedule.id)
        .toList()
        .first;

    final timeCreated = DateTime.parse(statusRecord.createdAt);
    final String ago = timeago.format(timeCreated);

    final bool scheduleCompleted = schedule.isCompleted;
    final scheduleStatus = scheduleCompleted ? "COMPLETED" : "RUNNING";
    final statusCompleted = statusRecord.isCompleted;
    final statusColor =
        statusCompleted ? Colors.greenAccent : Colors.blueAccent;
    final Color color = scheduleCompleted ? Colors.greenAccent : Colors.amber;

    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ScheduleScreen(compostSchedule: schedule)));
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 28, horizontal: 24),
        decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            width: 1,
          )),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              spacing: 12,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      extractDay(
                          format: "EEE, MMM d y · h:mm a", schedule.createdAt),
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withAlpha(164),
                        fontSize: 16,
                        fontFamily: "Zenbones Mono",
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: color,
                          )),
                      child: Text(
                        scheduleStatus,
                        style: TextStyle(
                          color: color,
                          fontFamily: "Zenbones Mono",
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.025,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  schedule.scheduleName,
                  style: TextStyle(
                    fontSize: 32,
                    fontFamily: "Zenbones Mono",
                  ),
                ),
              ],
            ),
            Column(
              spacing: 18,
              children: [
                Column(
                  spacing: 16,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "Composting Status: ",
                              style: TextStyle(
                                fontFamily: "Zenbones Mono",
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 5,
                                horizontal: 14,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withAlpha(24),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                statusRecord.status.name.toUpperCase(),
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 12,
                                  fontFamily: "Zenbones Mono",
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "${(getProgressValue(statusRecord.status) * 100).toInt()}%",
                          style: TextStyle(
                            fontSize: 64,
                            fontFamily: "Zenbones Mono",
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.025,
                            height: 0.75,
                          ),
                        ),
                      ],
                    ),
                    StepProgressIndicator(
                      totalSteps: 50,
                      currentStep:
                          (getProgressValue(statusRecord.status) * 50).toInt(),
                      size: 24,
                      selectedColor: statusColor,
                      unselectedColor:
                          Theme.of(context).colorScheme.surfaceContainerHigh,
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      spacing: 8,
                      children: [
                        _toStatusWidget<CompostSchedule>(
                            item: schedule,
                            selector: (r) => "${r.compostProduced}kg",
                            icon: Icon(
                              FluentIcons.plant_grass_24_regular,
                              size: 20,
                            )),
                        _toStatusWidget<CompostSchedule>(
                            item: schedule,
                            selector: (r) => "${r.juiceProduced}L",
                            icon: Icon(
                              FluentIcons.drop_24_regular,
                              size: 20,
                            )),
                      ],
                    ),
                    Text(
                      "last updated $ago",
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withAlpha(124),
                      ),
                    )
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _handleScheduleCreation(
      BuildContext context, ToastHelper toastHelper) async {
    showDialog(
      context: context,
      builder: (_) => GeneralDialog(
        title: 'Create compost schedule',
        description:
            'Give your composting cycle a name (e.g., Backyard Pile 1)',
        confirmButtonLabel: 'Continue',
        widget: Form(
          key: formKey,
          child: TextFormField(
            controller: _scheduleIdentifierController,
            validator: (value) => (value == null || value.trim().length <= 8)
                ? "Compost schedule name must be at least 9 characters."
                : null,
          ),
        ),
        approvedFunction: () async {
          if (!formKey.currentState!.validate()) return;
          final name = _scheduleIdentifierController.text.trim();
          Navigator.pop(context);

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator()),
          );

          Future<void> fail(String title, String message) async {
            Navigator.pop(context);
            toastHelper.show(title: title, description: message, isError: true);
          }

          try {
            final scheduleResp = await http.post(
              Uri.parse("${AppSecrets.domainURL}/schedule"),
              headers: {'Content-Type': 'application/json; charset=UTF-8'},
              body: jsonEncode({
                "scheduleName": name,
                "compostProduced": "0",
                "juiceProduced": "0",
              }),
            );

            if (scheduleResp.statusCode != 200) {
              await fail("Schedule creation failed",
                  scheduleResp.body.parseErrorMessage());
              return;
            }

            final CompostSchedule inserted =
                CompostScheduleModel.fromJson(jsonDecode(scheduleResp.body));

            Navigator.pop(context);

            toastHelper.show(
              title: "Compost Schedule Created",
              description: "Tracking for $name is now ready.",
              isError: false,
            );

            final settingsPayload = {
              "status": "idle",
              "id": inserted.id.toString(),
              "reading_interval":
                  _mqttService.lastSystemSettings!['reading_interval'],
              "refresh_rate": _mqttService.lastSystemSettings!['refresh_rate'],
            };

            _mqttService.publish(
              "system/settings",
              jsonEncode(settingsPayload),
              qos: MqttQos.atLeastOnce,
              retain: true,
            );

            context.read<CompostScheduleBloc>().add(CompostScheduleList());
            context.read<StatusRecordBloc>().add(StatusRecordList());

            showDialog(
              context: context,
              builder: (_) => GeneralDialog(
                title: 'Begin feeding',
                description: 'Would you like to begin feeding for $name?',
                confirmButtonLabel: 'Confirm',
                approvedFunction: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => InitializationInstructionScreen(
                              scheduleId: inserted.id,
                            )),
                  );
                },
              ),
            );
          } catch (e) {
            await fail("Unexpected Error", e.toString());
          }
        },
      ),
    );
  }

  Widget _toStatusWidget<T>({
    required T item,
    required String Function(T) selector,
    Icon? icon,
  }) {
    return Row(
      spacing: 4,
      children: [
        icon ?? SizedBox.shrink(),
        Text(
          selector(item),
          style: TextStyle(
            fontSize: 16,
            fontFamily: "Zenbones Mono",
            fontWeight: FontWeight.w600,
            letterSpacing: 0.025,
          ),
        ),
      ],
    );
  }
}
