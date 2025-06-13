import 'dart:convert';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vermicomposting/core/common/widgets/dialog.dart';
import 'package:flutter_vermicomposting/core/common/widgets/toast_helper.dart';
import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:flutter_vermicomposting/core/utils/parse_error_message.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/data/models/compost_schedule_model.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/domain/entities/compost_schedule.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/presentation/bloc/compost_schedule_bloc.dart';
import 'package:flutter_vermicomposting/mqtt_service.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mqtt_client/mqtt_client.dart';

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
  final formKey = GlobalKey<FormState>();

  final TextEditingController scheduleIdentifierController =
      TextEditingController();

  @override
  void dispose() {
    super.dispose();
    // scheduleIdentifierController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate = DateFormat("d MMM yyyy, hh:mm")
        .format(DateTime.parse(widget.compostSchedule.createdAt));

    final toastHelper = ToastHelper(context);

    return BlocListener<CompostScheduleBloc, CompostScheduleState>(
      listener: (context, state) {
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
      child: Row(
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
              IconButton(
                style: OutlinedButton.styleFrom(
                  // backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
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
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  // backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
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
                      FluentIcons.task_list_square_database_20_regular,
                      // or FluentIcons.checkmark_circle_16_filled
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.8),
                      size: 14,
                    ),
                    Text(
                      "End Cycle",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        letterSpacing: 0.025,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
            approvedFunction: () {
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

  void _handleEndSchedule(ToastHelper toastHelper) {
    final MqttService mqttService = widget.mqttService;
    final now = DateTime.now().toIso8601String();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GeneralDialog(
          title: 'Finalize Vermicomposting Cycle',
          description:
              'Are you sure you want to mark this vermicomposting cycle as complete? This action will finalize all associated data',
          confirmButtonLabel: 'Confirm',
          approvedFunction: () async {
            try {
              final scheduleUri = Uri.parse(
                "https://verminator.thinkio.me/schedule/${widget.compostSchedule.id}",
              );

              final statusUri = Uri.parse(
                "https://verminator.thinkio.me/status",
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
                throw Exception(scheduleResponse.body.parseErrorMessage());
              }

              mqttService.publish(
                "system/status",
                "idle",
                qos: MqttQos.atLeastOnce,
                retain: true,
              );

              final statusPayload = {
                'statusScheduleId': widget.compostSchedule.id,
                'status': CompostingStatus.released.name,
                'remarks': "",
              };

              final statusResponse = await http.patch(
                statusUri,
                headers: {'Content-Type': 'application/json; charset=UTF-8'},
                body: jsonEncode(statusPayload),
              );

              if (statusResponse.statusCode != 200) {
                throw Exception(statusResponse.body.parseErrorMessage());
              }

              toastHelper.show(
                title: "Cycle Finalized",
                description:
                    "The vermicomposting cycle has been successfully completed and recorded.",
                isError: false,
              );

              context.read<CompostScheduleBloc>().add(CompostScheduleList());

              Navigator.of(context, rootNavigator: true)
                  .popUntil((route) => route is PageRoute);
            } catch (e) {
              toastHelper.show(
                title: "An error has occurred",
                description: e.toString(),
                isError: true,
              );
            }
          },
        );
      },
    );
  }
}
