import 'dart:convert';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vermicomposting/core/common/widgets/dialog.dart';
import 'package:flutter_vermicomposting/core/common/widgets/empty_display_widget.dart';
import 'package:flutter_vermicomposting/core/common/widgets/loader.dart';
import 'package:flutter_vermicomposting/core/common/widgets/status_badge.dart';
import 'package:flutter_vermicomposting/core/common/widgets/toast_helper.dart';
import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:flutter_vermicomposting/core/utils/parse_error_message.dart';
import 'package:flutter_vermicomposting/core/utils/string_extensions.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/data/models/compost_schedule_model.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/domain/entities/compost_schedule.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/presentation/bloc/compost_schedule_bloc.dart';
import 'package:flutter_vermicomposting/features/food_waste/presentation/bloc/food_waste_bloc.dart';
import 'package:flutter_vermicomposting/features/logs/presentation/bloc/log_bloc.dart';
import 'package:flutter_vermicomposting/features/main/presentation/pages/schedule_initialization/initialization_instruction_screen.dart';
import 'package:flutter_vermicomposting/features/main/presentation/pages/schedule_screen.dart';
import 'package:flutter_vermicomposting/features/sensor_reading/presentation/bloc/sensor_reading_bloc.dart';
import 'package:flutter_vermicomposting/features/status/domain/entity/status_record.dart';
import 'package:flutter_vermicomposting/features/status/presentation/bloc/status_record_bloc.dart';
import 'package:flutter_vermicomposting/features/worm_activity/presentation/bloc/worm_activity_bloc.dart';
import 'package:http/http.dart' as http;

class ScheduleListScreen extends StatefulWidget {
  const ScheduleListScreen({super.key});

  @override
  State<ScheduleListScreen> createState() => _ScheduleListScreenState();
}

class _ScheduleListScreenState extends State<ScheduleListScreen> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController _scheduleIdentifierController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    final double deviceHeight = MediaQuery.of(context).size.height;
    final double deviceWidth = MediaQuery.of(context).size.width;

    final toastHelper = ToastHelper(context);

    return SafeArea(
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          iconTheme:
              IconThemeData(color: Theme.of(context).colorScheme.onSurface),
          backgroundColor: Colors.transparent,
          elevation: 0.0,
        ),
        floatingActionButton: FloatingActionButton(
          elevation: 0,
          backgroundColor: Colors.blueAccent.withAlpha(64),
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          shape: CircleBorder(
            side: BorderSide(color: Colors.blueAccent),
          ),
          onPressed: () => _handleScheduleCreation(context, toastHelper),
          child: const Icon(
            size: 28,
            Icons.add,
          ),
        ),
        body: BlocBuilder<CompostScheduleBloc, CompostScheduleState>(
          builder: (context, state) {
            if (state is CompostScheduleLoading) {
              return Center(
                child: Loader(),
              );
            } else if (state is CompostScheduleFailure) {
              return EmptyDisplayWidget(
                description: state.error,
                title: 'An error has occurred',
                icon: FluentIcons.cloud_error_24_regular,
              );
            } else if (state is CompostScheduleListSuccess) {
              return BlocBuilder<StatusRecordBloc, StatusRecordState>(
                  builder: (context, statusState) {
                if (statusState is StatusRecordLoading) {
                  return Center(
                    child: Loader(),
                  );
                } else if (statusState is StatusRecordFailure) {
                  return EmptyDisplayWidget(
                    description: statusState.error,
                    title: 'An error has occurred',
                    icon: FluentIcons.cloud_error_24_regular,
                  );
                } else if (statusState is StatusRecordListSuccess) {
                  final statusList = statusState.statusRecordList
                    ..sort((a, b) => DateTime.parse(a.createdAt)
                        .compareTo(DateTime.parse(b.createdAt)));

                  if (statusList.isEmpty) return const SizedBox();

                  return RefreshIndicator(
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
                          context
                              .read<WormActivityBloc>()
                              .add(WormActivityList());
                          context
                              .read<StatusRecordBloc>()
                              .add(StatusRecordList());
                        });

                        // showing snackbar
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: const Text('Page Refreshed')));
                      });
                    },
                    child: Container(
                      height: deviceHeight,
                      width: deviceWidth,
                      padding: const EdgeInsets.fromLTRB(44, 64, 44, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _headerSection(),
                          const SizedBox(height: 20),
                          Expanded(
                            child: GridView.builder(
                              shrinkWrap: true,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 1.5,
                              ),
                              itemCount: state.compostScheduleList.length,
                              itemBuilder: (context, index) {
                                final schedule =
                                    state.compostScheduleList[index];

                                final List<StatusRecord> filtered = statusList
                                    .where((item) =>
                                        item.scheduleId == schedule.id)
                                    .toList();

                                filtered.sort((a, b) =>
                                    DateTime.parse(b.createdAt).compareTo(
                                        DateTime.parse(a.createdAt)));

                                final StatusRecord? statusRecord =
                                    filtered.isNotEmpty ? filtered.first : null;

                                return InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => ScheduleScreen(
                                                scheduleId: schedule.id)));
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        width: 1,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surfaceContainerHigh,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                schedule.scheduleName,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            StatusBadge(
                                              color: !schedule.isCompleted
                                                  ? Colors.amber
                                                  : Colors.greenAccent,
                                              state: !schedule.isCompleted
                                                  ? "In Progress"
                                                  : "Completed",
                                            )
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          spacing: 8,
                                          children: [
                                            Row(
                                              spacing: 2,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  "Progress",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Constants()
                                                        .textMutedFgDark,
                                                  ),
                                                ),
                                                Text(
                                                  statusRecord!.status.name
                                                      .firstLetterUpperCase(),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    letterSpacing: 0.025,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              child: LinearProgressIndicator(
                                                minHeight: 6,
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .surfaceContainerHigh,
                                                color: statusRecord.isCompleted
                                                    ? statusRecord.status ==
                                                            CompostingStatus
                                                                .released
                                                        ? Colors.greenAccent
                                                        : Colors.blueAccent
                                                    : Colors.grey,
                                                value: _getProgressValue(
                                                    statusRecord.status),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Compost",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Constants()
                                                        .textMutedFgDark,
                                                    fontWeight: FontWeight.w500,
                                                    letterSpacing: 0.025,
                                                  ),
                                                ),
                                                Text(
                                                  "${schedule.compostProduced ?? "0"}kg",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                )
                                              ],
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Vermitea",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Constants()
                                                        .textMutedFgDark,
                                                    fontWeight: FontWeight.w500,
                                                    letterSpacing: 0.025,
                                                  ),
                                                ),
                                                Text(
                                                  "${schedule.juiceProduced ?? "0"}L",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
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
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                }

                return const SizedBox();
              });
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _headerSection() {
    return Text(
      "Compost Schedule List",
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
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
}

double _getProgressValue(CompostingStatus status) {
  switch (status) {
    case CompostingStatus.initial:
      return 0.25;
    case CompostingStatus.active:
      return 0.50;
    case CompostingStatus.ready:
      return 0.75;
    case CompostingStatus.released:
      return 1.0;
  }
}
