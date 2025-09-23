import 'dart:convert';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vermicomposting/core/common/widgets/custom_searchbar_widget.dart';
import 'package:flutter_vermicomposting/core/common/widgets/dialog.dart';
import 'package:flutter_vermicomposting/core/common/widgets/get_progress_value.dart';
import 'package:flutter_vermicomposting/core/common/widgets/loader.dart';
import 'package:flutter_vermicomposting/core/common/widgets/toast_helper.dart';
import 'package:flutter_vermicomposting/core/utils/extract_by_day.dart';
import 'package:flutter_vermicomposting/core/utils/parse_error_message.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/data/models/compost_schedule_model.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/domain/entities/compost_schedule.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/presentation/bloc/compost_schedule_bloc.dart';
import 'package:flutter_vermicomposting/features/main/presentation/pages/schedule_initialization/initialization_instruction_screen.dart';
import 'package:flutter_vermicomposting/features/main/presentation/pages/schedule_screen.dart';
import 'package:flutter_vermicomposting/features/status/domain/entity/status_record.dart';
import 'package:flutter_vermicomposting/features/status/presentation/bloc/status_record_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:timeago/timeago.dart' as timeago;

class ScheduleListScreen extends StatefulWidget {
  const ScheduleListScreen({super.key});

  @override
  State<ScheduleListScreen> createState() => _ScheduleListScreenState();
}

class _ScheduleListScreenState extends State<ScheduleListScreen> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController _scheduleIdentifierController =
      TextEditingController();

  String _searchQuery = '';

  bool _hasInitialized = false;

  bool _loading = true;
  bool _hasError = false;

  final List<String> _errors = [];
  List<CompostSchedule> _compostSchedules = [];
  List<StatusRecord> _statusRecords = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasInitialized) {
      context.read<CompostScheduleBloc>().add(CompostScheduleList());
      context.read<StatusRecordBloc>().add(StatusRecordList());
      _hasInitialized = true;
    }
  }

  @override
  void dispose() {
    _searchQuery = '';
    _scheduleIdentifierController.clear();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double deviceHeight = MediaQuery.of(context).size.height;
    final double deviceWidth = MediaQuery.of(context).size.width;

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
      body: MultiBlocListener(
        listeners: [
          BlocListener<CompostScheduleBloc, CompostScheduleState>(
            listener: (context, state) {
              if (state is CompostScheduleLoading) {
                setState(() => _loading = true);
              } else if (state is CompostScheduleListSuccess) {
                setState(() {
                  _compostSchedules = state.compostScheduleList;
                  _loading = _statusRecords.isEmpty;
                });
              } else if (state is CompostScheduleFailure) {
                setState(() {
                  _hasError = true;
                  _errors.add(state.error);
                  _loading = false;
                });
              }
            },
          ),
          BlocListener<StatusRecordBloc, StatusRecordState>(
            listener: (context, state) {
              if (state is StatusRecordLoading) {
                setState(() => _loading = true);
              } else if (state is StatusRecordListSuccess) {
                setState(() {
                  _statusRecords = state.statusRecordList;
                  _loading = _compostSchedules.isEmpty;
                });
              } else if (state is StatusRecordFailure) {
                setState(() {
                  _hasError = true;
                  _errors.add(state.error);
                  _loading = false;
                });
              }
            },
          ),
        ],
        child: SafeArea(
          child: Container(
            height: deviceHeight,
            width: deviceWidth,
            padding: EdgeInsets.symmetric(
              vertical: verticalPadding,
              horizontal: horizontalPadding,
            ),
            child: _loading
                ? Center(child: const Loader())
                : _hasError
                    ? _buildError()
                    : SingleChildScrollView(child: _buildContent()),
          ),
        ),
      ),
    );
  }

  Widget _buildError() => Center(
        child: Text(
          _errors.join('\n'),
          style: const TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        ),
      );

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
              height: MediaQuery.of(context).size.width * 0.0275,
              width: MediaQuery.of(context).size.width * 0.23,
              child: CustomSearchBarWidget.build(
                  context: context,
                  onChangedFunction: (value) => setState(() {
                        _searchQuery = value;
                      }),
                  label: "Search schedule name",
                  leadingIcon: Icon(
                    FluentIcons.search_24_regular,
                    size: 20,
                  )),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  context
                      .read<CompostScheduleBloc>()
                      .add(CompostScheduleList());
                  context.read<StatusRecordBloc>().add(StatusRecordList());
                });
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
          onPressed: () => _handleScheduleCreation(context, toastHelper),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
            minimumSize: Size.zero,
          ),
          child: Row(
            spacing: 8,
            children: [
              Text(
                "New",
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: "Zenbones Mono",
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.025,
                ),
              ),
              Icon(
                FluentIcons.add_24_filled,
                color: Colors.white,
                grade: 100,
              )
            ],
          ),
        )
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
        Column(
          children: _compostSchedules.where((item) {
            final bool matchesSearch = _searchQuery.isEmpty
                ? true
                : item.scheduleName
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase());
            return matchesSearch;
          }).map((schedule) {
            final timeCreated = DateTime.parse(schedule.updatedAt);
            final String ago = timeago.format(timeCreated);

            final StatusRecord statusRecord = _statusRecords
                .where((record) => record.scheduleId == schedule.id)
                .toList()
                .first;

            final bool scheduleCompleted = schedule.isCompleted;
            final scheduleStatus = scheduleCompleted ? "COMPLETED" : "RUNNING";
            final statusCompleted = statusRecord.isCompleted;
            final statusColor =
                statusCompleted ? Colors.greenAccent : Colors.blueAccent;
            final Color color =
                scheduleCompleted ? Colors.greenAccent : Colors.amber;

            return InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            ScheduleScreen(scheduleId: schedule.id)));
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 28, horizontal: 24),
                decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
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
                                  format: "EEE, MMM d y · h:mm a",
                                  schedule.createdAt),
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
                                  (getProgressValue(statusRecord.status) * 50)
                                      .toInt(),
                              size: 24,
                              selectedColor: statusColor,
                              unselectedColor: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHigh,
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
          }).toList(),
        )
      ],
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
              Uri.parse("https://verminator.thinkio.me/schedule"),
              headers: {'Content-Type': 'application/json; charset=UTF-8'},
              body: jsonEncode({"scheduleName": name}),
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
    return Container(
      child: Row(
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
      ),
    );
  }
}
