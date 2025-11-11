import 'dart:convert';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vermicomposting/core/common/widgets/dialog.dart';
import 'package:flutter_vermicomposting/core/common/widgets/glassmorphism.dart';
import 'package:flutter_vermicomposting/core/common/widgets/toast_helper.dart';
import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:flutter_vermicomposting/core/error/exception.dart';
import 'package:flutter_vermicomposting/core/secrets/app_secrets.dart';
import 'package:flutter_vermicomposting/core/utils/parse_error_message.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/data/models/compost_schedule_model.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/domain/entities/compost_schedule.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/presentation/bloc/compost_schedule_bloc.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/home_screen_widgets/daily_report_widget.dart';
import 'package:flutter_vermicomposting/features/status/presentation/bloc/status_record_bloc.dart';
import 'package:flutter_vermicomposting/mqtt_service.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SystemScheduleHeaderSection extends StatefulWidget {
  final MqttService mqttService;

  final CompostSchedule compostSchedule;

  const SystemScheduleHeaderSection({
    super.key,
    required this.compostSchedule,
    required this.mqttService,
  });

  @override
  State<SystemScheduleHeaderSection> createState() =>
      _SystemScheduleHeaderSectionState();
}

class _SystemScheduleHeaderSectionState
    extends State<SystemScheduleHeaderSection> {
  bool _responseLoaded = false;
  bool _responseError = false;
  late PromptBody _scheduleSummaryResponse;
  late ToastHelper _toaster;

  final formKey = GlobalKey<FormState>();

  final TextEditingController scheduleIdentifierController =
      TextEditingController();

  bool _isReadyToComplete = false;

  @override
  void initState() {
    super.initState();

    _getResponse();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _toaster = ToastHelper(context);

    final String formattedDate = DateFormat("d MMM yyyy, hh:mm")
        .format(DateTime.parse(widget.compostSchedule.createdAt));

    final toastHelper = ToastHelper(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 34,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.compostSchedule.scheduleName,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      FluentIcons.calendar_16_regular,
                      color: Constants().textMutedFgDark,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 2.5),
                      child: Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 16,
                          color: Constants().textMutedFgDark,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
            Row(
              spacing: 8,
              children: [
                BlocListener<CompostScheduleBloc, CompostScheduleState>(
                  listener: (ctx, state) {
                    if (state is CompostScheduleFailure) {
                      toastHelper.show(
                        title: "An error has occured",
                        description: state.error,
                        isError: true,
                      );
                    } else if (state is CompostScheduleSuccess) {
                      toastHelper.show(
                        title: "Update success",
                        description:
                            "Successfully changed the schedule name to ${state.compostSchedule.scheduleName}",
                        isError: false,
                      );
                    }
                  },
                  child: IconButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        width: 1,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () => _handleChangeScheduleName(toastHelper),
                    icon: Icon(
                      FluentIcons.edit_24_regular,
                      size: 18,
                    ),
                  ),
                ),
                BlocListener<StatusRecordBloc, StatusRecordState>(
                  listener: (ctx, state) {
                    if (state is StatusRecordFailure) {
                    } else if (state is StatusRecordListSuccess) {
                      final statusList = state.statusRecordList
                          .where((status) =>
                              status.scheduleId == widget.compostSchedule.id)
                          .toList()
                        ..sort((a, b) => DateTime.parse(b.createdAt)
                            .compareTo(DateTime.parse(a.createdAt)));

                      final firstStatus = statusList.first;
                      final isCompleted = firstStatus.isCompleted;

                      setState(() {
                        _isReadyToComplete =
                            firstStatus.status == CompostingStatus.released &&
                                !isCompleted;
                      });
                    }
                  },
                  child: _isReadyToComplete
                      ? OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            side: BorderSide(
                              color:
                                  Theme.of(context).colorScheme.outlineVariant,
                              width: 1,
                            ),
                            padding: const EdgeInsets.fromLTRB(14, 8.5, 12, 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () => _handleEndSchedule(toastHelper),
                          child: Row(
                            spacing: 6,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                FluentIcons
                                    .task_list_square_database_20_regular,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.8),
                                size: 14,
                              ),
                              Text(
                                "End Cycle",
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                  letterSpacing: 0.025,
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Row(
              spacing: 8,
              children: [
                Text(
                  "Summary",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.lightBlue.withAlpha(64),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Colors.lightBlue,
                    ),
                  ),
                  child: Text(
                    "AI",
                    style: TextStyle(
                      color: Colors.lightBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.025,
                    ),
                  ),
                )
              ],
            ),
            Skeletonizer(
              enabled: !_responseLoaded,
              child: Glassmorphism(
                blur: 12,
                opacity: 0.2,
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
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
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.blueAccent.withAlpha(28),
                        Colors.blueAccent.withAlpha(24),
                      ],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                  ),
                  child: Text(
                    textAlign: TextAlign.justify,
                    _responseLoaded && _scheduleSummaryResponse != null
                        ? _scheduleSummaryResponse!.insight
                        : "Preparing your summary... This may take a little longer than usual as the AI analyzes the data to generate insights.",
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withAlpha(212),
                      fontSize: 16,
                      letterSpacing: 0.025,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ],
    );
  }

  Future<void> _getResponse() async {
    try {
      final response = await http.post(
        Uri.parse(
            "${AppSecrets.domainURL}/summary/${widget.compostSchedule.id}"),
      );

      if (response.statusCode == 200) {
        _scheduleSummaryResponse =
            PromptBody.fromJson(jsonDecode(response.body));
        setState(() {
          _responseLoaded = true;
        });
      }
      setState(() {
        _responseError = false;
      });
    } on ServerException catch (e) {
      _toaster.show(
        title: "Something went wrong",
        description: e.toString(),
        isError: true,
      );
      setState(() {
        _responseError = true;
      });
    } catch (e) {
      _toaster.show(
        title: "Unexpected error has occured",
        description: e.toString(),
        isError: true,
      );
      setState(() {
        _responseError = true;
      });
    }
  }

  void _handleChangeScheduleName(ToastHelper toastHelper) {
    showDialog(
        context: context,
        builder: (context) {
          return GeneralDialog(
            title: 'Change compost schedule name',
            description: 'Modify your schedule name (e.g., Backyard Pile 1)',
            confirmButtonLabel: 'Continue',
            widget: Form(
              key: formKey,
              child: TextFormField(
                controller: scheduleIdentifierController,
                validator: (value) {
                  if (value!.isEmpty || value.length <= 8) {
                    return "Compost schedule name is invalid";
                  }
                  return null;
                },
              ),
            ),
            approvedFunction: () async {
              if (formKey.currentState!.validate()) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return GeneralDialog(
                      title: 'Change schedule name?',
                      description:
                          'Would you change the schedule name to ${scheduleIdentifierController.text}?',
                      confirmButtonLabel: 'Confirm',
                      approvedFunction: () async {
                        final response = await http.patch(
                          Uri.parse(
                              "https://verminator.thinkio.me/schedule/${widget.compostSchedule.id}"),
                          headers: <String, String>{
                            'Content-Type': 'application/json; charset=UTF-8',
                          },
                          body: jsonEncode(<String, dynamic>{
                            'scheduleName':
                                scheduleIdentifierController.text.trim(),
                          }),
                        );

                        if (response.statusCode == 200) {
                          final compostSchedule = CompostScheduleModel.fromJson(
                              jsonDecode(response.body));
                          toastHelper.show(
                              title: "Successfully updated",
                              description:
                                  "Successfully updated schedule name to ${compostSchedule.scheduleName}",
                              isError: false);
                          context
                              .read<CompostScheduleBloc>()
                              .add(CompostScheduleList());
                          Navigator.of(context, rootNavigator: true)
                              .popUntil((route) => route is PageRoute);
                        } else {
                          toastHelper.show(
                              title: "An error has occurred",
                              description: response.body.parseErrorMessage(),
                              isError: true);
                        }
                      },
                    );
                  },
                );
              }
            },
          );
        });
  }

  void _handleEndSchedule(ToastHelper toastHelper) async {
    final rootContext = context;
    final MqttService mqttService = widget.mqttService;
    final SupabaseClient supabase = GetIt.instance<SupabaseClient>();
    final now = DateTime.now().toIso8601String();

    showDialog(
      context: rootContext,
      builder: (BuildContext dialogContext) {
        return GeneralDialog(
          title: 'Finalize Vermicomposting Cycle',
          description:
              'Are you sure you want to mark this vermicomposting cycle as complete? This action will finalize all associated data',
          confirmButtonLabel: 'Confirm',
          approvedFunction: () async {
            Navigator.of(dialogContext).pop();
            await Future.delayed(const Duration(milliseconds: 150));

            showDialog(
              context: rootContext,
              barrierDismissible: false,
              builder: (_) => const Center(child: CircularProgressIndicator()),
              useRootNavigator: true,
            );

            Future<void> fail(String title, String message) async {
              Navigator.of(rootContext, rootNavigator: true).pop();
              toastHelper.show(
                title: title,
                description: message,
                isError: true,
              );
            }

            try {
              final scheduleUri = Uri.parse(
                "https://verminator.thinkio.me/schedule/${widget.compostSchedule.id}",
              );

              final schedulePayload = {
                'compostProduced': "4",
                'juiceProduced': "2",
                'isCompleted': true,
                'dateReleased': now,
              };

              final scheduleResponse = await http.patch(
                scheduleUri,
                headers: {'Content-Type': 'application/json; charset=UTF-8'},
                body: jsonEncode(schedulePayload),
              );

              if (scheduleResponse.statusCode != 200) {
                await fail("Schedule update failed",
                    scheduleResponse.body.parseErrorMessage());
                return;
              }

              await supabase
                  .from("status_records")
                  .update({
                    "is_completed": true,
                  })
                  .eq('status_schedule_id', widget.compostSchedule.id)
                  .eq('status', 'released');

              final settingsPayload = {
                "status": "idle",
                "id": 0,
                "reading_interval": "15",
                "refresh_rate": "2",
              };

              mqttService.publish(
                "system/settings",
                jsonEncode(settingsPayload),
                qos: MqttQos.atLeastOnce,
                retain: true,
              );

              Navigator.of(rootContext, rootNavigator: true).pop();

              toastHelper.show(
                title: "Cycle Finalized",
                description:
                    "The vermicomposting cycle has been successfully completed and recorded.",
                isError: false,
              );

              context.read<CompostScheduleBloc>().add(CompostScheduleList());

              await Future.delayed(const Duration(milliseconds: 100));

              Navigator.of(rootContext, rootNavigator: true)
                  .popUntil((route) => route is PageRoute);
            } catch (e) {
              await fail("Unexpected Error", e.toString());
            }
          },
        );
      },
    );
  }
}
